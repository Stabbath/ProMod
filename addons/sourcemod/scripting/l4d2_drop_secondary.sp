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

#define L4D2UTIL_STOCKS_ONLY 1

#include <sourcemod>
#include <sdkhooks>
#include <l4d2util>

new g_PlayerSecondaryWeapons[MAXPLAYERS+1] = -1;

public Plugin:myinfo =
{
    name        = "L4D2 Drop Secondary",
    author      = "Jahze",
    version     = "1.0",
    description = "Survivor players will drop their secondary weapon when they die"
}

public OnPluginStart() {
    HookEvent("round_start", ClearSecondarys);
    HookEvent("player_use", StoreWeapon);
    HookEvent("player_bot_replace", BotWeaponSwap);
    HookEvent("bot_player_replace", BotWeaponSwap);
    HookEvent("player_death", PlayerDeath);
    HookEvent("player_left_start_area", InitialStoreWeapons);
}

public ClearSecondarys(Handle:event, const String:name[], bool:dontBroadcast) {
    for (new i = 0; i < MAXPLAYERS+1; ++i) {
        g_PlayerSecondaryWeapons[i] = -1;
    }
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || client > MaxClients+1) {
        return;
    }

    if (! IsClientInGame(client) || ! IsSurvivor(client)) {
        return;
    }

    new weapon = g_PlayerSecondaryWeapons[client] ;
    if (weapon != -1) {
        SDKHooks_DropWeapon(client, EntRefToEntIndex(weapon));
    }
}

public Action:StoreWeapon(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || client > MaxClients+1) {
        return;
    }

    StoreWeaponForClient(client);
}

public Action:BotWeaponSwap(Handle:event, const String:name[], bool:dontBroadcast) {
    new bot = GetClientOfUserId(GetEventInt(event, "bot"));
    new player = GetClientOfUserId(GetEventInt(event, "player"));

    if (bot <= 0 || player <= 0 || bot > MaxClients+1 || player > MaxClients+1) {
        return;
    }

    if (StrEqual(name, "player_bot_replace")) {
        g_PlayerSecondaryWeapons[bot] = g_PlayerSecondaryWeapons[player];
        g_PlayerSecondaryWeapons[player] = -1;
    }
    else {
        g_PlayerSecondaryWeapons[player] = g_PlayerSecondaryWeapons[bot];
        g_PlayerSecondaryWeapons[bot] = -1;
    }
}

public Action:InitialStoreWeapons(Handle:event, const String:name[], bool:dontBroadcast) {
    for (new i = 1; i < MaxClients+1; ++i) {
        if (IsClientInGame(i) && IsSurvivor(i)) {
            StoreWeaponForClient(i);
        }
    }
}

static StoreWeaponForClient(client) {
    new weapon = GetPlayerWeaponSlot(client, 1);
    g_PlayerSecondaryWeapons[client] = weapon == -1 ? weapon : EntIndexToEntRef(weapon);
}
