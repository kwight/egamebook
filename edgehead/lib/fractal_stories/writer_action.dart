/// Use these classes in sources generated from writer's input.
library stranded.writer_action;

import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/room_roaming/room_roaming_situation.dart';

/// This is analogous to [SimpleActionApplyFunction], but for the
/// [Action.isApplicable] closure.
typedef SimpleActionApplicableFunction = bool Function(
    ApplicabilityContext context,
    Actor a,
    Simulation sim,
    WorldState w,
    SimpleAction self);

/// This closure signature is here in order to allow [SimpleAction] to be
/// defined without needing to implement the class.
///
/// For example, apply function needs access to the class's
/// [SimpleAction.movePlayer] method, but a closure won't be able to access it
/// without the [self] parameter.
typedef SimpleActionApplyFunction = String Function(
    ActionContext c, SimpleAction self);

/// An action that takes place in the context of a [RoomRoamingSituation]
/// (either directly or as an indirect descendant of such situation).
abstract class RoamingAction extends Action<Nothing> {
  @override
  final bool isProactive = true;

  @override
  final bool isImplicit = false;
}

/// This is a simple actions that, once taken, always succeed.
///
/// It is meant to be used for classic 'CYOA-style' options. Anything more
/// involved (needing a target, a non-1.0 success chance, rerollability)
/// will need to use another class or extend [Action].
class SimpleAction extends RoamingAction {
  final SimpleActionApplyFunction success;

  final SimpleActionApplicableFunction isApplicableClosure;

  final String simpleActionCommand;

  @override
  final String helpMessage;

  @override
  final String name;

  SimpleAction(
      this.name, this.simpleActionCommand, this.success, this.helpMessage,
      {this.isApplicableClosure});

  @override
  bool get isAggressive => false;

  @override
  bool get rerollable => false;

  @override
  Resource get rerollResource => throw StateError("Not rerollable");

  @override
  String applyFailure(ActionContext context, void object) {
    throw StateError("SimpleAction always succeeds");
  }

  @override
  String applySuccess(ActionContext context, void object) {
    return success(context, this);
  }

  @override
  String getRollReason(Actor a, Simulation sim, WorldState w, void object) {
    throw StateError("SimpleAction shouldn't have to provide roll reason");
  }

  @override
  ReasonedSuccessChance getSuccessChance(
      Actor a, Simulation sim, WorldState w, void object) {
    return ReasonedSuccessChance.sureSuccess;
  }

  @override
  bool isApplicable(ApplicabilityContext context, Actor a, Simulation sim,
      WorldState w, void object) {
    if (isApplicableClosure == null) return true;
    return isApplicableClosure(context, a, sim, w, this);
  }

  @override
  Iterable<Nothing> generateObjects(ApplicabilityContext context) {
    throw AssertionError('generateObjects was called on Action<Nothing>');
  }

  @override
  List<String> get commandPathTemplate => [simpleActionCommand];
}
