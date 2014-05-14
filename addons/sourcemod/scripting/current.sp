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
#include <l4d2_direct>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

new Handle:hCvarPrintToEveryone;
new Handle:survivor_limit;
new Handle:z_max_player_zombies;

public OnPluginStart()
{
	hCvarPrintToEveryone =
		CreateConVar("l4d_global_percent", "1",
				"Display boss percentages to entire team when using commands",
				FCVAR_PLUGIN);

	RegConsoleCmd("sm_cur", CurrentCmd);
	RegConsoleCmd("sm_current", CurrentCmd);

	survivor_limit = FindConVar("survivor_limit");
	z_max_player_zombies = FindConVar("z_max_player_zombies");
}

public Action:CurrentCmd(client, args)
{
	new L4D2_Team:team = L4D2_Team:GetClientTeam(client);
	if (team == L4D2Team_Spectator)
	{
		PrintCurrentToClient(client);
	}
	else
	{
		if (GetConVarBool(hCvarPrintToEveryone))
		{
			PrintCurrentToTeam(team);
		}
		else
		{
			PrintCurrentToClient(client);
		}
	}
}

stock PrintCurrentToClient(client)
{
	PrintToChat(client, "\x01Current: \x04%d%%", GetMaxSurvivorCompletion());
}

stock PrintCurrentToTeam(L4D2_Team:team)
{
	new members_found;
	new team_max = GetTeamMaxHumans(team);
	new max_completion = GetMaxSurvivorCompletion();
	for (new client = 1;
			client <= MaxClients && members_found < team_max;
			client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client) &&
				L4D2_Team:GetClientTeam(client) == team)
		{
			members_found++;
			PrintToChat(client, "\x01Current: \x04%d%%", max_completion);
		}
	}
}

stock GetMaxSurvivorCompletion()
{
	new Float:flow = 0.0;
	decl Float:tmp_flow;
	decl Float:origin[3];
	decl Address:pNavArea;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) &&
			L4D2_Team:GetClientTeam(client) == L4D2Team_Survivor)
		{
			GetClientAbsOrigin(client, origin);
			pNavArea = L4D2Direct_GetTerrorNavArea(origin);
			if (pNavArea != Address_Null)
			{
				tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
				flow = MAX(flow, tmp_flow);
			}
		}
	}
	return RoundToNearest(flow * 100 / L4D2Direct_GetMapMaxFlowDistance());
}

stock GetTeamMaxHumans(L4D2_Team:team)
{
	if (team == L4D2Team_Survivor)
	{
		return GetConVarInt(survivor_limit);
	}
	else if (team == L4D2Team_Infected)
	{
		return GetConVarInt(z_max_player_zombies);
	}
	return MaxClients;
}
