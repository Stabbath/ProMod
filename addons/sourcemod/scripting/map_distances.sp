#pragma semicolon 1

#include <sourcemod>
#include <left4downtown>
#include <l4d2lib>

public Plugin:myinfo =
{
	name = "Map Distances",
	author = "Stabby",
	description = "Simple plugin that reads max_distance from mapinfo and sets it as the custom max distance for a map. This was pretty much just taken directly from l4d2_scoremod, since it should be in its own plugin, independent of scoring system.",
	version = "1",
	url = "https://github.com/Stabbath/L4D2-Stuff"
};

new bool: g_bL4D2LibAvailable;

public OnAllPluginsLoaded() {
	g_bL4D2LibAvailable = LibraryExists("l4d2lib");
}
 
public OnLibraryRemoved(const String:name[]) {
	if (StrEqual(name, "l4d2lib"))	g_bL4D2LibAvailable = false;
}
 
public OnLibraryAdded(const String:name[]) {
	if (StrEqual(name, "l4d2lib"))	g_bL4D2LibAvailable = true;
}

public OnMapStart() {
	new mapscore = g_bL4D2LibAvailable ? L4D2_GetMapValueInt("max_distance", -1) : -1;
	
	if (mapscore > -1)	L4D_SetVersusMaxCompletionScore(mapscore);
}
