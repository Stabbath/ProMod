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
#include <sdktools>

public Plugin:myinfo =
{
	name = "L4D2 Finale Incap Distance Fixifier",
	author = "CanadaRox",
	description = "Kills survivors before the score is calculated so you don't get full distance if you are incapped as the rescue vehicle leaves.",
	version = "1.0",
	url = "https://bitbucket.org/CanadaRox/random-sourcemod-stuff"
};

public OnPluginStart()
{
	HookEvent("finale_vehicle_leaving", FinaleEnd_Event, EventHookMode_PostNoCopy);
}

public FinaleEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	for (new i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerIncap(i))
		{
			ForcePlayerSuicide(i);
		}
	}
}

stock IsPlayerIncap(client) return GetEntProp(client, Prop_Send, "m_isIncapacitated");