import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/anatomy/body_part.dart';
import 'package:edgehead/fractal_stories/anatomy/deal_slashing_damage.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/pose.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/common/conflict_chance.dart';
import 'package:edgehead/src/fight/common/drop_weapon.dart';
import 'package:edgehead/src/fight/common/recently_forced_to_ground.dart';
import 'package:edgehead/src/fight/common/humanoid_pain_or_death.dart';
import 'package:edgehead/src/fight/sweep_feet/sweep_feet_situation.dart';

ReasonedSuccessChance computeCounterSweepFeet(
    Actor a, Simulation sim, WorldState w, Actor enemy) {
  return getCombatMoveChance(a, enemy, 0.3, const [
    Modifier(30, CombatReason.dexterity),
    Modifier(20, CombatReason.balance),
    Bonus(20, CombatReason.targetHasPrimaryArmDisabled),
    Bonus(30, CombatReason.targetHasOneLegDisabled),
    Bonus(50, CombatReason.targetHasOneEyeDisabled),
    Bonus(50, CombatReason.targetHasAllEyesDisabled),
  ]);
}

class CounterSweepFeet extends OtherActorAction {
  static final CounterSweepFeet singleton = CounterSweepFeet();

  static const String className = "CounterSweepFeet";

  @override
  final String helpMessage = "That's an extended leg down there. I can try "
      "attacking. I should beware, though: this move is a bit more complicated"
      " than just staying away.";

  @override
  final bool isAggressive = true;

  @override
  final bool isProactive = false;

  @override
  final bool rerollable = true;

  @override
  final Resource rerollResource = Resource.stamina;

  @override
  List<String> get commandPathTemplate => const ["slash the leg"];

  @override
  String get name => className;

  @override
  String get rollReasonTemplate => "will <subject> hit the leg "
      "and keep <subject's> stance?";

  @override
  String applyFailure(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    Simulation sim = context.simulation;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;
    final thread = getThreadId(sim, w, sweepFeetSituationName);
    a.report(s, "<subject> attempt<s> to counter <object's> foot sweep",
        object: enemy, actionThread: thread);
    a.report(s, "<subject> fail<s> to slash <object's> leg",
        object: enemy, but: true, negative: true, actionThread: thread);
    w.popSituation(sim);
    return "${a.name} fails to counter sweep feet from ${enemy.name}";
  }

  @override
  String applySuccess(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    Simulation sim = context.simulation;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;
    final thread = getThreadId(sim, w, sweepFeetSituationName);
    a.report(s, "<subject> step<s> around the foot sweep",
        actionThread: thread);

    assert(
        enemy.anatomy.isHumanoid,
        "This part assumes that the enemy has legs "
        "and that those are the only 'mobile' bodyparts.");
    var leg = enemy.anatomy.allParts
        .where((part) =>
            part.function == BodyPartFunction.mobile &&
            part.isAnimatedAndActive)
        .first;

    final damage = a.currentDamageCapability.slashingDamage;
    var result = executeSlashingHit(
        enemy, a.currentWeaponOrBodyPart, SlashSuccessLevel.majorCut,
        bodyPart: leg);

    w.updateActorById(enemy.id, (b) => b.replace(result.victim));

    assert(
        result.victim.isAnimated,
        "This assumes the enemy doesn't immediately die from "
        "the leg wound. Which is a safe bet unless they have some really "
        "weird anatomy.");

    // Copied from finish_slash.dart.
    a.report(
        s,
        "<subject> {slash<es>|cut<s>} <object's> "
        "${result.touchedPart.randomDesignation}",
        object: result.victim,
        positive: true,
        actionThread: thread);
    if (result.disabled) {
      result.touchedPart.report(s, "<subject> go<es> limp",
          negative: true, actionThread: thread);
    }
    if (result.willDropCurrentWeapon) {
      final weapon = dropCurrentWeapon(w, result.victim.id);
      result.victim.report(s, "<subject> drop<s> <object>",
          object: weapon, negative: true, actionThread: thread);
    }
    if (result.willFall) {
      result.victim.report(s, "<subject> fall<s> {|down|to the ground}",
          negative: true, actionThread: thread);
      w.updateActorById(result.victim.id, (b) => b.pose = Pose.onGround);
      w.recordCustom(fellToGroundCustomEventName, actor: result.victim);
    }
    inflictPain(context, enemy.id, damage, result.touchedPart);

    w.popSituationsUntil("FightSituation", sim);

    return "${a.name} successfully counters a sweep feet from ${enemy.name}";
  }

  @override
  ReasonedSuccessChance getSuccessChance(
      Actor a, Simulation sim, WorldState w, Actor enemy) {
    return computeCounterSweepFeet(a, sim, w, enemy);
  }

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
          WorldState w, Actor enemy) =>
      !a.anatomy.isBlind &&
      a.currentDamageCapability.isSlashing &&
      // Never do this to the player, that would just suck.
      !enemy.isPlayer;
}
