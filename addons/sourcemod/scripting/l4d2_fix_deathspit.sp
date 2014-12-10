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

public Plugin:myinfo = {
    name = "L4D2 Fix Death Spit",
    author = "Jahze",
    description = "Removes invisible death spit",
    version = "1.0",
    url = "https://github.com/Jahze/l4d2_plugins"
}
public OnPluginStart() {
    HookEvent("spitter_killed", SpitterKilledEvent, EventHookMode_PostNoCopy);
}

public SpitterKilledEvent(Handle:event, const String:name[], bool:dontBroadcast) {
    CreateTimer(1.0, FindDeathSpit);
}

public Action:FindDeathSpit(Handle:timer) {
    new entity = -1;

    while ((entity = FindEntityByClassname(entity, "insect_swarm")) != -1) {
        new maxFlames = L4D2Direct_GetInfernoMaxFlames(entity);
        new currentFlames = GetEntProp(entity, Prop_Send, "m_fireCount");

        if (maxFlames == 2 && currentFlames == 2) {
            SetEntProp(entity, Prop_Send, "m_fireCount", 1);
            L4D2Direct_SetInfernoMaxFlames(entity, 1);
        }
    }
}

