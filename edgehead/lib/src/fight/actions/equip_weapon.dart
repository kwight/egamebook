import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/item.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';

/// This [Action] requires an [item] from the performer's inventory.
///
/// It will skip weapons that are held by the actor.
class EquipWeapon extends Action<Item> {
  static const String className = "EquipWeapon";

  static final Action<Item> singleton = EquipWeapon();

  @override
  final bool isImplicit = false;

  @override
  List<String> get commandPathTemplate => ["self", "<object>", "equip"];

  @override
  final String helpMessage = "Picking a different weapon can be a smart move. "
      "Different weapons excel in different situations.";

  @override
  final bool isAggressive = false;

  @override
  final bool isProactive = true;

  @override
  String get name => className;

  @override
  final bool rerollable = false;

  @override
  Resource get rerollResource => throw StateError('not rerollable');

  @override
  String applyFailure(ActionContext context, Item object) {
    throw StateError('not a failing action');
  }

  @override
  String applySuccess(ActionContext context, Item object) {
    Actor a = context.actor;
    Storyline s = context.outputStoryline;

    if (a.holdsSomeWeapon) {
      var beltOrBack = a.currentWeapon.damageCapability.length > 1
          // Spears and swords belong behind one's back.
          ? "behind <subject's> back"
          // The rest can go in the belt.
          : "to <subject's> belt";
      a.report(s, "<subject> replace<s> <object> $beltOrBack",
          object: a.currentWeapon);
    }

    context.outputWorld
        .updateActorById(a.id, (b) => b.inventory.equip(object, a.anatomy));

    a.report(s, "<subject> draw<s> <object>", object: object);

    return "actor ${context.actor.name} equipped ${object.name}";
  }

  @override
  Iterable<Item> generateObjects(ApplicabilityContext context) {
    // Takes all weapons from inventory except from the one currently held.
    return context.actor.inventory.weapons
        .where((w) => w.id != context.actor.currentWeapon?.id);
  }

  @override
  String getRollReason(Actor a, Simulation sim, WorldState w, Item object) {
    throw StateError('not rerollable');
  }

  @override
  ReasonedSuccessChance getSuccessChance(
          Actor a, Simulation sim, WorldState w, Item object) =>
      ReasonedSuccessChance.sureSuccess;

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
      WorldState w, Item object) {
    if (!a.anatomy.anyWeaponAppendageAvailable) return false;
    if (a.isPlayer) return true;

    // NPCs and monsters have additional requirement: new item must be better
    // than current one.
    return object.value > (a.currentWeapon?.value ?? 0);
  }

  @override
  String toString() => "EquipWeapon<$commandPathTemplate>";
}
