Pro Mod, a competitive config based off of Metafogl.
Edited by Jacob, Designed by the l4d2 community!

Version 2.6

If you have any problems installing, add me at: http://steamcommunity.com/id/jacob404

==========================
Installation Instructions:
==========================

-----------[Step 1 - Stop Server]-----------------------
Stop your server in the control panel of your GSP. Not doing this step sometimes causes
issues when installing. On NFO control panel this is located on the Server Control tab.


-----------[Step 2 - Install Metamod: Source]-----------
http://www.sourcemm.net/

If you already have Metamod: Source installed, skip this step.
If you are using Nuclear Fallout, instead just install it on the Autoinstallers tab of
your control panel.

Download Metamod: Source. Determine which OS your server runs on and download that
version (if you are not sure ask your GSP). Extract the files to the same directory
structure of your server. After that, go to the metamod site and click Make your VDF
and choose Left 4 Dead 2. Download the metamod.vdf put it inside the "../addons/"
folder. Metamod: Source is now installed.


-----------[Step 3 - Install Sourcemod]------------------
http://www.sourcemod.net/downloads.php

If you already have Sourcemod installed, skip this step.
If you are using Nuclear Fallout, instead just install it on the autoinstallers tab of
your control panel.

Download Sourcemod. As with step 2 determine which OS your server runs on and download
that version. Extract the files into the same directory structure of your server.
Sourcemod is now installed.


-----------[Step 4 - Install Stripper: Source]-----------
http://code.google.com/p/metafogl/downloads/list

Download Stripper: Source from the official Metafogl page. Make sure you download the
correct one for your OS (if unsure ask your GSP, for NFO it's probably Windows) and
make sure you use this one and not the one on bailopan.net or elsewhere! Extract the
files into the same directory structure of your server. Stripper: Source is now
installed.


-----------[Step 5 - Install Confogl]--------------------
http://code.google.com/p/metafogl/downloads/list

Download the fixed Confogl from the official Metafogl page. The Confogl package on the
original Confogl download page has some outdated files, do not use it. You want to
download Confogl-2.2.2-FIXED.zip! Extract all of the files into the same directory
structure of your server. Confogl is now installed.


-----------[Step 6 - Install SDK Hooks]------------------
http://forums.alliedmods.net/showthread.php?t=106748

Download SDK Hooks from the Allied Modders forum. Make sure you download the correct
one for your server OS as previous tips suggest. Extract the files into the same
directory structure of your server. Look and make sure the following files don't exist
on your server in the sourcemod folder:

    gamedata/sdkhooks.games.txt
    extensions/sdkhooks.ext.dll
    extensions/sdkhooks.ext.so

If so, delete them. They are left overs of an outdated version of SDK Hooks and will
cause conflicts on your server. SDK Hooks is now installed.


-----------[Step 7 - Install Promod]---------------------
http://code.google.com/p/metafogl/downloads/list

Download Promod from the official Metafogl page. Extract all of the files into the same
directory structure of your server and overwrite anything that it asks to. Promod is
now installed.


-----------[Step 8 - Start Server]-----------------------
Restart your server and connect to it. Once in game type in console "sm version" and
"meta version" to check if both are installed. Try to start a config with !match
whatever. To check plugins are loaded type "sm plugins" and then !resetmatch to see if
it correctly unloads then try another config. Your server is now installed, gg.



===========
Additional:
===========

"Commands like !forcestart and !forcematch aren't working."

If everything else works, you probably need to set admins in sourcemod.
See here: http://wiki.alliedmods.net/Adding_Admins_%28SourceMod%29


"I keep mistyping config names, how do I stop basic confogl from loading on accident?"

Open confogl.cfg and confogl_plugins.cfg in the cfg folder of your server and delete
everything inside. When someone mistypes a config it will give a message but nothing
will be loaded. You can also copy-paste an entire config in cfgogl and rename it to
allow it to be loaded under more than one name (ie, copy-paste metafogl and name it
meta, or copy-paste hunters and rename it hunter4v4)


"I'm finding throwables, map distance issues, or tank are spawning in weird places."

With Pro Mod 2.5, mapinfo.txt is read from each individual config directory instead of
one static location. Make sure you place the mapinfo.txt of any additional configs you
want to use such as EQ in their directory (ie, cfg/cfgogl/eq/mapinfo.txt) instead of
in the old default (addons/sourcemod/configs/l4d2lib/) directory.


"I hear SI spawn sounds as survivor or my SI teammates are invisible as ghosts."

Not really an issue with confogl but I thought I'd include it, outdated SMAC installs
cause these problems. Update your SMAC and the problems should be gone.