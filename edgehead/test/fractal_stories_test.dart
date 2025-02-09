import 'package:built_collection/built_collection.dart';
import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/anatomy/body_part.dart';
import 'package:edgehead/fractal_stories/anatomy/deal_slashing_damage.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/item.dart';
import 'package:edgehead/fractal_stories/items/weapon_type.dart';
import 'package:edgehead/fractal_stories/room.dart';
import 'package:edgehead/fractal_stories/room_approach.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/situation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/ruleset/ruleset.dart';
import 'package:edgehead/src/fight/counter_attack/counter_attack_situation.dart';
import 'package:edgehead/src/fight/fatality_on_ground/fatality_on_ground.dart';
import 'package:edgehead/src/fight/fight_situation.dart';
import 'package:edgehead/src/fight/off_balance_opportunity/off_balance_opportunity_situation.dart';
import 'package:edgehead/src/fight/slash/slash_defense/slash_defense_situation.dart';
import 'package:edgehead/src/fight/slash/slash_situation.dart';
import 'package:edgehead/src/fight/strike_down/strike_down_defense/on_ground_defense_situation.dart';
import 'package:edgehead/src/fight/strike_down/strike_down_situation.dart';
import 'package:edgehead/src/predetermined_result.dart';
import 'package:edgehead/src/room_roaming/room_roaming_situation.dart';
import 'package:test/test.dart';

void main() {
  group("fractal_stories", () {
    group("Actor", () {
      test("rebuilt actor has different hashcode", () {
        Actor filip = Actor.initialized(1, "Filip",
            isPlayer: true,
            pronoun: Pronoun.YOU,
            currentWeapon: Item.weapon(42, WeaponType.sword),
            constitution: 2,
            stamina: 1,
            initiative: 1000);

        var filip2 = filip.rebuild((b) => b);
        var richard = filip.rebuild((b) => b..name = "Richard");

        expect(filip.hashCode, equals(filip2.hashCode));
        expect(filip.hashCode, isNot(richard.hashCode));
      });
    });

    group("Situation", () {
      Actor a, b;
      final sim =
          Simulation(const [], const [], const {}, const Ruleset.empty());
      final world = WorldState((b) => b
        ..actors = SetBuilder<Actor>(<Actor>[])
        ..situations = ListBuilder<Situation>(<Situation>[])
        ..statefulRandomState = 1337
        ..time = DateTime.utc(1000)).toBuilder();

      setUp(() {
        a = Actor.initialized(1001, "A");
        b = Actor.initialized(1002, "B");
      });

      test("FightSituation", () {
        var roomRoamingSituation = RoomRoamingSituation.initialized(
            1, Room("something", (c) {}, (c) {}, null, null), false);
        checkSituationBuild(() => FightSituation.initialized(
            2, [], [], "ground", roomRoamingSituation, {}));
        checkSituationBuild(() => FightSituation.initialized(
            3, [a], [b], "ground", roomRoamingSituation, {}));
      });
      test("OnGroundDefenseSituation", () {
        checkSituationBuild(() =>
            createOnGroundDefenseSituation(1, a, b, Predetermination.none));
      });
      test("StrikeDownSituation", () {
        checkSituationBuild(() => createStrikeDownSituation(1, a, b));
      });
      test("CounterAttackSituation", () {
        checkSituationBuild(() => CounterAttackSituation.initialized(1, a, b));
      });
      test("OffBalanceOpportunitySituation", () {
        checkSituationBuild(
            () => OffBalanceOpportunitySituation.initialized(1, a));
        checkSituationBuild(
            () => OffBalanceOpportunitySituation.initialized(2, a, culprit: b));
      });
      test("SlashDefenseSituation", () {
        checkSituationBuild(
            () => createSlashDefenseSituation(1, a, b, Predetermination.none));
      });
      test("SlashSituation from direction", () {
        checkSituationBuild(() =>
            createSlashSituation(1, a, b, direction: SlashDirection.left));
      });
      test("SlashSituation as designation", () {
        checkSituationBuild(() => createSlashSituation(1, a, b,
            designation: BodyPartDesignation.primaryArm));
      });
      test("FatalityOnGroundSituation", () {
        checkSituationBuild(
            () => createFatalityOnGroundSituation(a, sim, world, b));
      });
    });

    group("Exits", () {
      bool forgeIsAfterFire;

      setUp(() {
        forgeIsAfterFire = false;
      });

      final afterFireCrevice = Room("after_fire_hidden_crevice",
          emptyRoomDescription, emptyRoomDescription, null, null);

      const _forgeName = "forge";

      const _forgeAfterFireName = "forge_after_fire";

      final creviceExit = Approach(_forgeAfterFireName, afterFireCrevice.name,
          "explore to hidden crevice", (_) {});

      const _outsideName = "outside";

      final forgeEntryAfterFire = Approach(
          _outsideName, _forgeAfterFireName, "enter the charred forge", (_) {});

      final forgeEntry =
          Approach(_outsideName, _forgeName, "enter the forge", (_) {});

      final outside = Room(
          _outsideName, emptyRoomDescription, emptyRoomDescription, null, null);

      final outsideExit =
          Approach(_forgeName, outside.name, "go outside", (_) {});

      final forge = Room(
          _forgeName, emptyRoomDescription, emptyRoomDescription, null, null);

      final forgeAfterFire = Room(_forgeAfterFireName, emptyRoomDescription,
          emptyRoomDescription, null, null,
          parent: _forgeName,
          prerequisite: Prerequisite(
              _forgeAfterFireName.hashCode, 1, false, (_) => forgeIsAfterFire));

      final simulation = Simulation(
          [forge, forgeAfterFire, afterFireCrevice, outside],
          [creviceExit, forgeEntryAfterFire, forgeEntry, outsideExit],
          const {},
          const Ruleset.empty());

      final context = ApplicabilityContext(null, simulation, null);

      test("the default is picked when no more specific apply", () {
        expect(simulation.getAvailableApproaches(outside, context),
            unorderedEquals(<Approach>[forgeEntry]));
      });

      test("variants get parent's exits if not overridden", () {
        forgeIsAfterFire = true;
        expect(simulation.getAvailableApproaches(forgeAfterFire, context),
            unorderedEquals(<Approach>[outsideExit, creviceExit]));
      });

      test("variants use own exits over parent's when overridden", () {
        forgeIsAfterFire = true;
        expect(simulation.getAvailableApproaches(outside, context),
            unorderedEquals(<Approach>[forgeEntryAfterFire]));
      });

      group("RoomRoamingSituation.moveActor", () {
        final aren =
            Actor.initialized(42, "Aren", currentRoomName: _outsideName);
        final initialSituation =
            RoomRoamingSituation.initialized(1, outside, false);
        final world = WorldState((b) => b
          ..actors = SetBuilder<Actor>(<Actor>[aren])
          ..situations = ListBuilder<Situation>(<Situation>[initialSituation])
          ..statefulRandomState = 1337
          ..time = DateTime.utc(1000));

        const sureSuccess = ReasonedSuccessChance.sureSuccess;

        test("uses default if no variant is applicable", () {
          final actionContext = ActionContext(null, aren, simulation, world,
              world.toBuilder(), null, sureSuccess);

          initialSituation.moveActor(actionContext, _forgeName, silent: true);
          final result = actionContext.outputWorld.build();

          expect(result.getActorById(aren.id).currentRoomName, _forgeName);
        });

        test("uses variant if applicable", () {
          final actionContext = ActionContext(null, aren, simulation, world,
              world.toBuilder(), null, sureSuccess);
          forgeIsAfterFire = true;

          expect(world.visitHistory.getLatestOnly(aren)?.roomName,
              isNot(_forgeAfterFireName));

          initialSituation.moveActor(actionContext, _forgeName, silent: true);
          final result = actionContext.outputWorld.build();

          expect(result.visitHistory.getLatestOnly(aren).roomName,
              _forgeAfterFireName);
        });

        test("actor's currentRoom is always the parent", () {
          final actionContext = ActionContext(null, aren, simulation, world,
              world.toBuilder(), null, sureSuccess);
          forgeIsAfterFire = true;

          initialSituation.moveActor(actionContext, _forgeName, silent: true);
          final result = actionContext.outputWorld.build();

          expect(result.getActorById(aren.id).currentRoomName, _forgeName);
        });
      });
    });
  });
}

/// Checks whether the situation initializes correctly. It also checks some
/// assumptions about [Situation.id], [Situation.hashCode] and
/// [Situation.elapseTurn].
///
/// Provide [build], a closure that generates a new situation every time it
/// is called.
void checkSituationBuild(Situation build()) {
  Situation a;

  // Building returns normally.
  expect(() {
    a = build();
  }, returnsNormally);

  // Hashcode returns consistently.
  expect(a.hashCode, a.hashCode);

  // Situations initialize with time == 0.
  expect(a.turn, 0);

  var b = a.elapseTurn();

  // Situation.elapseTime() works
  expect(b.turn, a.turn + 1);

  // Situations keep id when elapsing time.
  expect(a.id, equals(b.id));

  // Hashcode for same situation with different [time] data is different.
  expect(a.hashCode, isNot(b.hashCode));
}
