================================================================================
# DEPRECATED
The  material in this repository is far from fresh, and no longer maintained. It has not been updated with SM 1.10, and I expect it to be mostly broken because of updates made to the L4D2 client since it was last worked on. For an actively-maintained competitive L4D2 framework and configs, refer to https://github.com/SirPlease/L4D2-Competitive-Rework
================================================================================


Pro Mod - L4D2 Competitive Config - Version 4.0
Website: http://l4dpromod.com

Pro Mod is a configuration for Left 4 Dead 2 built for LGOFNOC [pre 4.0: Confogl] with the purpose of
making competitive play more balanced and interesting. It's the most recent set of
changes from an evolving set of ideas put forth from other configs such as Fresh
and Metafogl, as well as the community.

Developer  : CircleSquared (inactive), Jacob, Stabby, epilimic
Customfogl : EsToOpi, Jacob, Sir
Plugins    : CanadaRox, ProdigySim, Blade, Jahze, Jacob, Tabun, Vintik, Stabby, CircleSquared, Grego, purpletreefactory, Greenice, raziEiL
VScripts   : Jacob, Tabun, CircleSquared
Stripper   : Jacob, Blade, Tabun, Stabby, CircleSquared, Visor, NF
Testing    : Ammo, bink, Button, cepS, Critical, Cuda, Dolemite, DustY, epilimic, Fever, Fig, hoveller, K9, Kobra, Laugh, Lazy, Lid, marr, Martine, Murtagh, purpletreefactory, Rjven, scalar, the ZKA! crew, and everyone at L4DNation.com
Website    : Xan, Gen

Special thanks to epilimic for all the time spent testing things himself and getting people to play full games during testing.

================================================================================
Installation Instructions (Must be done in ORDER)
================================================================================
Pre-install note: This guide and linked packages are for LINUX servers only. This guide also assumes you have a clean vanilla server to start with.
At this time windows is not fully supported. For more information on setting up a windows server please visit: http://www.l4dnation.com/confogl-and-other-configs/does-promod-work-on-windows-server/ and also note that you will still need LGOFNOC and the updated Match Vote to play Pro Mod 4.0

Step 1 - Stop Server
Step 2 - Install MM+SM+Updated Files combo, or skip to Step 3
Step 3 - Install Metamod: Source
Step 4 - Install Sourcemod
Step 5 - Install Required files
Step 6 - Install Pro Mod
Step 7 - Start Server
================================================================================


-----------------[Step 1 - Stop Server]-----------------------------------------
Stop your server in the control panel of your GSP. Not doing this step sometimes causes issues when installing.
--------------------------------------------------------------------------------


-----------------[Step 2 - Install MM+SM+Required Files combo]------------------
Combo Pack: MetaMod + SourceMod + All Required Files (except Pro Mod)
Download: http://l4dpromod.com/files/required/lgofnoc_fullpackage_1.0.zip
Install: Extract and upload to your server's /left4dead2/ folder.

This is a fully working server package with all prerequisite files included and covers steps 3-6. If you do not wish to install this package and prefer to install everything separate, skip to Step 3 - Install Metamod: Source.

Also keep in mind that this is a full install, if you have configs edited (admin_simple.ini), this will overwrite it.

This package contains:
Metamod
Sourcemod
Left4Downtown
L4DToolz
Stripper:Source
DHooks
Builtin Votes
L4D2 Direct
LGOFNOC
Match Vote

We have removed a few files that aren't needed for the sake of keeping the package a bit smaller. Things removed include binaries/gamedata for games other than l4d2, and the entire scripting folder of sourcemod.

Once installed, skip to Step 6 - Install Pro Mod.
--------------------------------------------------------------------------------

-----------------[Step 3 - Install Metamod: Source]-----------------------------
If you already have Metamod: Source installed, check your version. If you are using at least 1.10.1, skip this step.

Download: http://l4dpromod.com/files/required/metamod_1.10.1-hg870.zip
Source: http://sourcemm.net/snapshots
Install: Extract and upload to your server's /left4dead2/ folder.

After that, go to the metamod site and click Make your VDF and choose Left 4 Dead 2. This is not required if you download MetaMod from our Downloads page.
Download the metamod.vdf put it inside the "../addons/" folder. Also not required if you downloaded from our Downloads page.
--------------------------------------------------------------------------------


-----------------[Step 4 - Install Sourcemod]-----------------------------------
If you already have Sourcemod installed, check your version. If you are using at least 1.6.0-hg4140, skip this step.

Download: http://l4dpromod.com/files/required/sourcemod_1.6.0-hg4140.zip
Source: http://www.sourcemod.net/snapshots.php
Install: Extract and upload to your server's /left4dead2/ folder.

We Recommend: Version 1.6.0-hg4140+ (below this and the latest SMAC won't fully work)
--------------------------------------------------------------------------------

-----------------[Step 5 - Install Required files]------------------------------
Left4Downtown2
Download: Left4Downtown2 (0.5.4.2) http://l4dpromod.com/files/required/left4downtown2_0.5.4.2.zip
Source: https://code.google.com/p/left4downtown2
Install: Extract and upload to your server's /left4dead2/ folder.

L4DToolz
Download: L4D Toolz (1.0.0.9h) http://l4dpromod.com/files/required/l4dtoolz_1.0.0.9h.zip
Source: http://forums.alliedmods.net/showthread.php?t=93600
Install: Extract and upload to your server's /left4dead2/ folder.

Stripper:Source
Download: Stripper (1.2.2) http://l4dpromod.com/files/required/stripper_1.2.2.zip
Source: http://forums.alliedmods.net/showpost.php?p=1987339&postcount=1146
Install: Extract and upload to your server's /left4dead2/ folder.

Dhooks
Download: Dhooks (1.0.12-alpha) http://l4dpromod.com/files/required/dhooks_1.0.12-alpha.zip
Source: http://forums.alliedmods.net/showthread.php?t=180114
Install: Extract and upload to your server's /left4dead2/ folder.

Builtin Votes
Download: Builtin Votes (0.5.8) http://l4dpromod.com/files/required/builtinvotes_0.5.8.zip
Source: http://forums.alliedmods.net/showthread.php?t=162164
Install: Extract and upload to your server's /left4dead2/ folder.

L4D2 Direct
Download: L4D2 Direct (latest) http://l4dpromod.com/files/required/l4d2_direct.zip
Source: https://github.com/ConfoglTeam/l4d2_direct/blob/master/gamedata/l4d2_direct.txt
Install: Extract and upload to your server's /left4dead2/ folder.

LGOFNOC
Download: LGOFNOC (1.0) http://l4dpromod.com/files/required/lgofnoc_1.0.zip
Source: https://github.com/ConfoglTeam/LGOFNOC
Install: Extract and upload to your server's /left4dead2/ folder.
Important: LGOFNOC & Pro Mod 4.0+ is not compatible with Confogl. You must remove confoglcompmod.smx from your server's addons/plugins/ folder for Pro Mod 4.0 to work.

Match Vote
Download: Match Vote(1.2) http://l4dpromod.com/files/required/match_vote_1.2.zip
Source: https://github.com/Stabbath/sm_plugins/tree/master/match_vote
Install: Extract and upload to your server's /left4dead2/ folder.
Important: Any prior version of match_vote is not compatible with LGOFNOC. You must replace your existing match_vote.smx from your server's addons/plugins/ folder for LGOFNOC to work.


Lastly, if you already have sdkhooks installed, you'll need to make sure these files aren't in your sourcemod folder:

    gamedata/sdkhooks.games.txt
    extensions/sdkhooks.ext.dll
    extensions/sdkhooks.ext.so

If they are, DELETE them. They are left overs of an outdated version of SDK Hooks and will cause conflicts on your server. SDKHooks is now built into the recommended version of Sourcemod.
All prerequired files for Pro Mod are now installed.
-------------------------------------------------------------------------------


-----------------[Step 6 - Install Promod]-------------------------------------
Download Pro Mod 4.0. http://l4dpromod.com/files/ver/ProMod4.0.zip
Extract and upload to your server's /left4dead2/ folder and overwrite anything that it asks to.
Promod is now installed. If you're installing other configs, make sure Pro Mod's plugins aren't overwritten by them as they may not work as intended.
-------------------------------------------------------------------------------


-----------------[Step 7 - Start Server]---------------------------------------
Restart your server and connect to it.
Once in game type in console "sm version" and "meta version" to check if both are installed.
Try to start a config with !forcematch promod.
To check plugins are loaded type "sm plugins" in console, then say !resetmatch in chat to see if it correctly unloads then try another config.
Your server is now installed, gg.
-------------------------------------------------------------------------------


===============================================================================
Additional Q/A
===============================================================================

  ["Commands like !forcestart and !forcematch aren't working."]

  If everything else works, you probably need to set admins in sourcemod.
  See here: http://wiki.alliedmods.net/Adding_Admins_%28SourceMod%29

  ["How do I get other configs like EQ into the match vote menu?"]

  You must add them in (addons/sourcemod/configs/matchmodes.txt) and then add this
  line into the confogl_plugins.cfg file of the config you wish to add:

        sm plugins load match_vote.smx

  Additionally you may add the above line to your confogl_personalize.cfg so that it is
  universally loaded for all configs, but you must still edit matchmodes.txt.

  ["SI sounds are off, I can hear SI spawns on survivor, or my teammates are invisible."]

  SMAC's wallhack plugin causes these issues as well as causes hit registration issues.
  We really don't recommend using it with Left 4 Dead 2. Other SMAC plugins however are
  very much recommended to prevent cheating.


  ["How do I fix (issue) with Fresh/Metafogl/Etc with Pro Mod installed?"]

  Older configs aren't supported because of plugin updates that change cvars or break
  old functionality. If you want to fix them to work with Pro Mod installed feel free
  but they aren't supported. Good luck to you.


  ["Where is zombie bat?"]

  Zombie bat lives in all of us.

====================================================================================
LICENSE
====================================================================================

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.

END OF LICENSE
