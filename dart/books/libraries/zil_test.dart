import 'package:unittest/unittest.dart';
import 'package:egamebook/src/book/scripter.dart';
import 'zil.dart';
import 'storyline.dart';


void main() {
  test("ZIL works", () {
    
    // Init
    var captainsGun = new Item("captain's gun", 
        [
         new Action("check the gun", 
            () => echo("You check the gun. It's okay."),
            roomCheck: (room) => room.lit,
            performerCheck: (actor) => actor.isHuman,
            //targetActorCheck: (targetCandidate) => true,
            //targetItemCheck: (targetCandidate) => true,
            itemCheck: (item) => item.isActive,
            needsToBeCarried: true,
            submenu: "...")
         ],
      takeable: true,
      count: 1,  // can be >1 for things like bullets
      container: true,
      contents: []
    );
    var bridge = rooms.add(new Room("Exploration.Bridge", // corresponds to pagename
        "the bridge",
        [new Exit("LeftCorridor"), 
         new Exit("Hatchway", requirement: () => player.isAlive)],
         //onEnter: () { /* Room function (on enter?) */ echo },
         //globalBitsOverride: {hearablePA: true, loudEnviron: false},
         coordinates: [0, 0, 0],
         items: [captainsGun]
    ));
    var leftCorridor = rooms.add(new Room("LeftCorridor",
        "Left Corridor",
        [new Exit("Exploration.Bridge")],
        coordinates: [1, 1, 0]
    ));
    rooms.add(new Room("Hatchway", "the hatchway", []));
    
    var gorilla = actors.add(new AIActor("Gorilla", pronoun: Pronoun.HE), bridge);
    gorilla.currentGoal = new ArbitrarySetOfGoals(gorilla, 
        [new TestPickUpAndComment(gorilla, captainsGun),
         new GoToRoom(gorilla, leftCorridor),
         new GoToRoom(gorilla, bridge),
         new Say(gorilla, "Hi again!")]);
    
    
    // Script
    // npcs.update(1);
    // rooms.update(1);
    // ^^^ = zil.update(1);
    
    player.location = bridge;
    rooms.setCurrentFromPageName("Exploration.Bridge");
    
    rooms.current.describe(10);
    // rooms.current.showArrival();  // "You have arrived to the bridge."
    // rooms.current.showDescription();  // "You are standing at the bridge."
    // npcs.showIn(rooms.current);  // "Gorilla is here. He sits on the floor." / He carries ___. Heading towards ...
    //rooms.current.showItems();  // "The captain's gun is here."
    // rooms.current.showExits();
    
    // Needed in debug only.
    print(storyline.toString());
    
    // zil.showChoices();
  });
  
  // EXAMPLE
  // aiActors.update(); // something like that?
  // rooms.setCurrentFromPageName(currentPageName);
  // rooms.current.showText();  // "You are standing in the cargo bay. There's a steel bar on the ground here."
                                // "Gorilla is walking through here. He's heading to the hatch Corridor Left."
  // timeline.time++;           // "Through the PA, you hear ..." 
  
  // rooms.current.showChoices();  // Run this in a separate script block!
}