Pro Mod
Version 3.0
Website: http://promod.webege.com

Pro Mod is a configuration for Left 4 Dead 2 built for Confogl with the purpose of
making competitive play more balanced and interesting. It's the most recent set of
changes from an evolving set of ideas put forth from other configs such as Fresh
and Metafogl, as well as the community.

Developer : Jacob (inactive), CircleSquared
Plugins   : CanadaRox, ProdigySim, Blade, Jahze, Jacob, Tabun, Vintik, Stabby, CircleSquared
Scripts   : Jacob, Tabun, CircleSquared
Stripper  : Jacob, Blade, Tabun, CircleSquared
Testing   : Ammo, cepS, Critical, DustY, Fever, Fig, hoveller, K9, Kobra, Laugh, Lazy, Lid
            marr, Martine, Murtagh, purpletreefactory, scalar


=======================================================================================
Installation Instructions (Must be done in ORDER)
=======================================================================================
Step 1 - Stop Server
Step 2 - Install Metamod: Source
Step 3 - Install Sourcemod
Step 4 - Install Stripper: Source
Step 5 - Install Confogl
Step 6 - Install SDK Hooks
Step 7 - Install Pro Mod
Step 8 - Start Server
=======================================================================================


-----------------[Step 1 - Stop Server]------------------------------------------------
Stop your server in the control panel of your GSP. Not doing this step sometimes causes
issues when installing.
---------------------------------------------------------------------------------------


-----------------[Step 2 - Install Metamod: Source]------------------------------------
If you already have Metamod: Source installed, skip this step.

If you are using Nuclear Fallout, instead just install it on the Autoinstallers tab of
your control panel.

Download Metamod: Source. Determine which OS your server runs on and download that
version (if you are not sure ask your GSP). Extract the files to the same directory
structure of your server. After that, go to the metamod site and click Make your VDF
and choose Left 4 Dead 2. Download the metamod.vdf put it inside the "../addons/"
folder. Metamod: Source is now installed.

Download: http://www.sourcemm.net
---------------------------------------------------------------------------------------


-----------------[Step 3 - Install Sourcemod]------------------------------------------
If you already have Sourcemod installed, skip this step.

If you are using Nuclear Fallout, instead just install it on the autoinstallers tab of
your control panel.

Download Sourcemod. As with step 2 determine which OS your server runs on and download
that version. Extract the files into the same directory structure of your server.
Sourcemod is now installed.

Download: http://www.sourcemod.net/downloads.php
---------------------------------------------------------------------------------------


-----------------[Step 4 - Install Stripper: Source]-----------------------------------
Download Stripper: Source from the official Pro Mod website. Make sure you download the
correct one for your OS (if unsure ask your GSP, for NFO it's probably Windows) and
make sure you use this one and NOT the one on bailopan.net or elsewhere! Extract the
files into the same directory structure of your server. Stripper: Source is now
installed.

Download: http://promod.webege.com/downloads.html
---------------------------------------------------------------------------------------


-----------------[Step 5 - Install Confogl]--------------------------------------------
Download the fixed confogl from the official Pro Mod website. MAKE SURE you get the one
on the Pro Mod website, the one on the google code page contains outdated files that
might cause conflicts. Extract all of the files into the same directory structure of
your server. You must install this even if you are only going to use Pro Mod! Confogl
is now installed.

Download: http://promod.webege.com/downloads.html
--------------------------------------------------------------------------------------


-----------------[Step 6 - Install SDK Hooks]------------------------------------------
Download SDK Hooks from the Allied Modders forum. Make sure you download the correct
one for your server OS as previous tips suggest. Extract the files into the same
directory structure of your server. Look and make sure the following files DON'T exist
on your server in the sourcemod folder:

    gamedata/sdkhooks.games.txt
    extensions/sdkhooks.ext.dll
    extensions/sdkhooks.ext.so

If so, DELETE them. They are left overs of an outdated version of SDK Hooks and will
cause conflicts on your server. SDK Hooks is now installed.

Download: http://forums.alliedmods.net/showthread.php?t=106748
---------------------------------------------------------------------------------------


-----------------[Step 7 - Install Promod]---------------------------------------------
Download Pro Mod from the official Pro Mod website. Extract all of the files into the
same directory structure of your server and overwrite anything that it asks to. Promod
is now installed. If you intend to install additional configs such as Equilibrium, then
remember to remove any mapinfo.txt in the l4d2lib path and place it directly into the
directory of the config itself (see below). If you're installing Equilibrium 1.3 or
less make sure Pro Mod's plugins aren't overwritten by them as they are the latest
version. Equilibrium 1.4 and greater (when released) will have no conflicts when
overwriting each other.

Download: http://promod.webege.com/downloads.html
---------------------------------------------------------------------------------------


-----------------[Step 8 - Start Server]-----------------------------------------------
Restart your server and connect to it. Once in game type in console "sm version" and
"meta version" to check if both are installed. Try to start a config with !match
whatever. To check plugins are loaded type "sm plugins" and then !resetmatch to see if
it correctly unloads then try another config. Your server is now installed, gg.
---------------------------------------------------------------------------------------


=======================================================================================
Additional Q/A
=======================================================================================

  ["Commands like !forcestart and !forcematch aren't working."]

  If everything else works, you probably need to set admins in sourcemod.
  See here: http://wiki.alliedmods.net/Adding_Admins_%28SourceMod%29


  ["I'm finding throwables, map distance issues, or tank are spawning in weird places."]

  Since Pro Mod 2.5, mapinfo.txt is read from each individual config directory instead of
  one static location. Make sure you place the mapinfo.txt of any additional configs you
  want to use such as EQ in their directory (ie, cfg/cfgogl/eq/mapinfo.txt) instead of
  in the old default (addons/sourcemod/configs/l4d2lib/) directory.


  ["How do I get other configs like EQ into the match vote menu?"]

  You must add them in (addons/sourcemod/configs/matchmodes.txt) and then add this
  line into the confogl_plugins.cfg file of the config you wish to add:

        sm plugins load match_vote.smx

  Additionally you may add the above line to your confogl_personalize.cfg so that it is
  universally loaded for all configs, but you must still edit matchmodes.txt. Both of
  the fixed confogl packages already have the plugin loading line added.


  ["SI sounds are off, I can hear SI spawns on survivor, or my teammates are invisible."]

  SMAC's wallhack plugin causes these issues as well as causes hit registration issues.
  I really don't recommend using it with Left 4 Dead 2.


  ["Where is zombie bat?"]

  Zombie bat lives in all of us.


=======================================================================================
Changelog
=======================================================================================
3.0
- Removed weapon_item_spawns from L4D1 map finales to (hopefully) finally prevent throwable and pill issues
- Removed medkits by hammerid in DT4 saferoom to prevent them magically appearing there on second round
- Bhop for survivor now allowed on Pro Mod and Pro Mod HR (tanks are still blocked)
- Replaced tank percent with boss percent, commands !tank !witch and !boss all show the tank/witch percents
- Boss percentages will be be more accurate than previous and sm_tank/sm_witch/sm_boss in console now work
- Removed connectinfo plugin, try Paranoia IP Tracker instead if you need this functionality
- Updated nobhaps plugin to toggle bhop allowed status of survivors with a cvar
- Updated weapon limits plugin to allow swapping melees with different types when the limit is reached
- Updated weapon limits plugin to fix a bug that caused picking up melees to turn teammates into civilian survivors
- Added plugin to prevent survivor bots taking pills if players crash or disconnect from game
- Added plugin to remove tank back-punch from the 3 selectable punch types, now there are only 2
- Added tank rush plugin (thanks to Jahze and Vintik) to deadman to stop distance when tank is alive
- Lowered some horde values in vscripts and mapbased cvar changes for 2v2/3v3 configs
- Fixed some weapon conversion for euros that had some mistakes
- Dead Center 1 saferoom weapons removed and re-added the 2 previously removed melee
- Dead Center 1 maproom now has a single pickup shotgun with 8 ammo and no reserve (for witch)
- Dead Center 1 tank spawn pushed back slightly from 76% to 82% (prevent horde+SI+witch+tank shitstorm)
- God frames for hittables, witches, smokers, and jockeys have all been removed
- God frames for smokers and jockeys adjusted to include 1 second of spit protection
- All hittables (even baggage carts, logs, and haybales) will always deal 100 damage and never clip players for less
- All hittables (even baggage carts, logs, and haybales) will always deal 100 damage to incapacitated survivors
- All hittables will now cause 0 self-damage to the tank when hit with them accidentally
- Reorganized all of the plugin loading cfgs and plugin cvar cfgs to remove clutter, typos, and mistakes:
    Fixed the typo that was supposed to already be fixed to fix the silent jockey plugin... fixception!
    Added jockey ledge hang plugin to pm2v2/pm3v3 and removed it from pm1v1
    Fixed a typo that prevented blocktrolls plugin from loading in hunters3v3
    Removed slow health pills (l4dhots) from pm2v2
    Re-added missing lines that prevents killing SI with m2 in hunters 1v1-4v4, pm1v1, deadman, and jockeys
    Added mysteriously missing weapon rules to pm1v1
- Parish finale remixed with a longer map, more openings for SI attacks, and drastically less death charge spots
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
