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

#define L4D2UTIL_STOCKS_ONLY

#include <sourcemod>
#include <sdktools>
#include <l4d2util>

new Float:fLedgeHangInterval;
new Handle:hCvarJockeyLedgeHang;

public Plugin:myinfo = {
    name = "L4D2 Jockey Ledge Hang Recharge",
    author = "Jahze",
    version = "1.0",
    description = "Adds a cvar to adjust the recharge timer of a jockey after he ledge hangs a survivor."
};

public OnPluginStart() {
    hCvarJockeyLedgeHang = CreateConVar("z_leap_interval_post_ledge_hang", "10", "How long before a jockey can leap again after a ledge hang");
    HookConVarChange(hCvarJockeyLedgeHang, JockeyLedgeHangChange);
    
    fLedgeHangInterval = GetConVarFloat(hCvarJockeyLedgeHang);
    
    PluginEnable();
}

PluginEnable() {
    HookEvent("jockey_ride_end", JockeyRideEnd);
}

public JockeyLedgeHangChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) {
    fLedgeHangInterval = StringToFloat(newValue);
}

public Action:JockeyRideEnd(Handle:hEvent, const String:name[], bool:bDontBroadcast) {
    new jockeyAttacker = GetClientOfUserId(GetEventInt(hEvent, "userid"));
    new jockeyVictim = GetClientOfUserId(GetEventInt(hEvent, "victim"));
    
    if (IsHangingFromLedge(jockeyVictim)) {
        FixupJockeyTimer(jockeyAttacker);
    }
}

FixupJockeyTimer(client) {
    new iEntity = -1;
    
    while ((iEntity = FindEntityByClassname(iEntity, "ability_leap")) != -1) {
        if (GetEntPropEnt(iEntity, Prop_Send, "m_owner") == client) {
            break;
        }
    }
    
    if (iEntity == -1) {
        return;
    }
    
    SetEntPropFloat(iEntity, Prop_Send, "m_timestamp", GetGameTime() + fLedgeHangInterval);
    SetEntPropFloat(iEntity, Prop_Send, "m_duration", fLedgeHangInterval);
}

