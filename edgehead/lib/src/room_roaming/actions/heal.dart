import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/anatomy/deep_replace_body_part.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/room_roaming/room_roaming_situation.dart';

class HealAction extends Action<Actor> {
  static const className = 'HealAction';

  static final HealAction singleton = HealAction();

  @override
  List<String> get commandPathTemplate => ['<object>', 'heal'];

  @override
  String get helpMessage => null;

  @override
  bool get isAggressive => false;

  @override
  bool get isImplicit => false;

  @override
  bool get isProactive => true;

  @override
  String get name => className;

  @override
  bool get rerollable => false;

  @override
  Resource get rerollResource => throw UnimplementedError();

  @override
  String applyFailure(ActionContext context, Actor object) {
    throw UnimplementedError();
  }

  @override
  String applySuccess(ActionContext context, Actor patient) {
    final a = context.actor;
    final w = context.outputWorld;
    final s = context.outputStoryline;

    final parts = patient.anatomy.woundedParts.toList(growable: false);
    final count = parts.length;
    assert(count > 0);
    final woundOrWounds = count > 1 ? 'wounds' : 'wound';
    a.report(
        s,
        "<subject> put<s> <subject's> hand on "
        "<object's> $woundOrWounds",
        object: patient);

    // TODO: reattach limbs

    final patientBuilder = patient.toBuilder();
    deepReplaceBodyPart(
      patient,
      patientBuilder,
      (part) => part.hitpoints < part.maxHitpoints,
      (b, isDescendant) {
        if (isDescendant) return;
        b.hitpoints = b.maxHitpoints;
      },
    );

    w.updateActorById(patient.id, (b) => b.replace(patientBuilder.build()));

    s.addEnumeration("", parts, "<is> <also> healed");
    return "${a.name} healed ${patient.name}";
  }

  @override
  Iterable<Actor> generateObjects(ApplicabilityContext context) {
    final player = _getPlayer(context.world.actors);
    return getPartyOf(player, context.simulation, context.world);
  }

  @override
  String getRollReason(Actor a, Simulation sim, WorldState w, Actor object) =>
      null;

  @override
  ReasonedSuccessChance getSuccessChance(
          Actor a, Simulation sim, WorldState w, Actor object) =>
      ReasonedSuccessChance.sureSuccess;

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
      WorldState w, Actor patient) {
    if ((w.currentSituation as RoomRoamingSituation).monstersAlive) {
      // Don't allow healing when monsters in this room are still alive.
      return false;
    }

    if (!a.isPlayer) return false;
    if (a.id != patient.id && !a.anatomy.anyWeaponAppendageAvailable) {
      return false;
    }

    return patient.anatomy.woundedParts.isNotEmpty;
  }

  Actor _getPlayer(Iterable<Actor> actors) =>
      actors.firstWhere((a) => a.isPlayer && a.isAnimatedAndActive);
}
