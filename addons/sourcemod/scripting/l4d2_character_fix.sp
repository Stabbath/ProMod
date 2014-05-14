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

new Handle:hCvarMaxZombies;

public Plugin:myinfo = {
	name = "Character Fix",
	author = "someone",
	version = "0.1",
	description = "Fixes character change exploit in 1v1, 2v2, 3v3"
};

public OnPluginStart() {
	AddCommandListener(TeamCmd, "jointeam")
	hCvarMaxZombies = FindConVar("z_max_player_zombies");
}

public Action:TeamCmd(client, const String:command[], argc) {
	if (client && argc > 0)
	{
		static String:sBuffer[128];
		GetCmdArg(1, sBuffer, sizeof(sBuffer));
		new newteam = StringToInt(sBuffer);
		if (GetClientTeam(client)==2 && (StrEqual("Infected", sBuffer, false) || newteam==3))
		{
			new zombies = 0;
			for (new i=1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i)==3)
					zombies++;
			}
			if (zombies>=GetConVarInt(hCvarMaxZombies))
				return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}