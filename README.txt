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
Pre-install note: This guide and linked packages are for LINUX servers only. 
At this time windows is not fully supported. For more information on setting up a windows server please visit: http://www.l4dnation.com/confogl-and-other-configs/does-promod-work-on-windows-server/ and also note that you will still need LGOFNOC and the updated Match Vote to play Pro Mod 4.0

Step 1 - Stop Server
Step 2 - Install MM+SM+Updated Files combo, or skip to Step 3
Step 3 - Install Metamod: Source
Step 4 - Install Sourcemod
Step 5 - Install Required files
Step 6 - Install Pro Mod
Step 7 - Start Server
====================================================================================


-----------------[Step 1 - Stop Server]-----------------------------------------
Stop your server in the control panel of your GSP. Not doing this step sometimes causes issues when installing.
--------------------------------------------------------------------------------


-----------------[Step 2 - Install MM+SM+Updated Files combo]-------------------
Combo Pack: MetaMod + SourceMod + All Required Files (except Pro Mod)
Download: http://l4dpromod.com/files/required/metamod_1.10.1-hg870.zip
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
Download: http://l4dpromod.com/downloads.php
Install: Extract all of the files into the same directory structure of your server and overwrite anything that it asks to.
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


===============================================================================
Changelog
===============================================================================

4.0
Main Changes:
- ProMod now uses damage bonus. Parity will now be the exact health bonus equivalent of ProMod.
- Removed l4d_hots and l4d2_nobhaps from every config, enabling instant pill health and tank bhops.
- Tweaked l4d2_startercommon: it now lowers the common limit on round start and instantly resets it upon leaving saferoom.
- Added caster_assister to help spectators, especially streamers/casters, move around more naturally.
- Added tank rock selector plugin, CanadaRox's version: just pressing Use or Reload alone will start the rock throw.
- Added l4d2_spitdontswallow to allow people to opt for a spitter during tank fights.
- Added staggersolver to block button presses during stumbles.
- Removed No Mercy 5 and Dead Center 4 wipefest flow tanks.
- The 2nd finale tank (not counting possible flow tanks) is now blocked, to makes finales shorter and more survivable.
- Hard Rain 2 has multiple witches again, but with reduced health (only 500).
- Hard Rain 1 only has 1 SMG and 1 pump shotgun in saferoom: to get more primary weapons players must go into the diner.
- 4v4 configs now have 1 extra pill.
- Added zombie bat.
- Insta pounce is fixed (Hunters & Jockeys)
- Ladderblocking is fixed, the blocker will simply be pushed away.
- When a survivor dies, he/she will always drop his secondary weapon (Pistol, Melee)
- Engine Fixes are applied (Picking up players won't prevent fall damage)
- Blocked texture manager mathack.
- Heavily reworked map distances. They were initially based on a mix of the typical distance and health scores as logged by the l4d2-logger, on a scale of 300 to 1000 (300 for parish 1, which was used as the base), with small human adjustments and about ~150-200 points being removed for each tank that will be blocked in 4.0. With the shift to DB, the goal will be to base the maximum distance scores strictly on the average damage bonus people have at the end of the map (another benefit of DB is that we can do that and end up with perfect scoring balance).

Other Changes:
- Added witch_announce and other small plugins that were needed or popularly requested, like the ones listed at the end of the Main Changes (thanks to Jahze, Sir and Visor).
- Removed l4d_tank_rush from whichever configs had it.
- Converted from confogl+l4d2lib to lgofnoc.
- Added CCT's spit damage blockers to the regular plugin.
- Separated custom map distances into a separate plugin from scoremod.
- Removed the remains of l4d_tankpunchstuckfix.
- Uniformized a lot of settings:
    - Every config uses the same stripper setup (they were already 99% the same).
    - There is a limit of 2 equipped melee weapons in every config (will probably be tweaked).
    - Respawn intervals for all 1v1/2v2/3v3/4v4 configs are set to 8/11/13/17.
    - Common limits are set to 7/15/22/30.
    - Mega mob sizes are set to 1.33 times common limit.
    - Normal mob sizes are set to 0.83 times common limit.
    - Starting common limit is set to 0.33 times common limit (from l4d2_startercommon).
    - Tank healths are 1000/2000/3000/4000 (multiply by 1.5 for the real versus value).
- All item spawns are now handled by universal-item-manager.
- Removed l4d_nocans, all canister, can and firework removal is now done by universal-item-manager.
- Changed the way plugins are loaded to be more developer-friendly. Plugin loads and cvar settings are divided into .cfg modules, selectively executed by each config that wants that module's features:
    - There's a .cfg for the standard promod settings.
    - There's a .cfg for each possible player number (1v1/2v2/3v3/4v4).
    - There's a .cfg for adding a nerfed hr.
    - There's a .cfg to have hunters only.
    - ... for db.
    - ... for hb.
	- etc...
- Likely other smaller changes that were forgotten.

TODO:
- Add epi's new plugin which allows custom connection messages. "Jacob (Admin) has connected."
- Remove the secret room from dark carnival 4 that could spawn up to 4 pills in unobtainable places.
- Revise and implement the following stripper changes:
  - c1m1: Removed props from burning room.
  - c1m1: Removed 2 props from the final room before saferoom.
  - c1m2: Removed awning on overpass that gave SI spawns at the cost of blocking potential car hits.
  - c2m1: Blocked survivors getting on top of the ambulance and white van in the open tank fight area.
  - c2m2: Removed a couple tents at the bottom of the slide.
  - c2m3: Removed vent block that was for hunters mode in primary config.
  - c3m2: Removed a bush in the open field after the event to remove a bit of clutter.
  - c5m1: Added two possible pill spawns early in the map.
  - c5m2: Removed hedge in open field that gave survivors easy LOS.
  - c5m2: Made weapon spawns in the park consistent. (Shotgun right, Hunting Rifle middle, SMG left)
  - c5m3: Removed hittable dumpster from open area outside saferoom.
  - c5m3: Removed big blue dumpster from open area outside saferoom.
  - c5m3: Removed semi truck from street just before manhole drop.
  - c5m3: Made the bushes at the back of the street just before the manhole inaccessible for survivors, however infected can now use these to get behind the fence.
  - c5m5: Removed bridge props other than the side railings. Ending is still as CircleSquared made it.
  - c10m4: Removed army truck that I have never seen do any good but block hittables.
  - c10m4: Removed semi-truck that served no purpose.

3.3 - Undocumented test release with changes to the main promod config alone, with an associated beta version
- Updated Ready up, Pause, and Player Management.
- Tweaked god frames to not reward gang bangs, but to still reward spit damage.
- Fixed death spit having 2 hitboxes which could lead to players taking damage from "invisible" spit.
- Updated stripper files to match throwback.
- Changed Boomer Vomit recharge time from 30 to 20.
- Added CanadaRox's Simple Pill Passing plugin. (Press Reload while aiming pills at a teammate.)
- Added Tab's AI Damage Fix plugin.
- Added Raecher's updated Boss Percentage plugin. (There will now be a witch on every map.)
*The following changes only apply to the beta*
- Added damage based scoring.
- Changed all map distances to 200.

3.2
- Added plugin to track statistics for further balance changes (no private information is taken)
- Added plugin to allow SI to warp to survivors as ghosts based on survivor position in map:
    Use: sm_warpto <1-4> (ex 1=Front 4=Back) or <name> (such as Ellis or Louis)
- Added plugin to keep being-shot hunters from losing pouncability against other objects
- Added plugin for players to set scores directly in the event of a server crash
    Use: !setscores <survivor score> <infected score> (non-admins will prompt a vote) 
- Added coinflip plugin to make neutral decisions on captains or teams (use !coinflip)
- Updated Tabun's exploit blocker package to v29
- Updated tank control to display who will get the tank at round start
- Updated and readded heatseeking charger fix to kick instead of attempt to stop charge
- Updated readyup plugin to fix a glitch that kept players from being able to pause
- Removed temporarily punchstuckfix due to issues
- Fixed horde from being unavailable when survivors reach certain sections of c1m2 and c5m2
- Merged Customfogl into all packages (for custom campaign support)

3.1
- Added new config 'Parity' with Canadarox's damage bonus system and temp-health kits
    Uses Commands: !damage or !health
- Added tank control plugin to 2v2/3v3s (everyone gets tank and frustration refills instead of pass)
- Added starter common plugin to 2v2/3v3s to prevent wasting time clearing outside saferoom
- Added plugin to replace lerptracker, high lerps will spectate players instead of kicking them
- Added plugin to replace si no slowdown with a simpler tank slowdown enable/disable cvar
- Added plugin to prevent getting stuck in ceilings from tank punches (teleports down after 1 sec)
- Added plugin to kill tanks that turn AI on deadman to prevent double teaming survivor
- Added plugin to replace pillgiver with bitfield flags for more flexibility
- Added plugin to fix exploit that gave free distance points on configs with less than 4 survivors
- Added small car alarm event and forced survivors to make a one-way drop on Hard Rain 4
- Added tank spawning ban for 80-100% on Hard Rain 4 to go along with new alarm event
- Added extra time until tank frustration drains on deadman since only one turn (35 seconds)
- Added a single pill outside of the saferoom for pm3v3
- Updated Tabun's exploit blocker package to v28
- Updated promodhr with balance/difficulty tweeks to make it more appealing
    Hunting Rifle clipsize decreased to 10 (from 12)
    Hunting Rifle damage on tanks decreased to 75 (from 90)
    Removed tank slow down from survivor weaponfire
- Updated mvp plugin to fix bugs like incorrect CI kills and include output stats in console
- Updated hittable control plugin to include forklifts, bhlogs, handtrucks, and overhit settings
- Updated boss percents plugin to fix displaying [None] occasionally on second round
- Updated boss percents plugin to include a cvar for turning on/off global chat display on commands
- Updated starter common plugin to work with non-default common limits
- Updated l4dhots plugin to include cvars for interval, increment, and total health
- Updated thirdpersonshoulderblock plugin to spectate players with bad settings instead of kick
- Updated getup fix plugin to improve handling of getup animation bugs and add new functionality:
    Double Getup Bug: Added check for additional situations where double getup could still occur
    Zero Getup Bug: Added getup animation after charging a jockeyed player (previously none)
    Self Clear Bug: Removed getup animation when you self clear/level a charger when near an obstacle
- Updated scoremod plugin to use colors and include a "Difference" stat display for health bonus:
    Difference = (round1 hb - round2 hb)
- Updated readyup plugin to more recent version with working pause limit (def 100 pauses) and color
- Updated readyup plugin to prevent pausing while an incapacitated survivor pickup is in progress
- Updated match votes plugin to allow forcematching of configs not in the matchmodes.txt menu
- Updated slow pill health to give 2 health per 0.2 seconds instead of 10 per 1.0 seconds
- Updated the following plugins to prevent error spam in log files:
    confoglcompmod, l4dready, l4d2_scoremod, l4d_boss_percent, l4d_weapon_attributes, l4d_no_cans
    l4dhots, l4d_tank_props, l4d2_blind_infected, 1v1_skeetstats, l4d2_unsilent_jockey
- Updated Parish finale with LOS humvees (1 on bridge, 2 on helipad) and opened a death charge spot
- Removed jockeys config from the main package
- Removed jockey glitch fix plugin since valve has addressed the issue
- Removed heatseeking charger fix plugin since it apparently never worked
- Removed a useless client cvar setting and a duplicate scoremod cvar to prevent error spam in logs
- Removed item spawns at the end of long maps that are right at map end since they are useless:
    Dead Center 1(3), Dead Center 2(7), Hard Rain 2(9), Parish 2(1), Parish 3(4),
    Sacrifice 2(1), No Mercy 3(7), Crash Course 1(4), Death Toll 1(4),
    Death Toll 2(6), Dead Air 2(6), Dead Air 3(2), Blood Harvest 2(1)
- Fixed buffed pumpshotgun in retro not getting reset and carying over to vanilla and other configs
- Fixed accidental loading of tank plugin in pm1v1
- Fixed accidental blocking of bhops on hunters 1v1-4v4
- Fixed players being pushed by common when not boomed but when other survivors are
- Fixed shoves until boomer pops from 4 to 5 to always be exactly 4
- Fixed car at exploding bridge on parish 3 from randomly igniting tanks on fire when punching it

3.0
- Removed weapon_item_spawns from L4D1 map finales to prevent throwable and pill issues
- Removed medkits by hammerid in DT4 saferoom that magically appear there on second round
- Bhop for survivor now allowed on Pro Mod and Pro Mod HR (tanks are still blocked)
- Replaced tank percent with boss percent, the commands: !tank !witch and !boss
- Boss percentages will be be more accurate and sm_tank/sm_witch/sm_boss in console now work
- Removed connectinfo plugin, try Paranoia IP Tracker instead if you need this functionality
- Updated nobhaps plugin to toggle bhop allowed status of survivors with a cvar
- Updated weapon limits plugin to allow swapping melees with different types at limit
- Updated weapon limits plugin to fix a bug that turned teammates into civilian survivors
- Added plugin to prevent survivor bots taking pills if players crash or disconnect from game
- Added plugin to remove tank back-punch from the 3 selectable punch types, now there are only 2
- Added tank rush plugin (thanks to Jahze and Vintik) to deadman to stop distance when tank is alive
- Lowered some horde values in mapbased cvar changes for 2v2/3v3 configs
- Fixed some weapon conversion for euros that had some mistakes
- Dead Center 1 saferoom weapons removed and re-added the 2 previously removed melee
- Dead Center 1 maproom now has a single pickup shotgun with 8 ammo and no reserve (for witch)
- Dead Center 1 tank spawn pushed back slightly from 76% to 82%
- God frames for hittables, witches, smokers, and jockeys have all been removed
- God frames for smokers and jockeys adjusted to include 1 second of spit protection
- All hittables (even baggage carts, logs, and haybales) always deal 100 damage and never clip players
- All hittables (even baggage carts, logs, and haybales) always deal 100 damage to incaped survivors
- All hittables will now cause 0 self-damage to the tank when hit with them accidentally
- Reorganized all of the plugin loading cfgs and plugin cvar cfgs to remove clutter, typos, and mistakes:
    Fixed the typo that was supposed to already be fixed to fix the silent jockey plugin... fixception!
    Added jockey ledge hang plugin to pm2v2/pm3v3 and removed it from pm1v1
    Fixed a typo that prevented blocktrolls plugin from loading in hunters3v3
    Removed slow health pills (l4dhots) from pm2v2
    Re-added missing lines that prevents m2 kills in hunters 1v1-4v4, pm1v1, deadman, and jockeys
    Added mysteriously missing weapon rules to pm1v1
- Parish finale remixed: longer map, more opening for SI attacks, and drastically less death charges
- Parish finale custom distance bonus raised to 600

2.6
- Updated Tabun's exploit blocker package to v27
- Updated confoglcompmod to prevent the config display issue
- Added Vintik's match vote plugin which adds/augments two new commands:
    !match - Brings up a menu of available configs (editable by server admin) to vote on loading
    !rmatch - Brings up vote to reset match to vanilla (same effect as admin command sm_resetmatch)
- Added confogl_rates.cfg for easier changing of rates for different tick servers
- Added DieTeetasse's plugin to stop spectators being randomly swapped to teams on map change
- Added dominators control to some configs to prevent double hunters
- Readded default l4d2lib mapinfo path to fall back if configs are missing mapinfo.txt
- Added vscripts to c12m3 to make horde equally consistent between rounds at the event
- Added vscripts to c12m3 for 1v1-3v3 to prevent full player horde at the event
- Updated mapinfo data to remove useless code and cleaned it up a bit
- Added mapinfo data for Crash Course (fixes health kit conversion at finale, also)
- Added mapinfo data for about a dozen different popular custom campaigns:
    Blood Tracks, Carried Off, City 17, Drop Dead Gorges, Dead Before Dawn 2,
    Death Aboard 2, Detour Ahead, Haunted Forest, I Hate Mountains, One 4 Nine,
    Suicide Blitz 2, The Dark Parish, Tour of Terror, Urban Flight, Warcelona
- Added the c2m3 vent block to all configs
- Removed adrenaline completely
- Increased pills per map from 3 to 4
- Fixed all instances where pills would spawn more than the limit on finales
- Finales now always have 4 pills except Crash Course which has 6 (4 at event, 2 randomly in map)
- Changed Crash Course finale distance bonus to 800
- Added tier 1 weapons to Dead Center 1 saferoom and removed 2 melee
- Nerfed Retro shotgun very slightly (272 to 256 damage)
- Increased tank spawning ban distance slightly for Death Toll 1 from 60% to 70%
- Added tank spawning ban for the Blood Harvest 5 cornfield event
- Added hunters1v1 config and changed pm1v1 to hunters/jockeys (deadman hunters only)
- Reduced pm3v3 spawn timer from 15sec to 13sec
- Added the tank damage announce plugin to deadman
- Updated the 1v1 plugin to refer to players as infected rather than hunter
- Updated the no cans plugin to additionally remove fireworks
- Enabled full bunny hopping on all configs except promod and promodhr
- Replaced magnum spawns with pistols in configs that limit them to 0

2.5
- Updated l4d2lib using confogl natives so mapinfo.txt is loaded from each cfgogl directory.
- Updated Skeetstats plugin to latest version.
- Updatd Tabun's exploit blocker package to v26.
- Fixed Chargers getting stuck on the ledge lip of Dark Darnival 2 ladder-roof area.
- Fixed bot Chargers becoming heat seeking at survivors.
- Reduced common infected a bit more for 4v4 static hordes for 1v1-3v3.
- Vscripts for L4D1 maps on 1v1-3v3 configs to prevent 4v4 horde. (Dead Air 4 glitchy still, starts large but does dissipate)
- Fixed typo causing silent jockey fix plugin from not loading.
- Fixed quadcaps in Retro to follow normal sac order rules.
- Readded HR in standard spots for Retro for ammo pickup. (limited to 0)
- Cleaned up all the configs and stripper cfgs to be more readable and remove outdated cvars.
- Blocked cheap camping spots in Hunters/Jockeys/Retro configs.
- Weapons outside HR1 dinner changed to uzi/pump with weapons inside changed to silenced uzi/chrome.
- Updated 1v1 plugin to remove some error output and show promod1v1 and various messages depending on health left.
- Fixed HR from spawning randomly on c5m2 in promodhr to spawn near the horse statue and steps past the hall choke.
- Fixed tier 1 uzi/shotgun not appearing in saferoom of c1m1 for Retro.
- Reduced m2s for 1v1 to match Hunters config.
- Reduced gas can pour time to 1 second on scavenge-type finale for 1v1.
- Replaced added saferoom shotguns with code to make already spawned weapons always produce at least 1 uzi and 1 shotgun. (c2m5, c5m2, c5m5, c6m3, c8m4, and c8m5)
- Fixed pills issues on some finale maps. Pills now always spawn where finale first aid kits normally do. (c5m5, c10m5, c11m5, c12m5, c13m4)
- Fixed adrenaline/throwables appearing in some spots in 1v1-3v3 configs.
- Readded and updated Deadman config.
- Updated tank control plugin to inform all SI when tank rage refills in hint text and in chat in color.
- Updated tank percent plugin to match EQ's boss percent plugin formatting.
- Fixed 'No Boomer Glitch'.

2.4
- Removed mp5.
- Re-added HR as an ammo pick up only.
- Removed bile bombs.
- Nerfed adrenaline. Run speed is now the same as when you are not on adrenaline. Reviving someone takes 3 seconds, instead of 2 while on adren. (4 while not on adren)
- Added quad caps to retro. For now they are random, and not based on sack order. We are working on a plugin for that.
- Removed water slowdown in Retro.
- Enabled bhops for EVERYTHING in Retro.
- Added vscript for BH4 finally removing all dependencies on metafogl.

2.3
- Updated uncommon blocker to replace the uncommon infected with a regular common.
- Updated Survivor MVP plugin. Will no longer show FF stats as it causes server lag.
- Updated SI FF Block to fix SI not dying when entering kill zones while spawned.
- Updated exploit blocks to v25.
- Fixed 4 player hordes spawning in 3v3/2v2/1v1 configs.
- Buffed mp5 damage to 28 (26 to tank) and limited to 1.
- Changed grace period when you first get tank to 25. Tanks now have the same amount of rage as normal tanks.
- All saferooms will now have at least 1 shotgun. (Parish 5, No Mercy 4, Passing 3)
- Added Silent Jockey fix.
- Added Skeet Stats to 1v1 config in place of mvp.
- Added new config "Retro". L4D1 style config. Thanks to CircleSquared for making this config.
 
2.2
- Finally fixed the mp5. It will now spawn in the place of the Hunting Rifle and Military Sniper.
- Added l4d_tank_control from EQ. Players who have already played the tank will not get a chance to be the tank again until all other players have had a turn. Tanks no longer pass between players, their rage meter is reset once instead.
- Added Jockey Hang fix. Jockeys will now have a 10 second cooldown after hanging a player off a ledge.
- Updated Car Alarm Equaliser.
- Fixed extra pills spawning in side configs.
- Removed a few outdated lines from confogl.cfg.

2.1
- Re-Added board allowing SI to get on top of the saferoom on Parish 2 that was accidentally removed in 2.0.
- Removed all uncommon infected except for "Mud Men".
- Fixed colors in Tank Damage Announce plugin.
- Replaced Military Sniper with MP5, and Autoshotgun with Chrome.
- Updated Survivor MVP plugin.

2.0
- Fixed parish finale for those who still play it.
- Fixed Tank spawning in the sugar field on c4m3.
- Updated mapinfo to include support for custom campaigns; I hate mountains 2, Death Aboard 2, Dark Parish.
- Removed bile bomb from Dead Center finale.
- Slightly increased horde during 2nd event on Dead Air 4.
- Changed Dead Center max distances to default values.
- Fixed confogl_off for all configs.
- Fixed "Jockey Glitch" thanks to Tabun's plugin.
- Updated Metafogl's 1v1, 2v2, 3v3, and hunters configs.
- Created a new config "Jockeys".
- Blocked Tank spawning right as survivors start the event on Dead Center 3.
- Changed Deagle limit to 1 in Pro Mod.
- Unblocked Bunny Hopping for survivors in Pro Mod 1v1, 2v2, and 3v3. NOT the main config.
- Added the mp5. It will spawn in the place of the Scar.
- Updated Tank Damage Announce with colored text. (Thanks CircleSquared)
- Updated Tank Percent with colored text. (Thanks CircleSquared)
- Updated Tabun's exploit blocks to v24.
- Re-Added Props to the end of Dead Air 3. (Glass Hallway)
- Re-Added Props to the beginning of Dead Air 4. (Rocks)
 
1.5
- Reduced shotgun ammo back to 80.
- Restored uzi ammo to 650.
- Replaced hunting rifle with pumpshotgun, and military sniper with silenced uzi.
- More mapinfo fixes.
- Blocked tank on Dead Center 1 up to 76% due to complaints of a glitched tank spawn.
- Tweaked props on No Mercy 1.

1.4
- Increased shotgun ammo to 100.
- Reduced uzi ammo to 550.
- Replaced military sniper with uzi instead of shotgun, do to complaints of not finding enough uzi ammo.
- Removed static survival bonus, returning the health bonus system to how it was in other configs.
- Fixed up some mapinfo stuff.
- Updated tabun's exploit blocks to version 23.
- Removed Dark Carnival 5 "Everything Or Nothing" Forklift.
 
1.3
- Reduced map distance on a couple maps; DaC3 = 600, NM2 = 500
- Added survival bonus. Basically extra points for surviving the map.
- Fixed hard rain 2 glitched tank spawn from meta.
- Removed custom max distance being shown in health if the map distance is default.
- Added support for Detour Ahead.
- Updated Tabun's Exploit Blocks to v21.
- Removed Scout from Pro Mod.
- Replaced all snipers in Pro Mod with shotguns. (Pro Mod HR still has the HR of course.)

1.2
- Updated Tabun's exploit blocks to v20.
- Replaced 2 uzi limit with a 3 ranged weapon limit.
- Attempt to fix long lasting problem from meta, where on occasion 4 sets of pills could spawn on certain maps.(excluding saferoom pills)
- Disabled Game Instructor for all players.
- Changed Parish 1 map distance to 300.
- Update to the way we block multiple scouts, reducing the chance that the scout will disappear when you try to pick it up if someone already has a scout.
- Fixed Custom Max Distance spam. (Thanks Jahze)
- Removed props from DA4 event and starting saferoom area.
- Created a side config 'Pro Mod HR'.
- Changed HR clip size to 12.

1.1
- Changed pills density to 3.
- Limit uzis to 2.
- Removed Scout buff against tanks.
- Updated Tabun's exploit blocks to version 19.
- Changed Death Toll 4 Horde Intensity in hopes of further balancing it.
- Removed props from DaC4 near event and BH4 bridge.
- Blocked Tank on Death Toll 1 immediately out of saferoom.
- Removed medkits in Death Toll 1 saferoom. (Thanks Tabun)

1.0
- Created Pro Mod.
