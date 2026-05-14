lab04 - Model import, animations, audio and particle effects (Godot 4)
=======================================================================

What this project covers
------------------------
Built on top of lab02 (FPS/TPS controller). On top of the existing
movement, sprint, jump, crouch and FPS/TPS toggle, this lab04 adds:

  - A procedural humanoid model (head, torso, two arms, two legs)
    built from Godot primitive meshes so no external 3D file is needed
  - An AnimationPlayer with these animations, built at runtime:
        idle, walk, run, jump, fall, crouch_idle, attack
  - Animation Events (method tracks) that call _on_footstep() during
    walk/run and _on_attack_impact() at the punch peak of the attack
    animation - the sound plays at the exact frame as required
  - 3D AudioStreamPlayer3D nodes for footstep, jump, land, attack
  - Particle effects:
        - LandDust  : dust puff under the feet when landing from a fall
        - MuzzleFlash : bright flash when attacking
          (one version on the FPS weapon, one on the third-person weapon)


How to install and run a Godot project (quick refresher)
--------------------------------------------------------
1. Download Godot 4.x (the .NET version is not required, plain
   "Standard" build is enough) from https://godotengine.org/download
   It is a single executable, no installer needed.
2. Unzip this project anywhere. Inside the unzipped folder there is
   a file called project.godot - that file IS the project.
3. Run Godot. In the Project Manager window press "Import", then point
   it to the project.godot file in the unzipped folder. Confirm.
4. The project opens. Press F5 (or the Play button top-right) to run.
   If asked to pick a main scene, choose scenes/main.tscn.

How Godot projects work in one paragraph
----------------------------------------
A Godot project is just a folder. The file project.godot at the root
tells the engine "this folder is a project". Everything else (scenes
in .tscn, scripts in .gd, images, sounds, etc.) is referenced through
res:// paths relative to that folder. Scenes are trees of nodes;
nodes get behaviour by attaching scripts. The "main scene" set in
project.godot is the one that runs first. When you save a .tscn, it is
a plain-text description of the node tree, which is why this project
can be assembled from text files alone.


Controls
--------
  WASD       move
  Shift      sprint (drains stamina)
  Space      jump
  Ctrl       crouch (use this to fit under the crossbar)
  LMB or F   attack (plays attack animation + muzzle flash + sound)
  V          toggle between FPS and TPS view
             You only see the humanoid model in TPS mode.
             Switch to TPS at least once to verify the animations.
  Esc        release / re-capture the mouse


What you still have to do (sounds)
----------------------------------
The audio files are NOT bundled here. You need to drop them into the
sounds/ folder yourself. The game runs fine without them - it just
plays silently. The code checks for the files and only plays them if
they are present, so nothing will crash if a file is missing.

Place files with these exact names in res://sounds/  (.ogg or .wav):
    footstep.ogg   - a short single footstep
    jump.ogg       - short jump/grunt
    land.ogg       - thud / landing
    attack.ogg     - punch / swoosh / shot

Recommended public-domain (CC0) sources:

1) Kenney game assets - https://kenney.nl/assets/category:Audio
   These packs are CC0 (no attribution required) and high quality.
   Suggested packs:
     - "Impact Sounds"      -> use for land
     - "Footsteps - Concrete Tiles" or "Footsteps - Grass" -> footstep
     - "Sci-fi Sounds"      -> attack (laser/punch flavour)
     - "RPG Audio"          -> jump grunt
   Pick one file from the pack, rename it to footstep.ogg etc., and
   drop it into the sounds/ folder.

2) freesound.org - https://freesound.org
   Filter by license "Creative Commons 0". Search for:
     "footstep concrete", "jump grunt", "body fall thud",
     "punch impact", "gun shot short". Download as wav,
     convert to ogg if you want (Godot accepts both).

3) opengameart.org - https://opengameart.org/art-search?keys=&field_art_type_tid%5B%5D=13
   Sort by license CC0.

After placing the files in sounds/, just press F5 again in Godot - it
will reimport automatically.


Drawings / textures you need to draw yourself
---------------------------------------------
You do NOT need to draw anything for this lab. The humanoid uses
plain coloured materials (skin, shirt, pants, hair) defined in the
player scene. If you want to give the character a face or shirt
logo, draw a small PNG/JPG (e.g. 256x256) and assign it as
"albedo_texture" on the head or torso material in the editor:

  - Face texture  -> open scenes/player.tscn, expand HumanoidMesh /
    Hips / HeadPivot / Head, select the StandardMaterial3D resource
    in the surface override, set Albedo -> Texture to your image.
  - Shirt texture -> same path but on the Torso mesh material.

This is optional and not required by the lab spec.


Where things live (file map)
----------------------------
project.godot                  - project root marker
icon.svg                       - project icon
scenes/main.tscn               - the world / arena (run this)
scenes/player.tscn             - the player + humanoid + audio + VFX
scripts/player.gd              - movement, attack, audio loading,
                                 particle setup, animation switching
scripts/camera_rig.gd          - first/third-person camera switching
scripts/humanoid_animator.gd   - attached to the AnimationPlayer,
                                 builds the AnimationLibrary at startup
                                 (idle, walk, run, jump, fall, crouch,
                                  attack) with method tracks for
                                 footsteps and attack impact
sounds/                        - YOU drop the four sound files here
vfx/                           - reserved (kept empty)


Lab spec checklist
------------------
[x] Import a 3D character model
    (procedural humanoid built from Godot primitives, scenes/player.tscn)
[x] Import required animations (idle, walk, jump, attack and extras)
    (built at runtime in scripts/humanoid_animator.gd)
[x] Connect animations to the model
    (AnimationPlayer node inside player.tscn, animations target the
     humanoid sub-nodes by NodePath)
[x] Add sound effects (footsteps, jump, attack)
    (AudioStreamPlayer3D nodes under Player/SFX, loaded in player.gd
     if files are present in res://sounds/)
[x] Connect them to actions / animations
    (jump and land are triggered from player.gd; footsteps and attack
     impact are triggered from animation method tracks)
[x] Use Animation Events to play sound at the exact time within the
    animation
    (method tracks _on_footstep and _on_attack_impact in
     humanoid_animator.gd, see _method_track function)
[x] Import / create particle effect
    (GPUParticles3D nodes; ParticleProcessMaterial built in player.gd:
     LandDust = dust on landing, MuzzleFlash = flash on attack)
[x] Trigger the effect on a specific action
    (LandDust on landing in _check_landing(), MuzzleFlash on attack
     impact in _on_attack_impact())
