# Suspense Escape Room

* I worked on this project as part of the 1UP internship scheme with Staffordshire University.
* Over 6 weeks, we utilised Unreal Engine for Fortnite (UEFN) to create this project.

## Project Summary

* The core gameplay loop has players exploring a house and labs, exploring and solving puzzles that unlock new rooms and hidden passages.
* Players are equipped with a flashlight, which can be used to freeze fungi folk NPCs in place. Shining the light directly at them stops their movement and renders them petrified. Certain environmental lights throughout the level can also immobilise these creatures when they step into illuminated areas.
* Instead of being a direct threat, the fungi folk act as a persistent hindrance by interfering with puzzle elements, forcing players to adapt their puzzle-solving strategies as they navigate the environment.

## My Role & Key Skills

* As a programmer, my role prioritised the use of the Verse programming language in prototyping and implementing puzzle mechanics.
* Currently, Verse is exclusive to UEFN, allowing me to stretch my skillset by acclimating to a new language efficiently.

# Highlights

## NPCs interfering with puzzles

* NEEED TO COMPLETE

[Verse Files](AI)

---

* [Murgn](https://github.com/Murgn) is responsible for creating the AI functionality, however I included some of the behaviour files here as well, since some of the interaction scripts I made derive from those scripts, so I included them for context.
* This is also the same for the ```pipe_rotator_device```, which was developed on by [Georgez05](https://github.com/Georgez05), and someone from a previous year at the internship, GURKIS.
  
### Video

VIDEOO HERE

## Pouring gas to fill a generator

* This puzzle involved finding 3 gas cans to fill up a generator in order to open a locked gate.
* The simplest solution was to use a Conditional Button Device to receive 3 gas cans and trigger the gate, however, I opted for implementing a more interactive approach to solving the puzzle.
* While in the area around the generator, holding the right mouse button will trigger a pouring sequence, where a Verse class keeps track of how long the button has been held down in order to track the amount of poured fuel. After a gas can has been emptied out, the item is removed from the player's inventory, and a new gas can must be used in order to continue pouring.
* Once the generator has reached maximum capacity (when all 3 gas cans have been emptied), the gate is triggered to swing open.
* Unfortunately, due to bugs, the simpler approach was used instead.

[Verse Files](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/Gas_Generator)

### Video:

* The video displays debug logs being printed on the left side of the screen, which indicates the amount each gas can has been poured, and then the fill amount of the generator.

[![Pouring Gas](https://img.youtube.com/vi/_aNqz2TitNE/0.jpg)](https://youtu.be/_aNqz2TitNE)


## First person throwables

* Initially, many puzzles were designed to make use of throwable items to destroy obastacles in order to access a key item or as bait in order to lure the fungi folk NPCs to a target location. A large issue we ran into is that the game has a first person camera, however many of UEFN's custom carryables/throwable items force the player back into third person. The camera shift can be extremely immersion breaking, which is signficant in a suspense based experience.
* The method that me and another teammate, [Murgn](https://github.com/Murgn), worked on together was spawning a prop in front of the player on right mouse click, and then teleporting the prop away in the direction the player is facing to create a throwing effect. This workaround allows for a throwing effect that also accomodates the first person perspective.
* The player picks up a placeholder Fortnite item, which is promptly removed from the inventory, and information about the number of items that can be thrown is stored by the Verse class.
* Unfortunately, the puzzle elements involving throwing and destroying obstacles were removed; the fungi lures still make use of the same system, however it's designed more on dropping the item in front of the player, rather than throwing it.

[Verse Files](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/FP_Throwing)

---

* A key issue with this mechanic is that the projectile technically doesn't have collision, since it doesn't use physics and simply teleports in the correct trajectory, so [Murgn](https://github.com/Murgn) made a manual AABB collider to detect collisions from throwables. Although I didn't make this, these scripts were what we ended up using going forward, so I've included the files for better context.

[Verse Files For Murgn's AABB Collider & Lure device](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/FP_Throwing/Murgn)

### Video:

* The first clip shows my first prototype of the first person throwing mechanic, where a grey cube is launched in the direction the player faces after a key item is picked up and removed from the inventory.
* The second clip shows the final product, where the bait item is dropped onto the floor.

[![First Person Throwable](https://img.youtube.com/vi/uXxPJq5v_kg/0.jpg)](https://youtu.be/uXxPJq5v_kg)

## Hitting moving targets in first person

* One of the puzzles that involved a throwable item (before being scrapped) was hitting a target to trigger something. Developing on this, I also worked moving targets that all need to be hit in order to trigger something.
* This makes use of the first person throwing I mentioned in the previous section, and the AABB collider made by [Murgn](https://github.com/Murgn). It also makes use of UEFN's Prop Mover device to create the ping pong effect of the colliders moving back and forth.
* One annoying struggle with this was that prop mover's can only move one object at time, no matter if they're overlayed or referenced, as a result, having moving targets props with the moving colliders required a Prop Mover device for each collider and prop, which was a bit more tedious.

[Verse Files](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/FP_Throwing/Targets)

### Video:

[![Moving Targets & FP Throwables](https://img.youtube.com/vi/P_7NEXqosyM/0.jpg)](https://youtu.be/P_7NEXqosyM)


## Skilled Interactions

* After the throwables were scrapped, puzzle design shifted gear to focus more on the use of UEFN's Skilled Interactions device, which creates a lockpicking effect.
* Players use lockping on chests to reveal key items required to progress. As the items were granted to the player using Prop Placer devices, they didn't have any functionality to be enabled/disabled during run-time, so it required me to make a script to teleport the key item in front of the chest once it had been unlocked.
* There was also an odd bug that caused the prop placer items to 'ghost' respawn, the prop placer had been set to not respawn, though for some reason the model would sometimes still respawn without function. As a result, I also made a small Verse class to hide the Prop Placers underground after granting the item, in case the model did respawn.

[Verse Files](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/Skilled_Interactions)

### Video:

* The first clip shows the player unlocking a chest to reveal a key to unlock the house's door, and the second clip shows the same process but to reveal a gas can required to fuel the generator and open a gate.
  
[![Skilled Interactions & Triggering Items](https://img.youtube.com/vi/xSpXnkcCkFg/0.jpg)](https://youtu.be/xSpXnkcCkFg)

## Button & switch sequences

* Using an array of buttons, I made a Verse class that creates a sequence that the buttons must be hit in based on the index that the buttons are put into the array. I also included an option to shuffle the order of the sequence as well, so that it doesn't have to be predetermined by the user.
* The ```button_sequence_any``` script is a child of the base class and accepts the buttons to be hit in any order, only checking if all of the buttons have been hit to trigger something.
* For a different puzzle, involving a fungus NPC, I used ```switch_sequence_any``` instead, since it stores the state of being on or off (while buttons do the same thing, they cannot be toggled back to their 'off' state). This was used to trigger a door opening or closing based on the state of the switch.

[Verse Files](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/Buttons_And_Switches)

### Video:

* The video shows the same Verse class functioning in a separate test world, which explains the completely different environment.
* In the top left corner the debug logs displaying whether the pressed button is the correct one to press in the sequence, and if the sequence has been completed.

[![Opening Locked Doors](https://img.youtube.com/vi/4GRfuu8Wl7s/0.jpg)](https://youtu.be/4GRfuu8Wl7s)

## Ray and Sphere Casting

* While attempting to create sight detection, that would've been used for the flashlight to freeze the NPC fungi, I made use of both ray casting and sphere casting. They shoot from the player's position out in the direction the player faces, and can either stop after the first hit, or continue a set distance to detect multiple things overlapping. The sphere cast allows for a larger hit detection for greater allowance when trying to detect something.
* The hit sweep also has the ability to detect whether it's hitting a specific mesh.
* I also attempted using casting when creating the first person throwables, by having the cast track the movement of the thrown projectile, I intended it to detect when it collided with another object like the ground. Although, this didn't end up working, as it wasn't detecting specific meshes that I was testing - I could also see how in the future, it would cause issues due to the numerous different props used for the environment, that I would have had to manually check for.

[Verse Files](https://github.com/lucky-losingdogs/1UP-UEFN-Horror/tree/main/Casting)

### Video:

* The video shows the same Verse class functioning in a separate test world, which explains the completely different environment.
* When hitting the grey cube, a debug log is printed in the top left showing that the cube has been hit by the cast.

[![Raycasts & Detecting Meshes](https://img.youtube.com/vi/SJ7zxkD4XN0/0.jpg)](https://youtu.be/SJ7zxkD4XN0)

[![Spherecasts](https://img.youtube.com/vi/GLck9fJS4ME/0.jpg)](https://youtu.be/GLck9fJS4ME)
