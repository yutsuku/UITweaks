UITweaks - a World of Warcraft (1.12.1) AddOn
====================================

Installation:

Put "UITweaks" folder into ".../World of Warcraft/Interface/AddOns/".
Create AddOns folder if necessary

After Installation directory tree should look like the following

<pre>
World of Warcraft
`- Interface
   `- AddOns
      `- UITweaks
         |-- Config.lua
         |-- README.md
         |-- UITweaks.lua
         |-- UITweaks.toc
         |-- UITweaks.xml
         |-- help
         |   `-- GlobalStrings.lua
         |-- shitpost.lua
         `-- textures
         |-- background-gradient.blp
         `-- background-gradient.psd

</pre>

Features (can be changed in `config.lua`):
- shows bg bonus week in honor tab (calendar),
- "/bandage" macro (support for battleground bandages),
- moves battleground button from minimap to honor frame,
- moves ticket frame from corner to game menu frame (ESC),
- enables group bg join (AV),
- hides buff/debuff frame,
- filters common error messages,
- hides tooltips for players/mobs/npcs,
- shows lag in game menu,
- Dims bottom of the screen when chat message appears,
- hides Lua errors,
- extend default buffs frames to support up to 32 buffs,
- include guild names in tooltip,
- colors player names by class in tooltip,
- makes debuffs icon bigger

Known Issues:
- None.

Notes:
- I made this AddOn just for myself, pull requests will be most likely ignored. Just make your own copy if you desire to add some functionality.