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
#pragma semicolon 1

#include <sourcemod>

new         iDefaultCommonLimit;
new Handle: hCvarCommonLimit;
new Handle: hCvarStarterCommonLimit;
new bool:   bGameStarted;
new bool:   bInRound;

public Plugin:myinfo = {
	name = "L4D2 Starter Common",
	author = "Stabby, original by Blade",
	description = "Decreases amount of common before leaving the saferoom to a cvar'd value, and then increases it to the normal value upon leaving saferoom.",
	version = "3",
	url = "nope"
}

public OnPluginStart() {
	hCvarCommonLimit = FindConVar("z_common_limit");
	hCvarStarterCommonLimit = CreateConVar("z_starting_common_limit", "0", "Common limit to have in place before survivors leave saferoom.", FCVAR_PLUGIN, true, 0.0, false);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_left_start_area", Event_PlayerLeftStartArea);
}

public OnPluginEnd() {
	SetConVarInt(hCvarCommonLimit, iDefaultCommonLimit);
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	bInRound = false;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!bGameStarted) {
        	bGameStarted = true;
	        iDefaultCommonLimit = GetConVarInt(hCvarCommonLimit);
	}

	if (!bInRound) CreateTimer(1.0, Timed_PostRoundStart, _, TIMER_FLAG_NO_MAPCHANGE);

	bInRound = true;
}

public Action:Timed_PostRoundStart(Handle:timer) {
    SetConVarInt(hCvarCommonLimit, GetConVarInt(hCvarStarterCommonLimit));
}

public Action:Event_PlayerLeftStartArea(Handle:event, const String:name[], bool:dontBroadcast) {
	if (GetClientTeam(GetClientOfUserId(GetEventInt(event, "userid"))) == 2)
            SetConVarInt(hCvarCommonLimit, iDefaultCommonLimit);
}

// vim: ts=4 sw=4 et
