library edgehead.event_callbacks;

// ignore_for_file: type_annotate_public_apis
// ignore_for_file: non_constant_identifier_names

import 'package:edgehead/edgehead_ids.dart';
import 'package:edgehead/fractal_stories/item.dart';
import 'package:edgehead/fractal_stories/items/weapon_type.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/src/room_roaming/room_roaming_situation.dart';
import 'package:edgehead/writers_helpers.dart';
import 'package:egamebook_builder/instance_serializer.dart';

part 'edgehead_event_callbacks_gather.gathered.dart';

final agruth_enjoy_eating_flesh = EventCallback((c, sim, w, s) {
  var agruth = w.getActorById(agruthId);
  s.addParagraph();
  agruth.report(
      s,
      "\"I'll enjoy eating your flesh, human,\" "
      "<subject> snarl<s>.",
      wholeSentence: true);
  s.addParagraph();
});

final agruth_grit_teeth = EventCallback((c, sim, w, s) {
  var agruth = w.getActorById(agruthId);
  agruth.report(s, "<subject> grit<s> <subject's> teeth");
  agruth.report(s, "<subject> <does>n't talk any more", but: true);
});

final agruth_scowls = EventCallback((c, sim, w, s) {
  var agruth = w.getActorById(agruthId);
  agruth.report(s, "<subject> scowl<s> with pure hatred");
});

final agruth_spits = EventCallback((c, sim, w, s) {
  var agruth = w.getActorById(agruthId);
  agruth.report(s, "<subject> spit<s> on the cavern floor");
});

final escape_pursuers_reach = EventCallback((c, sim, w, s) {
  s.add(
      "Your pursuers reach you from behind and a sword pierces your chest "
      "with formidable power.",
      wholeSentence: true);
  w.updateActorById(playerId, (b) => b..hitpoints = 0);
  w.popSituationsUntil(RoomRoamingSituation.className, sim);
  w.popSituation(sim);
});

final escape_tunnel_earsplitting = EventCallback((c, sim, w, s) {
  s.add(
      "Ear-splitting shouts come from behind. You wheel around and see "
      "a body of orcs and goblins approaching at top speed, their "
      "swords and spears at the ready.",
      wholeSentence: true);
});

final escape_tunnel_halfway = EventCallback((c, sim, w, s) {
  s.add("The orcs and goblins are halfway here.", wholeSentence: true);
});

final escape_tunnel_insignificant = EventCallback((c, sim, w, s) {
  final built = w.build();
  final orc = getEscapeTunnelOrc(built);
  final goblin = getEscapeTunnelGoblin(built);
  final actor = orc.isAnimatedAndActive ? orc : goblin;
  final player = $(c).player;
  assert(actor.isAnimatedAndActive);
  assert(player.isAnimatedAndActive);
  final kicking = actor.currentWeapon == null ||
      (player.currentWeapon == null && player.currentShield == null);
  var assaultVerbing = kicking ? 'kicking' : 'slashing';
  var sounds =
      kicking ? ['Whoosh!', 'Swah!', 'Slam!'] : ['Swish!', 'Whoosh!', 'Thunk!'];
  actor.report(
      s,
      "<subject> start<s> wildly $assaultVerbing "
      "in your direction",
      positive: true);
  s.add(
      "\"Insignificant...\" ${sounds[0]} "
      "\"... little ...\" ${sounds[1]} "
      "\"... vermin!\" ${sounds[2]}",
      wholeSentence: true);
  var target = kicking
      ? ('knee')
      : (player.currentShield != null ? 'shield' : player.currentWeapon.name);
  s.add(
      "That last blow hits your $target hard"
      "${player.isOnGround ? '' : ' and sends you a couple of steps back'}.",
      wholeSentence: true);
  final eyes = Entity(name: "eyes", pronoun: Pronoun.THEY);
  s.add("<owner's> <subject> glint<s> with intensity",
      owner: actor, subject: eyes);
});

final escape_tunnel_look = EventCallback((c, sim, w, s) {
  final built = w.build();
  final orc = getEscapeTunnelOrc(built);
  final goblin = getEscapeTunnelGoblin(built);
  final player = $(c).player;
  if (bothAreAlive(orc, goblin)) {
    final actor = orc.isConfused ? goblin : orc;
    final otherActor = actor == orc ? goblin : orc;
    actor.report(
        s,
        "\"Look, Sgarr,\" <subject> say<s>. \"Look at them. "
        "Give a puny slave some steel and suddenly they think "
        "they're mighty slayers.\"",
        wholeSentence: true);
    otherActor.report(s, "<subject> laugh<s>");
    if (player.currentWeapon?.id == orcthorn.id) {
      otherActor.report(s, "<subject> stop<s> almost instantly", but: true);
      otherActor.report(s, "<subject> see<s> <object> in your hand.",
          object: player.currentWeapon, wholeSentence: true);
    }
  } else {
    final actor = orc.isAnimatedAndActive ? orc : goblin;
    assert(actor.isAnimatedAndActive);
    actor.report(
        s,
        "\"Look at you,\" <subject> laugh<s>. "
        "\"Give a puny slave some steel and suddenly you think "
        "you're mighty slayers.\"",
        wholeSentence: true);
    if (player.currentWeapon?.id == orcthorn.id) {
      actor.report(
          s,
          "But then <subject> see<s> <object> in your hand "
          "and his face hardens.",
          object: player.currentWeapon,
          but: true,
          wholeSentence: true);
    }
  }
});

final escape_tunnel_loud_cries = EventCallback((c, sim, w, s) {
  s.add(
      "From behind, you hear loud cries. Your pursuers must have reached "
      "the top of the stairs.",
      wholeSentence: true);
});

/// Gathers [EventCallback] instances from this file and puts them
/// into the `edgehead_event_callbacks_gather.gathered.dart` file.
@GatherInstancesFrom(['lib/edgehead_event_callbacks_gather.dart'])
final InstanceSerializer<EventCallback> eventCallbackSerializer =
    _$eventCallbackSerializer;

final mad_guardian_good = EventCallback((c, sim, w, s) {
  var guardian = w.getActorById(madGuardianId);
  guardian.report(
      s, "\"Good good good,\" <subject> whisper<s>, eyeing <object>.",
      object: $(c).player, wholeSentence: true);
});

final mad_guardian_pain = EventCallback((c, sim, w, s) {
  var guardian = w.getActorById(madGuardianId);
  var briana = w.getActorById(brianaId);
  s.addParagraph();
  guardian.report(s, "\"Pain is good,\" <subject> chuckle<s>.",
      wholeSentence: true);
  s.addParagraph();
  if (briana.isAnimatedAndActive) {
    briana.report(s, "<subject> glare<s> at him");
    briana.report(s, "\"Shut up and die.\"", wholeSentence: true);
    s.addParagraph();
  }
});

final mad_guardian_shut_up = EventCallback((c, sim, w, s) {
  var guardian = w.getActorById(madGuardianId);
  var player = $(c).player;
  s.addParagraph();
  guardian.report(
      s,
      "\"You'll make a nice addition to my collection,\" "
      "<subject> say<s>, laughing.",
      wholeSentence: true);
  guardian.report(
      s, "<subject> nod<s> towards the heap of rotting bodies nearby");
  s.addParagraph();
  player.report(s, "<subject> glance<s> over at Briana, then back at the orc.",
      wholeSentence: true);
  player.report(s, "_\"You had better shut up, and die.\"_",
      wholeSentence: true);
  s.addParagraph();
});

final slave_quarters_mean_nothing = EventCallback((c, sim, w, s) {
  final orc = getSlaveQuartersOrc(w);
  final goblin = getSlaveQuartersGoblin(w);
  final actor = orc.isAnimatedAndActive ? orc : goblin;
  actor.report(
      s,
      "\"You don't understand,\" <subject> growl<s>. "
      "\"No matter how many of us you kill, there will be more. "
      "And when we get you, we will eat your face alive.\"",
      wholeSentence: true);
  actor.report(s, "<subject> smirk<s>");
  actor.report(s, "\"You mean nothing.\"", wholeSentence: true);
});

final slave_quarters_orc_looks = EventCallback((c, sim, w, s) {
  final orc = getSlaveQuartersOrc(w);
  final goblin = getSlaveQuartersGoblin(w);
  if (!goblin.isAnimated) {
    orc.report(s, "<subject> look<s> at <object's> body", object: goblin);
    orc.report(s, "\"You'll pay for this, vermin,\" <subject> snarl<s>.",
        wholeSentence: true);
    return;
  }
  if (bothAreAlive(orc, goblin)) {
    orc.report(s, "<subject> look<s> at <object>", object: goblin);
    orc.report(
        s, "\"Now that is practice,\" <subject> say<s> to <objectPronoun>.",
        object: goblin, wholeSentence: true);
  }
});

final sleeping_goblin_thief = EventCallback((c, sim, w, s) {
  final goblin = w.getActorById(sleepingGoblinId);
  final player = $(c).player;
  final tookSpear =
      w.actionHasBeenPerformedSuccessfully("take_spear_in_underground_church");
  if (tookSpear) {
    goblin.report(s, "<subject> look<s> at <objectOwner's> <object>",
        objectOwner: player, object: sleepingGoblinsSpear);
    goblin.report(s, "\"Thief,\" <subject> hiss<es>.", wholeSentence: true);
  }
});

final start_make_goblin_not_invincible = EventCallback((c, sim, w, s) {
  w.updateActorById(firstGoblinId, (b) => b.isInvincible = false);
});

final start_tamara_bellows = EventCallback((c, sim, w, s) {
  var goblin = w.getActorById(firstGoblinId);
  goblin.report(s, "<subject> {smirk<s>|chuckle<s>}", positive: true);
  var tamara = w.getActorById(tamaraId);
  if (!tamara.isAnimatedAndActive ||
      tamara.isUndead ||
      tamara.anatomy.isBlind) {
    // The rest of this event doesn't make sense if Tamara can't see or talk.
    return;
  }
  s.addParagraph();
  tamara.report(s, "<subject> bellow<s> in {frustration|anger}");
  tamara.report(s, '"I hate this place."', wholeSentence: true);
  s.addParagraph();
});

final youre_dead_slave = EventCallback((c, sim, w, s) {
  var agruth = w.getActorById(agruthId);
  var sword = Item.weapon(w.randomInt(), WeaponType.sword);
  agruth.report(s, "<subject> {drop<s>|let<s> go of} the whip");
  agruth.report(s, "<subject> draw<s> <subject's> <object>", object: sword);
  w.updateActorById(agruthId, (b) => b..inventory.equip(sword, agruth.anatomy));
  agruth.report(
      s,
      "\"You're dead, slave,\" <subject> growl<s> at <object> "
      "with hatred.",
      object: $(c).player,
      wholeSentence: true);
});
