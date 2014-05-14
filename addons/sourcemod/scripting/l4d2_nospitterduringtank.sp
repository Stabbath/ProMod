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

public Plugin:myinfo =
{
	name = "No Spitter During Tank",
	author = "Don",
	description = "Prevents the director from giving the infected team a spitter while the tank is alive",
	version = "1.6",
	url = "https://bitbucket.org/DonSanchez/random-sourcemod-stuff"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:sGame[12];
	GetGameFolderName(sGame, sizeof(sGame));
	if (StrEqual(sGame, "left4dead2"))	// Only load the plugin if the server is running Left 4 Dead 2.
	{
		return APLRes_Success;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports L4D2");
		return APLRes_Failure;
	}
}

new bool:g_bIsTankAlive;
new Handle:g_hSpitterLimit;
new g_iOldSpitterLimit;

public OnPluginStart()
{
	HookEvent("tank_spawn", Event_tank_spawn_Callback);
	HookEvent("player_death", Event_player_death_Callback);
	HookEvent("round_end", Event_round_end_Callback);
	g_hSpitterLimit = FindConVar("z_versus_spitter_limit");
}

public Event_tank_spawn_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bIsTankAlive)
	{
		g_iOldSpitterLimit = GetConVarInt(g_hSpitterLimit);
		SetConVarInt(g_hSpitterLimit, 0);
		g_bIsTankAlive = true;
	}
}

public Event_player_death_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bIsTankAlive)
	{
		new String:sVictimName[8];
		GetEventString(event, "victimname", sVictimName, sizeof(sVictimName));
		if (StrEqual(sVictimName, "Tank"))
		{
			new iKiller = GetClientOfUserId(GetEventInt(event, "attacker")); 
			new String:sKillerName[MAX_NAME_LENGTH];
			GetClientName(iKiller, sKillerName, sizeof(sKillerName));
			new iKilled = GetClientOfUserId(GetEventInt(event, "userid"));
			new String:sKilledName[MAX_NAME_LENGTH];
			GetClientName(iKilled, sKilledName, sizeof(sKilledName));
			new String:sWeapon[8];
			GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
			if (!(StrEqual(sKillerName, sKilledName) && StrEqual(sWeapon, "world")))	/* Tank pass from first to second player triggers a player_death event,
													 * this check prevents it from counting as a tank death in this plugin.
													 */
			{
				SetConVarInt(g_hSpitterLimit, g_iOldSpitterLimit);
				g_bIsTankAlive = false;
			}
		}
	}
}

public Event_round_end_Callback(Handle:event, const String:name[], bool:dontBroadcast)		// Needed for when the round ends without the tank dying.
{
	if (g_bIsTankAlive)
	{
		SetConVarInt(g_hSpitterLimit, g_iOldSpitterLimit);
		g_bIsTankAlive = false;
	}
}

public OnPluginEnd()
{
	if (g_bIsTankAlive)
	{
		SetConVarInt(g_hSpitterLimit, g_iOldSpitterLimit);
	}
}
