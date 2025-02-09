import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';
import 'package:egamebook_builder/writers_builder.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import '../parse_writers_input/generated_action.dart' hide log;
import '../parse_writers_input/generated_approach.dart';
import '../parse_writers_input/generated_game_object.dart';
import '../parse_writers_input/generated_room.dart';
import '../parse_writers_input/parse_writers_input.dart' hide log;
import '../parse_writers_input/types.dart';

/// Generator for FunctionSerializer.
class WritersInputGenerator extends Generator {
  // Allow creating via `const` as well as enforces immutability here.
  static const List<String> validExtensions = [".txt"];

  const WritersInputGenerator();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final result = StringBuffer();

    final fileName = library.element.source.shortName.replaceAll('.dart', '');

    AnnotatedElement annotation = _getGatherAnnotation(library);
    if (annotation == null) {
      throw InvalidGenerationSourceError("File is specified as writer's input "
          "but no @GatherWriterInputFrom(['path/...']) annotation "
          "specified.");
    }

    final element = annotation.element;
    if (element is! LibraryElement) {
      throw InvalidGenerationSourceError(
          "Elements annotated with @GatherFunctionsFrom "
          "must be libraries.");
    }

    final globs = annotation.annotation
        .read("globs")
        .listValue
        .map((dartObject) => dartObject.toStringValue());

    final cb.LibraryBuilder lib = cb.LibraryBuilder();
    List<GeneratedGameObject> objects = [];

    for (final glob in globs) {
      log.fine('Traversing glob $glob');
      final assetIds = buildStep.findAssets(Glob(glob, recursive: true));
      await for (final id in assetIds) {
        log.finer('Compiling $id');
        if (!validExtensions.contains(id.extension)) continue;
        final path = id.uri.toString();
        final List<String> lines =
            (await buildStep.readAsString(id)).split("\n");
        final rawMaps = parseWritersOutput(lines);
        for (var rawMap in rawMaps) {
          if (rawMap.keys.contains("ROOM")) {
            // TODO: remove dirPath if not needed
            var room = generateRoom(rawMap, path);
            objects.add(room);
          } else if (rawMap.keys.contains("ACTION")) {
            var action = generateAction(rawMap, path);
            objects.add(action);
          } else if (rawMap.keys.contains("APPROACH")) {
            final approach = generateApproach(rawMap, path);
            objects.add(approach);
          }
        }
      }
    }

    lib.directives.addAll((allNeededTypes
        .map((type) => cb.Directive.import(type.url, show: [type.symbol]))));

    lib.directives
        .add(cb.Directive.import('package:built_value/built_value.dart'));
    lib.directives
        .add(cb.Directive.import('package:built_value/serializer.dart'));
    lib.directives
        .add(cb.Directive.import('package:edgehead/writers_helpers.dart'));
    lib.directives
        .add(cb.Directive.import('package:edgehead/edgehead_ids.dart'));

    lib.body.add(cb.Code("part '$fileName.compiled.g.dart';"));

    final devMode = false;
    if (devMode) {
      log.warning("Building in dev mode (less runtime asserts).");
    }
    lib.body.add(cb.Field((b) => b
      ..name = 'DEV_MODE'
      ..type = boolType
      ..modifier = cb.FieldModifier.constant
      ..assignment = cb.literal(devMode).code));

    final List<GeneratedRoom> rooms =
        objects.whereType<GeneratedRoom>().toList(growable: false);
    for (final room in rooms) {
      room.registerReachableRooms(rooms.map((r) => r.writersName));
    }

    for (final object in objects) {
      lib.body.addAll(object.finalizeAst());
    }

    lib.body.add(generateAllRooms(objects));
    lib.body.add(generateAllApproaches(objects));
    lib.body.add(generateAllActionInstances(objects));

    final emitter = cb.DartEmitter();
    final source = DartFormatter().format('${lib.build().accept(emitter)}');

    // TODO: add at the top as static code
    final sourceWithUnusedLinterIgnore =
        "// ignore_for_file: constant_identifier_names\n"
        "// ignore_for_file: unused_local_variable\n"
        "// ignore_for_file: unnecessary_parenthesis\n"
        "// ignore_for_file: lines_longer_than_80_chars\n"
        "// ignore_for_file: type_annotate_public_apis\n\n"
        "$source";

    result.writeln(sourceWithUnusedLinterIgnore);

    if (result.isNotEmpty) {
      return result.toString();
    } else {
      return null;
    }
  }

  AnnotatedElement _getGatherAnnotation(LibraryReader library) {
    final annotationChecker = TypeChecker.fromRuntime(GatherWriterInputFrom);
    for (final metadata in library.element.metadata) {
      // We must call this to force computation of the constant value.
      // Otherwise, metadata.constantValue might be `null`.
      metadata.computeConstantValue();
      final constant = ConstantReader(metadata.constantValue);
      if (annotationChecker.isExactlyType(metadata.constantValue.type)) {
        return AnnotatedElement(constant, library.element);
      }
    }
    return null;
  }
}
