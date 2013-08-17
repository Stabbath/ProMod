#include <sourcemod>
#include <left4downtown>

//requires at least left4downtown2 v0.5.4
//throw sequences:
//48 - (not used unless tank_rock_overhead_percent is changed)

//49 - 1handed overhand (MOUSE2+R),
//50 - underhand (MOUSE2+E),
//51 - 2handed overhand (MOUSE2)

new g_iQueuedThrow[MAXPLAYERS + 1];
new Handle:g_hBlockPunchRock = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "Tank Attack Control",
	author = "vintik",
	description = "",
	version = "0.3",
	url = "https://github.com/thevintik/sm_plugins"
}

public OnPluginStart()
{
	decl String:sGame[256];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "left4dead2", false))
	{
		SetFailState("Plugin supports Left 4 dead 2 only!");
	}
	
	//future-proof remake of the confogl feature (could be used with lgofnoc)
	g_hBlockPunchRock = CreateConVar("l4d2_block_punch_rock", "0", "Block tanks from punching and throwing a rock at the same time");
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 3
		|| GetEntProp(client, Prop_Send, "m_zombieClass") != 8)
			return Plugin_Continue;
	//if tank
	if ((buttons | IN_ATTACK2) !=0 )
	{
		if (buttons & IN_RELOAD)
			g_iQueuedThrow[client] = 1;
		else if (buttons & IN_USE)
			g_iQueuedThrow[client] = 2;
		else
			g_iQueuedThrow[client] = 3;
	}
	return Plugin_Continue;
}

public Action:L4D_OnCThrowActivate(ability)
{
	if (!IsValidEntity(ability))
	{
		LogMessage("Invalid 'ability_throw' index: %d. Continuing throwing.", ability);
		return Plugin_Continue;
	}
	new client = GetEntPropEnt(ability, Prop_Data, "m_hOwnerEntity");
	
	if (GetClientButtons(client) & IN_ATTACK)
	{
		if (GetConVarBool(g_hBlockPunchRock))
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:L4D2_OnSelectTankAttack(client, &sequence)
{
	if (sequence > 48 && g_iQueuedThrow[client])
	{
		//rock throw
		sequence = g_iQueuedThrow[client] + 48;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
