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
	name = "L4D Inaudible Ghosts",
	author = "AtomicStryker, DieTeeTasse, ProdigySim",
	description = "Keep survivors from hearing jumping infected ghosts.",
	version = "1.0",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}


new isGhostOffset;
public OnPluginStart() {
	isGhostOffset = FindSendPropInfo("CTerrorPlayer", "m_isGhost"); // daHURRDURR
	AddNormalSoundHook(NormalSHook:SoundHook);
}

public Action:SoundHook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity) {
	// infected fall sound and is ghost
	if (StrEqual(sample, "player/jumplanding_zombie.wav") &&
		GetEntData(entity, isGhostOffset))
	{
		// add infected and spectators to array
		numClients = 0;
		for (new i = 1; i < MaxClients+1; i++) {
			if (!IsClientInGame(i)) continue;
			if (IsFakeClient(i)) continue;
			if (GetClientTeam(i) != 3) continue; // team infected
			
			clients[numClients] = i;
			numClients++;
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}