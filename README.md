# Lithium

A modular hub. Single-file load, one feature per file, no dependency wiring.


## Features

Aim — silent aim, prediction, resolver, FOV control, target lock, tracers
Combat — kill aura, hitbox expander, triggerbot, rapid fire, wallbang
Visual — ESP, chams, skeleton, tracers, crosshair, bullet tracers, HUD changer
Movement — speed, fly, bunny hop, spinbot, vehicle fly, fake macro
Automation — auto-buy, auto heal, auto armor, auto reload, auto mask
Utility — desync, fake position, velocity spoofer, anti-void, anti-grab, god block, cash aura
World — ambient, fog, skybox, nebula theme
Fun — grab tools, throw, punch, rip in half, void, orbit, stomp effects

## Structure

init.lua              entry — loads core, features, ui in order

core/
  hook.lua            blocks 11 anti-cheat remotes via __namecall
  config.lua          every feature state in one table
  remote.lua          main remote resolver
  helpers.lua         isAlive, isKO, getClosestToCursor, raycast visibility
  desync.lua          body clone rig at (9999,9999,9999)

features/
  aim.lua             target aim UI + keybind
  aim_loop.lua        render-step aim / autokill / strafe
  aim_hud.lua         target stats panel + highlight
  hit_effects.lua     chams, skeleton, sounds, notifications
  killaura.lua        aura + stomp + visualizer
  gun_mods.lua        equip all, rapid fire, wallbang
  hitbox.lua          hitbox expander
  legit.lua           aimlock + triggerbot
  movement.lua        speed, fly, bunny hop, spinbot, vehicle fly, macro
  auto_buy.lua        gun, ammo, heal, armor, mask
  trolling.lua        grab tools, stomp effects
  misc.lua            anti-void, anti-stomp, cash aura, god block, anti-mod
  esp.lua             box, name, distance, skeleton, health, tracer, chams
  visual.lua          crosshair, rain, snow, aura, china hat, bullet tracers, hud
  world.lua           lighting, fog, skybox, nebula
  player.lua          player list, waypoints
  animation.lua       dance, animation packs
  anti_aim.lua        desync modes, fake pos, velocity spoofer

ui/
  settings.lua        menu bind, DPI, anti-afk, unload
  watermark.lua       corner overlay
  theme.lua           lithium palette

libs/                 optional vendored copies of the UI library

## Adding a feature

1. Write features/whatever.lua
2. Use globals from init.lua: Config, Tabs, Library, notify, LocalPlayer, RunService, Camera, Players, Workspace
3. Add one line to init.lua under the other load() calls

No registration, no imports, no dependency wiring.

Kindly use following executers for best result :

Delta
SynapeZ
CodeX
Madium
Velocity
Volt
Wave

## Credit

For Support : dsc.gg/JDpsqbnH8
