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
#include <sdktools>

public Plugin:myinfo = 
{
    name = "AI Tank Gank",
    author = "Stabby",
    version = "0.2",
    description = "Kills tanks on pass to AI."
};

new Handle:hKillOnCrash = INVALID_HANDLE;

public OnPluginStart() 
{
	hKillOnCrash = CreateConVar("tankgank_killoncrash",	"0",
								"If 0, tank will not be killed if the player that controlled it crashes.",
								FCVAR_PLUGIN, true,  0.0, true, 1.0);
	HookEvent("player_bot_replace", OnTankGoneAi);
}

public Action:OnTankGoneAi(Handle:event, const String: name[], bool:dontBroadcast)
{	
	new formerTank = GetClientOfUserId(GetEventInt(event, "player"));
	new newTank = GetClientOfUserId(GetEventInt(event, "bot"));
	
	if (GetClientTeam(newTank) == 3 && GetEntProp(newTank, Prop_Send, "m_zombieClass") == 8)
	{
		if (formerTank == 0 && !GetConVarBool(hKillOnCrash) )	//if people disconnect, formerTank = 0 instead of the old player's id
		{
			CreateTimer(1.0, Timed_CheckAndKill, newTank);
			return;
		}
		ForcePlayerSuicide(newTank);
	}
}

public Action:Timed_CheckAndKill(Handle:unused, any:newTank)
{
	if (IsFakeClient(newTank))
	{
		ForcePlayerSuicide(newTank);		
	}
}
