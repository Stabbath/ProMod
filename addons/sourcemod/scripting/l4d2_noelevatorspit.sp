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
#include <sdkhooks>

new Float:block_square[2][3];
new bool:lateLoad;

public Plugin:myinfo =
{
	name = "L4D2 No Elevator Spit",
	author = "ProdigySim & Estoopi",
	description = "Blocks spit damage on c4m2/c4m3 elevators",
	version = "1.0",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
};

public OnPluginStart()
{
	if(lateLoad)
	{
		SetupBlocks();
		for(new cl=1; cl <= MaxClients; cl++)
		{
			if(IsClientInGame(cl))
			{
				SDKHook(cl, SDKHook_OnTakeDamage, stop_spit_dmg);
			}
		}
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	lateLoad=late;
	return APLRes_Success;
}

public OnMapStart()
{
	SetupBlocks();
}

SetupBlocks()
{
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	// todo trie
	// todo not copy vectors
	// todo finish up todos
	// todo psychonc
	if(StrEqual(mapname, "c4m2_sugarmill_a"))
	{
		block_square[0][0] = -1411.940430;
		block_square[0][1] = -9491.997070;
		block_square[1][0] = -1545.875244;
		block_square[1][1] = -9602.097656;
	}
	else if(StrEqual(mapname, "c4m3_sugarmill_b"))
	{
		block_square[0][0] = -1411.940430;
		block_square[0][1] = -9491.997070;
		block_square[1][0] = -1545.875244;
		block_square[1][1] = -9602.097656;
	}
	else if(StrEqual(mapname, "l4d_dbd2dc_clean_up"))
	{
		block_square[0][0] = -4194.448242;
		block_square[0][1] = 3614.163818;
		block_square[1][0] = -4625.936523;
		block_square[1][1] = 3539.908936;
	}
	else if(StrEqual(mapname, "l4d_dbd2dc_undead_center"))
	{
		block_square[0][0] = -6902.102539;
		block_square[0][1] = 8809.659180;
		block_square[1][0] = -7872.751953;
		block_square[1][1] = 8522.269531;
	}
	else
	{
		block_square[0] = NULL_VECTOR;
		block_square[1] = NULL_VECTOR;
	}
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, stop_spit_dmg);
}

public Action:stop_spit_dmg(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(victim <= 0 || victim > MaxClients) return Plugin_Continue;
	if(!IsValidEdict(inflictor)) return Plugin_Continue;
	decl String:sInflictor[64];
	GetEdictClassname(inflictor, sInflictor, sizeof(sInflictor));
	//PrintToChatAll("OnTakeDamage: victim %i attacker %i inflictor %s damage %i type %i", victim, attacker, sInflictor, RoundToNearest(damage), damagetype);
	if(StrEqual(sInflictor, "insect_swarm"))
	{
		decl Float:origin[3];
		GetClientAbsOrigin(victim, origin);
		//PrintToChatAll("%.02f, %.02f  in %.02f, %.02f ; %.02f, %.02f", origin[0], origin[1], block_square[0][0], block_square[0][1], block_square[1][0], block_square[1][1]);
		if(isPointIn2DBox(origin[0], origin[1], block_square[0][0], block_square[0][1], block_square[1][0], block_square[1][1]))
		{
			//PrintToChatAll("BLOCKED");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;	
}

// Is x0,y0 in the box defined by x1,y1 and x2,y2
stock bool:isPointIn2DBox(Float:x0, Float:y0, Float:x1, Float:y1, Float:x2, Float:y2)
{
	if(x1 > x2)
	{
		if(y1 > y2)
		{
			return x0 <= x1 && x0 >= x2 && y0 <= y1 && y0 >= y2;
		}
		else
		{
			return x0 <= x1 && x0 >= x2 && y0 >= y1 && y0 <= y2;
		}
	}
	else
	{
		if(y1 > y2)
		{
			return x0 >= x1 && x0 <= x2 && y0 <= y1 && y0 >= y2;
		}
		else
		{
			return x0 >= x1 && x0 <= x2 && y0 >= y1 && y0 <= y2;
		}
	}
}
