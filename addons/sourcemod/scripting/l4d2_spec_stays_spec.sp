/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

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
*/
#include <sourcemod>
#pragma semicolon 1

#define ACTIVE_SECONDS 	120
/*
 * Debug modes:
 * 0 = disabled
 * 1 = server console
 * 2 = fileoutput "l4d2_spec_stays_spec.txt"
 */
#define DEBUG_MODE 0
#define MAX_SPECTATORS 	24
#define PLUGIN_VERSION 	"1.0"
#define STEAMID_LENGTH 	32

/*
 * plugin info
 * #######################
 */
public Plugin:myinfo =
{
	name = "Spectator stays spectator",
	author = "Die Teetasse",
	description = "Spectator will stay as spectators on mapchange.",
	version = PLUGIN_VERSION,
	url = ""
};

/*
 * global variables
 * #######################
 */
new lastTimestamp = 0;
new spectatorCount = 0;
new Handle:spectatorTimer[MAX_SPECTATORS];
new String:spectatorSteamIds[MAX_SPECTATORS][STEAMID_LENGTH];

/*
 * plugin start - check game
 * #######################
 */
public OnPluginStart() {
	decl String:gameFolder[12];
	GetGameFolderName(gameFolder, sizeof(gameFolder));
	if (StrContains(gameFolder, "left4dead") == -1) SetFailState("Spec stays spec work with Left 4 Dead 1 or 2 only!");
}

/*
 * map start - hook event
 * #######################
 */
public OnMapStart() {
	HookEvent("round_end", Event_Round_End);
}

/*
 * round end event - save spec steamids
 * #######################
 */
public Action:Event_Round_End(Handle:event, const String:name[], bool:dontBroadcast) {
	spectatorCount = 0;
	
	// clear arrays and kill timers
	for (new i = 0; i < MAX_SPECTATORS; i++) {
		spectatorSteamIds[i] = "";
		
		if (spectatorTimer[i] != INVALID_HANDLE) {
			KillTimer(spectatorTimer[i]);
			spectatorTimer[i] = INVALID_HANDLE;
		}
	}
	
	// get steamids
	for (new i = 1; i < MaxClients; i++) {
		if (!IsClientInGame(i)) continue;
		if (GetClientTeam(i) != 1) continue;
		
		GetClientAuthString(i, spectatorSteamIds[spectatorCount], STEAMID_LENGTH);
		spectatorCount++;
	}	
	
	// set timestamp
	lastTimestamp = GetTime();
	
	return Plugin_Continue;
}

/*
 * client authorisation - check and create timer if neccessary
 * #######################
 */
public OnClientAuthorized(client, const String:auth[]) {
	// get timestamp
	new currentTimestamp = GetTime();
	
	// check timestamp
	if ((currentTimestamp - lastTimestamp) > ACTIVE_SECONDS) return;
	
	// find steamid
	new index = Function_GetIndex(auth);
	if (index == -1) return;
	
	// create move timer
	spectatorTimer[index] = CreateTimer(1.0, Timer_MoveToSpec, client, TIMER_REPEAT);
}

/*
 * move to spec timer - checks for ingame and move the client
 * #######################
 */
public Action:Timer_MoveToSpec(Handle:timer, any:client) {
	// check ingame - if not => repeat
	if (!IsClientInGame(client)) return Plugin_Continue;

	// get steamid
	new String:auth[STEAMID_LENGTH];
	GetClientAuthString(client, auth, STEAMID_LENGTH);
	
	// find index
	new index = Function_GetIndex(auth);
	
	// check index (this should not happen^^)
	if (index == -1) return Plugin_Stop;
	
	// reset timer handle
	spectatorTimer[index] = INVALID_HANDLE;
	
	// check team - if already spec => stop
	new team = GetClientTeam(client);
	if (team == 1) return Plugin_Stop;
	
	// get client name
	decl String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	
	// change team and stop
	ChangeClientTeam(client, 1);
	PrintToChatAll("[SM] Found %s in %s team. Moved him back to spec team.", name, (team == 2) ? "survivor" : "infected");
	
	return Plugin_Stop;
}

/*
 * client disconnect - stop timer
 * #######################
 */
public OnClientDisconnect(client) {
	// get steamid
	new String:clientSteamId[STEAMID_LENGTH];
	GetClientAuthString(client, clientSteamId, STEAMID_LENGTH);
	
	// find index
	new index = Function_GetIndex(clientSteamId);
	
	// check index
	if (index == -1) return;
	
	// check timer
	if (spectatorTimer[index] == INVALID_HANDLE) return;
	
	// kill timer
	KillTimer(spectatorTimer[index]);
	spectatorTimer[index] = INVALID_HANDLE;
}

/*
 * private function - find steamid in array and return index
 * #######################
 */
Function_GetIndex(const String:clientSteamId[]) {
	// loop through steamids
	for (new i = 0; i < spectatorCount; i++) {
		if (StrEqual(spectatorSteamIds[i], clientSteamId)) return i;	
	}
	
	return -1;
}