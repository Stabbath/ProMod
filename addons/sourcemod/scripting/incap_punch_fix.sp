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
	name = "Incap Punch Fix",
	author = "CanadaRox",
	description = "Survivors go flying when they are incapped with a punch!!",
	version = "1",
	url = ""
};

public OnPluginStart()
{
	HookEvent("player_incapacitated", PlayerIncap);
}

public Action:PlayerIncap(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new String:weapon[256];
	GetEventString(event, "weapon", weapon, 256);

	if (StrEqual(weapon, "tank_claw"))
	{
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
		SetEntityHealth(client, 0);
		CreateTimer(0.1, Reincap_Timer, client);
	}
}

public Action:Reincap_Timer(Handle:timer, any:client)
{
	SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
	SetEntityHealth(client, 300);
}
