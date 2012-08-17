#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Float:block_square[2][3];
new bool:lateLoad;

public Plugin:myinfo =
{
	name = "L4D2 No Elevator Spit",
	author = "ProdigySim",
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
