## GodMon
A Pokemon-like sample game project.

This is very much a work in progress, so expect many bugs and missing features.

### Assets
Credit to Kenney and their awesome [assets](https://www.kenney.nl/) and credit to isaiah658 for their awesome [monster pack](https://opengameart.org/content/50-monsters-pack-2d).

I've extended the tilemaps and made some sprites myself too, you'll know which ones, they look awful!

### Addons
* [GUT](https://github.com/bitwes/Gut/) for tests. Not updated to Godot 4.4 yet.
* [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) for most of the dialogue in the game.

### What's done so far
* Player movement: walking, turning, running and jumping
* Map loading:
  * Chunk system to load and unload adjacent maps
  * Transition to other maps
  * Transition within a same map (stairs)
* Party screen
* Wild encounters
* Battles are playable from start to finish but there's a lot of stuff missing. See the section below.

### What's missing
Too much to list but most notably:
* Items
* Battle:
  * A lot of moves, mostly complex ones like Substitute, Counter, etc.
  * A lot of abilities
  * Weather
  * Animations
  * Trainer battles
  * Improved switching on Double and Triple battles
  * Shifting on Triple battles
  * EXP and Money rewards
* Menus
  * Trainer card
  * Pokedex
  * Pokemon summary
* And much more...

### Notes
* You can press 'Backspace' to turn on speed up. Press it again to go back to normal speed.
* When you turn too fast, the character gets stuck and can't move anymore. Press 'cancel' (X) and a direction to move again.
* As mentioned before, this is a work in progress, expect a lot of bugs.
* The 'Constants' singleton is huge. It'll be split at some point.
