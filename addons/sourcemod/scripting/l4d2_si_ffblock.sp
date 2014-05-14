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
#include <sdkhooks>


public Plugin:myinfo = 
{
	name = "L4D2 Infected Friendly Fire Disable",
	author = "ProdigySim, Don",
	description = "Disables friendly fire between infected players.",
	version = "1.2",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}

new bool:lateLoad
new Handle:cvar_ffblock;
new Handle:cvar_allow_tank_ff;

public OnPluginStart()
{
	cvar_ffblock=CreateConVar("l4d2_block_infected_ff", "1", "Disable SI->SI friendly fire");
	cvar_allow_tank_ff=CreateConVar("l4d2_infected_ff_allow_tank", "0", "Do not disable friendly fire for tanks on other SI");
	if(lateLoad)
	{
		for(new cl=1; cl <= MaxClients; cl++)
		{
			if(IsClientInGame(cl))
			{
				SDKHook(cl, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	lateLoad=late;
	return APLRes_Success;
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if(GetConVarBool(cvar_ffblock) && IsClientAndInGame(victim) && GetClientTeam(victim) == 3 && IsClientAndInGame(attacker) && GetClientTeam(attacker) == 3)
	{
		if(!GetConVarBool(cvar_allow_tank_ff) || GetEntProp(attacker, Prop_Send, "m_zombieClass") != 8) // If no tank ff or attacker is not tank
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

bool:IsClientAndInGame(index)
{
	return (index > 0 && index <= MaxClients && IsClientInGame(index));
}
