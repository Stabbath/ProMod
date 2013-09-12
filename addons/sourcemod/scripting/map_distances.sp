#pragma semicolon 1

#include <sourcemod>
#include <left4downtown>
#include <lgofnoc>

public Plugin:myinfo =
{
	name = "Map Distances",
	author = "Stabby",
	description = "Simple plugin that reads max_distance from mapinfo and sets it as the custom max distance for a map.",
	version = "2",
	url = "https://github.com/Stabbath/ProMod"
};

new bool: g_bLGOAvailable;

public OnAllPluginsLoaded() {
	g_bLGOAvailable = LibraryExists("lgofnoc");
}

public OnLibraryRemoved(const String:name[]) {
	if (StrEqual(name, "lgofnoc"))	g_bLGOAvailable = false;
}

public OnLibraryAdded(const String:name[]) {
	if (StrEqual(name, "lgofnoc"))	g_bLGOAvailable = true;
}

public OnMapStart() {
	new mapscore = g_bLGOAvailable ? LGO_GetMapValueInt("max_distance", -1) : -1;
	
	if (mapscore >= 0)	L4D_SetVersusMaxCompletionScore(mapscore);
}
