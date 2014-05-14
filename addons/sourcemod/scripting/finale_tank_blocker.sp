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
#include <left4downtown>

#define FINALE_STAGE_TANK 8

public Plugin:myinfo =
{
	name = "Finale Even-Numbered Tank Blocker",
	author = "Stabby",
	description = "Blocks even-numbered non-flow finale tanks.",
	version = "1",
	url = "nourl"
};

new iTankCount[2];

public Action:L4D2_OnChangeFinaleStage(&finaleType, const String:arg[]) {
	if (finaleType == FINALE_STAGE_TANK) {
		if (++iTankCount[GameRules_GetProp("m_bInSecondHalfOfRound")] % 2 == 0) return Plugin_Handled;
	}
	return Plugin_Continue;
}

public OnMapEnd() {
	iTankCount[0] = 0;
	iTankCount[1] = 0;
}
