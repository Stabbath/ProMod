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

new bool:	BK_bAllowBot 	= false;
new bool:	BK_bEnable 		= true;
new Handle:	BK_hEnable;

public Plugin:myinfo = 
{
	name = "Bot Kick",
	author = "LGOFNOC Team",
	description = "Prevents infected bots from joining, minus when tank spawns",
	version = "1.0",
	url = "http://github.com/stabbath/promod"
}

public OnPluginStart()
{
	HookEvent("tank_spawn", BK_TankSpawn);
	
	BK_hEnable = CreateConVar("blockinfectedbots","1","Blocks infected bots from joining the game, minus when a tank spawns (allows players to spawn a AI infected first before taking control of the tank)");
	HookConVarChange(BK_hEnable,BK_ConVarChange);
	
	BK_bEnable = GetConVarBool(BK_hEnable);
}

public BK_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	BK_bEnable = GetConVarBool(BK_hEnable);
}

public BK_TankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	BK_bAllowBot = true;
}

public bool:OnClientConnect(client, String:rejectmsg[],maxlen)
{
	if(!IsFakeClient(client) || !BK_bEnable)
	{
		return true;
	}
	
	decl String:name[10];
	GetClientName(client, name, sizeof(name));
	
	if(StrContains(name, "smoker", false) == -1 && 
		StrContains(name, "boomer", false) == -1 && 
		StrContains(name, "hunter", false) == -1 && 
		StrContains(name, "spitter", false) == -1 && 
		StrContains(name, "jockey", false) == -1 && 
		StrContains(name, "charger", false) == -1)
	{
		return true;
	}
	
	if(BK_bAllowBot)
	{
		BK_bAllowBot = false;
		return true;
	}
	
	KickClient(client,"Kicking infected bot...");
	
	return false;
}
