import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/anatomy/body_part.dart';
import 'package:edgehead/fractal_stories/item.dart';
import 'package:edgehead/fractal_stories/items/weapon_type.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/team.dart';
import 'package:test/test.dart';

void main() {
  test("simple storyline", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gorilla = Entity(
        name: "Gorilla",
        nameIsProperNoun: true,
        team: playerTeam,
        pronoun: Pronoun.IT);
    storyline.add(
        "The ship trembles. There is something wrong with the engines.",
        wholeSentence: true,
        time: 0);
    storyline.add("<subject> gesture<s> to <subject's> <object>",
        subject: player, object: gorilla, time: 1);
    storyline.add("<subject> nod<s> at <object>",
        subject: gorilla, object: player, time: 2);
    storyline.add("<subject> run<s> towards the engine room",
        subject: gorilla, time: 3);
    expect(
        storyline.realizeAsString(),
        matches("The ship trembles. There is something wrong with the "
            "engines. I gesture to Gorilla.+"
            "uns towards the engine room\."));
  });

  test('I am not', () {
    var storyline = Storyline();
    storyline.add("<subject> <isn't> fooled", subject: _createPlayer('Filip'));
    expect(storyline.realizeAsString(), contains('m not'));
    expect(storyline.realizeAsString(), isNot(contains('amn\'t')));
  });

  test("storyline.addParagraph", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gorilla = Entity(
        name: "Gorilla",
        nameIsProperNoun: true,
        team: playerTeam,
        pronoun: Pronoun.IT);
    storyline.add(
        "The ship trembles. There is something wrong with the engines.",
        wholeSentence: true);
    storyline.addParagraph();
    storyline.add("<subject> gesture<s> to <subject's> <object>",
        subject: player, object: gorilla);
    expect(storyline.realizeAsString(), contains("\n\n"));
  });

  test("fixing .\". in sentences", () {
    var storyline = Storyline();
    var gorilla = Entity(
        name: "Gorilla",
        nameIsProperNoun: true,
        team: playerTeam,
        pronoun: Pronoun.IT);
    storyline.add("<subject> enter<s> the room", subject: gorilla);
    storyline.add("<subject> say<s>: \"Isn't this great?\"",
        subject: gorilla, endSentence: true);
    expect(
        storyline.realizeAsString(), endsWith("says: \"Isn't this great?\""));
    storyline.clear();
    storyline.add("<subject> say<s>: \"Well, I think it's great.\"",
        subject: gorilla);
    expect(storyline.realizeAsString(),
        endsWith("says: \"Well, I think it's great.\""));
    storyline.clear();
    storyline.add("<subject> exclaim<s>: \"Well? Say something!\"",
        subject: gorilla);
    expect(storyline.realizeAsString(),
        endsWith("exclaims: \"Well? Say something!\""));
  });

  test("fixing .'. in sentences", () {
    var storyline = Storyline();
    var gorilla =
        Entity(name: "Gorilla", team: playerTeam, pronoun: Pronoun.IT);
    storyline.add("<subject> enter<s> the room", subject: gorilla);
    storyline.add("<subject> say<s>: 'Isn't this great?'",
        subject: gorilla, endSentence: true);
    expect(storyline.realizeAsString(), endsWith("says: 'Isn't this great?'"));
    storyline.clear();
    storyline.add("<subject> say<s>: 'Well, I think it's great.'",
        subject: gorilla);
    expect(storyline.realizeAsString(),
        endsWith("says: 'Well, I think it's great.'"));
    storyline.clear();
    storyline.add("<subject> exclaim<s>: 'Well? Say something!'",
        subject: gorilla);
    expect(storyline.realizeAsString(),
        endsWith("exclaims: 'Well? Say something!'"));
  });

  test("exchange", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var enemy =
        Entity(name: "enemy", team: defaultEnemyTeam, pronoun: Pronoun.HE);
    storyline.add("<subject> tr<ies> to hit <object> in the stomach",
        subject: player, object: enemy, time: 1);
    storyline.add("<subject> dodge<s> <object's> strike",
        subject: enemy, object: player, but: true, time: 2);
    storyline.add("<subject> hit<s> back",
        subject: enemy, positive: true, time: 3);
    storyline.add("<subject> break<s> <object's> nose",
        subject: enemy, object: player, positive: true, time: 4);
    expect(
        storyline.realizeAsString(),
        matches("I try to hit the enemy in the stomach.+ he dodges my strike. "
            "He hits back.+ breaks my nose."));
  });

  test("substitute pronouns where proper ('he gives him the money')", () {
    var storyline = Storyline();
    var enemy = Entity(
        name: "John",
        nameIsProperNoun: true,
        team: Team((b) => b..id = 3),
        pronoun: Pronoun.HE);
    var enemy2 = Entity(
        name: "Jack",
        nameIsProperNoun: true,
        team: Team((b) => b..id = 4),
        pronoun: Pronoun.HE);
    storyline.add("<subject> meet<s> <object> at the station",
        subject: enemy, object: enemy2);
    storyline.add("<subject> give<s> <object> the money",
        subject: enemy, object: enemy2);
    expect(
        storyline.realizeAsString(),
        matches("John meets Jack at the station.+"
            "gives him the money."));
  });

  test("don't substitute pronouns where confusing ('it hits it')", () {
    var storyline = Storyline();
    var kid =
        Entity(name: "kid", team: Team((b) => b..id = 3), pronoun: Pronoun.IT);
    var toy =
        Entity(name: "toy", team: Team((b) => b..id = 4), pronoun: Pronoun.IT);
    storyline.add("<subject> find<s> <object>", subject: kid, object: toy);
    storyline.add("<subject> lose<s> <object> again",
        subject: kid, object: toy, but: true);
    expect(storyline.realizeAsString().indexOf("it loses it"), -1);
  });

  test("ignore <owner's> when owner is null", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gun =
        Entity(name: "front laser", team: playerTeam, pronoun: Pronoun.IT);

    storyline.add("<subject> start<s> programming <owner's> <object> to fire",
        subject: player, object: gun);
    expect(storyline.realizeAsString(), isNot(matches("<owner's>")));
  });

  test(
      "ignoring <owner's> at start of sentence doesn't screw up capitalization",
      () {
    var storyline = Storyline();
    var hull = Entity(name: "hull", team: playerTeam, pronoun: Pronoun.IT);

    storyline.add("<owner's> <subject> explode<s>", subject: hull);
    expect(storyline.realizeAsString(), matches("The hull.+"));
  });

  test("don't substitute pronoun when it was used in the same form", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gun =
        Entity(name: "front laser", team: playerTeam, pronoun: Pronoun.IT);
    var enemy =
        Entity(name: "ship", team: defaultEnemyTeam, pronoun: Pronoun.IT);
    storyline.add("<subject> start<s> programming <object> to fire",
        subject: player, object: gun);
    storyline.add("<subject> go<es> wide of <object>",
        subject: player, object: enemy);
    expect(storyline.realizeAsString().indexOf("wide of it"), -1);
  });

  test("add 'the' to common nouns (default for every Entity)", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var apple = Entity(name: "apple", pronoun: Pronoun.IT);
    storyline.add("<subject> pick<s> up <object>",
        subject: player, object: apple);
    expect(storyline.realizeAsString(), matches("I pick up the apple."));
  });

  test("don't use <owner's> to pronoun", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var ship = Entity(name: "Haijing", pronoun: Pronoun.IT);
    var part = Entity(name: "main jet", pronoun: Pronoun.IT);
    storyline.add("<subject> hit<s> <object>", subject: player, object: part);
    storyline.add("<owner's> <subject> <is> damaged heavily",
        subject: part, owner: ship);
    expect(storyline.realizeAsString().indexOf("Haijing's it"), -1);
  });

  test("put 'and' between two sentences in a complex sentence", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gun = Entity(name: "front laser", pronoun: Pronoun.IT);
    var ship = Entity(name: "Haijing", pronoun: Pronoun.IT);
    storyline.add("<subject> take<s> hold of <object's> controls",
        subject: player, object: gun, time: 1);
    storyline.add("<subject> begin<s> to aim at <object>",
        subject: player, object: ship, time: 1);
    storyline.add("<subject> go<es> wide of <object>",
        subject: player, object: ship, time: 10);
    expect(
        storyline.realizeAsString(),
        matches("I take hold of the front laser's controls,? "
            "and begin to aim at the Haijing\..+"));
  });

  test("possessive", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gun = Entity(name: "gun", team: playerTeam, pronoun: Pronoun.IT);
    var enemy =
        Entity(name: "enemy", team: defaultEnemyTeam, pronoun: Pronoun.HE);
    storyline.add("<owner's> <subject> <is> pointed at <object>",
        owner: player, subject: gun, object: enemy, time: 1);
    storyline.add("<subject> fire<s>", subject: gun, time: 2);
    expect(storyline.realizeAsString(),
        matches("My gun is pointed at the enemy.+t fires."));

    storyline.clear();
    var ship =
        Entity(name: "ship", team: defaultEnemyTeam, pronoun: Pronoun.SHE);
    storyline.add("<owner's> <subject> aim<s> <subject's> guns at <object>",
        owner: enemy, subject: ship, object: player);
    storyline.add("<owner's> <subject> <is> faster",
        owner: player, subject: gun, but: true);
    expect(storyline.realizeAsString(),
        matches("The enemy's ship aims her guns at me.+ my gun is faster."));
  });

  test("possesive particles works even with <objectOwner's> <object>", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var gun = Entity(name: "gun", team: playerTeam, pronoun: Pronoun.IT);
    var enemy =
        Entity(name: "enemy", team: defaultEnemyTeam, pronoun: Pronoun.HE);
    storyline.add(
        "<owner's> <subject> <is> pointed at <objectOwner's> "
        "<object>",
        owner: player,
        subject: gun,
        object: enemy,
        time: 1);
    storyline.add("<subject> fire<s>", subject: gun, time: 2);
    expect(storyline.realizeAsString(),
        matches("My gun is pointed at *the enemy.+t fires."));
  });

  test("we don't show 'my the sword' even if Randomly is involved", () {
    var storyline = Storyline();
    var player = _createPlayer("Filip");
    var sword = Entity(name: "sword", pronoun: Pronoun.IT);
    var orc = Entity(name: "orc", team: defaultEnemyTeam, pronoun: Pronoun.HE);
    storyline.add("<subject> pound<s> on <objectOwner's> {<object>|<object>!}",
        subject: orc, objectOwner: player, object: sword);
    expect(storyline.realizeAsString(), matches("The orc pounds on my sword."));
  });

  group("possessive pronoun", () {
    Storyline storyline;
    Entity player;
    Entity dog;
    const String template = "<subject> unleash<es> <subject's> <object>";

    setUp(() {
      storyline = Storyline();
      player = _createPlayer("Filip");
    });

    test("do show with common nouns", () {
      dog = Entity(name: "dog", pronoun: Pronoun.IT);
      storyline.add(template, subject: player, object: dog);
      expect(storyline.realizeAsString(), contains("my dog"));
    });

    test("don't show with proper nouns", () {
      dog = Entity(name: "Buster", nameIsProperNoun: true, pronoun: Pronoun.IT);
      storyline.add(template, subject: player, object: dog);
      expect(storyline.realizeAsString(), isNot(contains("my Buster")));
    });
  });

  group('vs definitive article (no \'his the scimitar\')', () {
    Storyline storyline;
    Entity orc, sword;

    setUp(() {
      storyline = Storyline();
      orc = Entity(name: "orc", pronoun: Pronoun.HE);
      sword = Entity(name: "scimitar");
    });

    test("for <subject's> <object>", () {
      orc.report(storyline, "<subject> draw<s> <subject's> <object>",
          object: sword);
      expect(storyline.realizeAsString(), isNot(matches("his the scimitar")));
    });

    test("for <subject's> <object2>", () {
      orc.report(storyline, "<subject> draw<s> <subject's> <object2>",
          object2: sword);
      expect(storyline.realizeAsString(), isNot(matches("his the scimitar")));
    });

    test("for <object's> <object2>", () {
      var goblin = Entity(name: "goblin");
      orc.report(storyline, "<subject> draw<s> <object's> <object2>",
          object: goblin, object2: sword);
      expect(storyline.realizeAsString(), isNot(matches("his the scimitar")));
    });

    test("for <object2> pronoun ('verbs the it')", () {
      var goblin = Entity(name: "goblin");
      var vees = Entity(name: "Vees", nameIsProperNoun: true);
      var spear = Entity(name: "spear");
      var shield = Entity(name: "shield");
      goblin.report(storyline, "<subject> cast<s> <object2> at <object>",
          object: vees, object2: spear);
      vees.report(
          storyline,
          "<subject> stop<s> <object> "
          "with <object2>",
          object: spear,
          object2: shield);
      expect(storyline.realizeAsString(), isNot(matches("the it")));
      expect(storyline.realizeAsString(), matches("stops it"));
    });
  });

  test(
      "we don't make subsequent <object> a pronoun when the first instance "
      "is actually a Randomly option", () {
    var player = _createPlayer("Filip");
    var orc = Entity(name: "orc", team: defaultEnemyTeam, pronoun: Pronoun.HE);
    for (int i = 0; i < 1000; i++) {
      var storyline = Storyline();
      storyline.add(
          "<subject> {punch<es> <object> in the eye|"
          "punch<es> <object's> eye}",
          subject: player,
          object: orc);
      expect(storyline.realizeAsString(), isNot(contains("his eye")));
    }
  });

  test("first paragraph", () {
    var storyline = Storyline();
    storyline.add("this is some lorem ipsum");
    storyline.add("and it doesn't make much sense");
    storyline.addParagraph();
    storyline.add("but it has two paragraphs");

    expect(storyline.hasManyParagraphs, isTrue);
    expect(storyline.realizeAsString(), contains("has two paragraphs"));
    expect(storyline.realizeAsString(onlyFirstParagraph: true),
        isNot(contains("has two paragraphs")));

    storyline.removeFirstParagraph();
    expect(storyline.hasManyParagraphs, isFalse);
    expect(storyline.realizeAsString(), isNot(contains("lorem ipsum")));
    expect(storyline.realizeAsString(), contains("has two paragraphs"));
  });

  test("nice flow ('briana stands up, orc swings at her')", () {
    var storyline = Storyline();
    var briana =
        Entity(name: "Briana", nameIsProperNoun: true, pronoun: Pronoun.SHE);
    var orc = Entity(name: "orc", pronoun: Pronoun.HE);
    storyline.add("<subject> stand<s> up", subject: briana);
    storyline.add("<subject> swing<s> at <object>",
        subject: orc, object: briana);

    expect(storyline.realizeAsString(), contains("swings at her"));
  });

  test("definitive (the) article after first use", () {
    var storyline = Storyline();
    Entity sword = Entity(name: "sword");
    storyline.markEntityAsUnmentioned(sword);
    Entity shield = Entity(name: "shield");
    storyline.markEntityAsUnmentioned(shield);

    storyline.add("<subject> l<ies> on the table", subject: sword, time: 0);
    storyline.add("<subject> <is> propped up on the wall next to it",
        subject: shield, time: 1);
    storyline.add("<subject> <is> rusty", subject: sword, time: 3);

    var first = storyline.realizeAsString();

    expect(first, startsWith("A sword lies"));
    expect(first, contains("The sword is rusty"));

    var second = storyline.realizeAsString();

    expect(second, startsWith("A sword lies"));
    expect(second, contains("The sword is rusty"));
  });

  test("'they bite' (not bites)", () {
    var storyline = Storyline();
    var enemy = Actor.initialized(42, "Tamara", nameIsProperNoun: true);

    storyline.add("<owner's> <subject> {snap<s> at|bite<s>} empty air",
        subject: enemy.anatomy.findByDesignation(BodyPartDesignation.teeth),
        owner: enemy);
    expect(
        storyline.realizeAsString(),
        isIn([
          "Tamara's teeth bite empty air.",
          "Tamara's teeth snap at empty air."
        ]));
  });

  test("he has his dagger and his shield", () {
    var storyline = Storyline();
    var a = Actor.initialized(42, 'Leroy',
        nameIsProperNoun: true, pronoun: Pronoun.HE);
    var npc = a.rebuild((b) => b
      ..inventory.equip(Item.weapon(50, WeaponType.dagger), a.anatomy)
      ..inventory.currentShield = Item.weapon(60, WeaponType.shield));

    npc.report(storyline, "<subject> <has> <subjectPronoun's> <object>",
        object: npc.currentWeapon);
    npc.report(storyline, "<subject> <has> <subjectPronoun's> <object>",
        object: npc.currentShield);

    final result = storyline.realizeAsString();
    expect(result, contains("Leroy has his dagger"));
    expect(result, isNot(contains("and has his shield.")));
    expect(result, contains("and his shield"));
  });

  group("enumeration", () {
    Storyline storyline;
    Entity handkerchief = Entity(name: "handkerchief");
    Entity brush = Entity(name: "brush");
    Entity mirror = Entity(name: "mirror");
    Entity lipstick = Entity(name: "lipstick");
    Entity crateOfTnt = Entity(name: "crate of TNT");

    setUp(() {
      storyline = Storyline();

      // Make all entities unmentioned.
      storyline.markEntityAsUnmentioned(handkerchief);
      storyline.markEntityAsUnmentioned(brush);
      storyline.markEntityAsUnmentioned(mirror);
      storyline.markEntityAsUnmentioned(lipstick);
      storyline.markEntityAsUnmentioned(crateOfTnt);
    });

    test('throws with no elements', () {
      expect(() => storyline.addEnumeration("you see", [], "here"),
          throwsArgumentError);
    });

    test('one element', () {
      storyline.addEnumeration("you see", [handkerchief], "here");
      expect(
          storyline.realizeAsString(), matches("You see a handkerchief here."));
    });

    test('two elements', () {
      storyline.addEnumeration("you see", [handkerchief, brush], "here");
      expect(storyline.realizeAsString(),
          matches("You see a handkerchief and a brush here."));
    });

    test('three elements', () {
      storyline.addEnumeration(
          "you see", [handkerchief, brush, mirror], "here");
      expect(storyline.realizeAsString(),
          matches("You see a handkerchief, a brush, and a mirror here."));
    });

    test('four elements', () {
      storyline.addEnumeration(
          "you see", [handkerchief, brush, mirror, lipstick], "here");
      expect(
          storyline.realizeAsString(),
          matches("You see a handkerchief, a brush, and a mirror here. "
              "You see a lipstick here."));
    });

    test('five elements', () {
      storyline.addEnumeration("you see",
          [handkerchief, brush, mirror, lipstick, crateOfTnt], "here");
      expect(
          storyline.realizeAsString(),
          matches("You see a handkerchief, a brush, and a mirror here. "
              "You see a lipstick and a crate of TNT here."));
    });

    test('five elements and <also>', () {
      storyline.addEnumeration("you <also> see",
          [handkerchief, brush, mirror, lipstick, crateOfTnt], "here");
      expect(
          storyline.realizeAsString(),
          matches("You see a handkerchief, a brush, and a mirror here. "
              "You also see a lipstick and a crate of TNT here."));
    });

    test('five elements, <also>, and no end', () {
      storyline.addEnumeration("you <also> see",
          [handkerchief, brush, mirror, lipstick, crateOfTnt], null);
      expect(
          storyline.realizeAsString(),
          matches("You see a handkerchief, a brush, and a mirror. "
              "You also see a lipstick and a crate of TNT."));
    });

    test('implicit entity', () {
      storyline.addEnumeration(
          "", [handkerchief, brush, mirror, lipstick], "<is> <also> here");
      expect(
          storyline.realizeAsString(),
          matches("A handkerchief, a brush, and a mirror are here. "
              "A lipstick is also here."));
    });
  });

  group("actionThread", () {
    Storyline storyline;
    var threadA = 42;

    setUp(() {
      storyline = Storyline();
    });

    test("summary doesn't show when thread is broken", () {
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("a dog walks by");
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("you kill the duck",
          actionThread: threadA, replacesThread: true);
      expect(storyline.realizeAsString(), contains("aim at the sky"));
      expect(storyline.realizeAsString(), contains("shoot the duck"));
      expect(storyline.realizeAsString(), isNot(contains("kill the duck")));
    });

    test("thread is shown even when thread is broken (no summary)", () {
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("someone calls you by name");
      expect(storyline.realizeAsString(), contains("aim at the sky"));
      expect(storyline.realizeAsString(), contains("shoot the duck"));
      expect(storyline.realizeAsString(), contains("calls you by name"));
    });

    test("summary doesn't show when start is missing", () {
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("you kill the duck",
          actionThread: threadA, replacesThread: true);
      expect(storyline.realizeAsString(), contains("shoot the duck"));
      expect(storyline.realizeAsString(), isNot(contains("kill the duck")));
    });

    test("summary replaces unbroken thread", () {
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("you kill the duck",
          actionThread: threadA, replacesThread: true);
      expect(storyline.realizeAsString(), isNot(contains("aim at the sky")));
      expect(storyline.realizeAsString(), contains("kill the duck"));
    });

    test("summary replaces unbroken thread but leaves leading non-thread be",
        () {
      storyline.add("things are going great");
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("you kill the duck",
          actionThread: threadA, replacesThread: true);
      expect(storyline.realizeAsString(), contains("going great"));
      expect(storyline.realizeAsString(), isNot(contains("aim at the sky")));
      expect(storyline.realizeAsString(), contains("kill the duck"));
    });

    test(
        "not shown supportive actions don't influence making subjects "
        "into pronouns in summary", () {
      var storyline = Storyline();
      var player = _createPlayer("Filip");
      var enemy =
          Entity(name: "orc", team: defaultEnemyTeam, pronoun: Pronoun.HE);
      storyline.add("<subject> aim<s> at <object>",
          subject: player,
          object: enemy,
          actionThread: threadA,
          startsThread: true);
      storyline.add("<subject> shoot<s> <object>",
          subject: player, object: enemy, actionThread: threadA);
      storyline.add("<subject> shoot<s> <object>",
          subject: player,
          object: enemy,
          actionThread: threadA,
          replacesThread: true);
      expect(storyline.realizeAsString(), "I shoot the orc.");
    });

    test("summary doesn't affect following reports", () {
      var threadB = 12345;
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("you kill the duck",
          actionThread: threadA, replacesThread: true);
      storyline.add("a dog barks at me",
          actionThread: threadB, startsThread: true);
      storyline.add("but I ignore it", actionThread: threadB);
      expect(storyline.realizeAsString(), isNot(contains("aim at the sky")));
      expect(storyline.realizeAsString(), contains("kill the duck"));
      expect(storyline.realizeAsString(), contains("dog barks at me"));
      expect(storyline.realizeAsString(), contains("I ignore it"));
    });

    test("throws when multiple starting action reports are together", () {
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("you look through the scopes",
          actionThread: threadA, startsThread: true);
      storyline.add("you shoot the duck", actionThread: threadA);
      expect(() => storyline.realizeAsString(), throwsStateError);
    });

    test("prints all summary action reports when together", () {
      storyline.add("you aim at the sky",
          actionThread: threadA, startsThread: true);
      storyline.add("you look through the scopes", actionThread: threadA);
      storyline.add("you shoot the duck", actionThread: threadA);
      storyline.add("the duck dies", actionThread: threadA);
      storyline.add("you shoot the duck",
          actionThread: threadA, replacesThread: true);
      storyline.add("and kill it", actionThread: threadA, replacesThread: true);
      expect(storyline.realizeAsString(), contains("shoot the duck"));
      expect(storyline.realizeAsString(), contains("kill it"));
    });
  });

  group('second object', () {
    Storyline storyline;
    Entity player;
    Entity rock;
    Entity goblin;

    setUp(() {
      storyline = Storyline();
      player = _createPlayer('Filip');
      rock = Entity(name: 'rock');
      goblin =
          Entity(name: 'goblin', pronoun: Pronoun.HE, team: defaultEnemyTeam);
    });

    test('is extracted', () {
      storyline.add("<subject> hit<s> <object> with <object2>",
          subject: player, object: goblin, object2: rock);
      expect(storyline.realizeAsString(), "I hit the goblin with the rock.");
    });

    test('makes pronouns', () {
      storyline.add("<subject> pick<s> up <object>",
          subject: player, object: rock);
      storyline.add("<subject> hit<s> <object> with <object2>",
          subject: player, object: goblin, object2: rock);
      var realized = storyline.realizeAsString();
      expect(realized, contains("I pick up the rock"));
      expect(realized, contains("hit the goblin with it"));
    });

    group('make pronouns even with two Pronoun.IT when not confusing', () {
      test('object2 stays object2', () {
        storyline.add(
            "<subject> throw<s> <subjectPronounSelf> at <object> "
            "with <object2>",
            subject: player,
            object: goblin,
            object2: rock);
        storyline.add("<subject> hit<s> <object> back with <object2>",
            subject: goblin, object: player, object2: rock);
        var realized = storyline.realizeAsString();
        expect(
            realized, contains("I throw myself at the goblin with the rock"));
        expect(realized, contains("hits me back with it"));
      });

      test('object becomes object2', () {
        final Entity statue = Entity(name: 'statue');
        storyline.add("<subject> pick<s> up <object>",
            subject: player, object: rock);
        storyline.add("<subject> hit<s> <object> with <object2>",
            subject: player, object: statue, object2: rock);
        var realized = storyline.realizeAsString();
        expect(realized, contains("I pick up the rock"));
        expect(realized, contains("hit the statue with it"));
      });

      test('object2 becomes object', () {
        storyline.add("<subject> cast<s> <object2> at <object>",
            subject: player, object: goblin, object2: rock);
        storyline.add("<subject> move<s> out of <object's> way",
            subject: goblin, object: rock);
        var realized = storyline.realizeAsString();
        expect(realized, contains("I cast the rock at the goblin"));
        expect(realized, contains("moves out of its way"));
      });
    });

    test('doesn\'t make pronouns when confusing', () {
      var statue = Entity(name: 'statue');

      storyline.add("<subject> examine<s> <object>",
          subject: player, object: statue);
      storyline.add("<subject> hit<s> <object> with <object2>",
          subject: player, object: statue, object2: rock);
      var realized = storyline.realizeAsString();
      expect(realized, contains("I examine the statue"));
      expect(realized, contains("hit it with the rock"));
    });
  });
}

Entity _createPlayer(String name) =>
    Entity(name: name, pronoun: Pronoun.I, team: playerTeam, isPlayer: true);
