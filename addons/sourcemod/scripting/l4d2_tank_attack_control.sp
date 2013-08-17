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
	author = "vintik, CanadaRox",
	description = "",
	version = "0.4",
	url = "https://github.com/CanadaRox/sm_plugins"
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
	g_hBlockPunchRock = CreateConVar("l4d2_block_punch_rock", "1", "Block tanks from punching and throwing a rock at the same time");

	HookEvent("tank_spawn", TankSpawn_Event);
}

public TankSpawn_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new tank = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(tank)) return;

	new bool:hidemessage = false;
	decl String:buffer[3];
	if (GetClientInfo(tank, "rs_hidemessage", buffer, sizeof(buffer)))
	{
		hidemessage = bool:StringToInt(buffer);
	}
	if (!hidemessage)
	{
		PrintToChat(tank, "[SM] Rock Selector");
		PrintToChat(tank, "Use -> Underhand throw");
		PrintToChat(tank, "Reload -> One hand overhand");
		PrintToChat(tank, "Melee -> Two hand overhand");
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 3
		|| GetEntProp(client, Prop_Send, "m_zombieClass") != 8)
			return Plugin_Continue;
	//if tank
	if (buttons & IN_RELOAD)
	{
		g_iQueuedThrow[client] = 1;
		buttons |= IN_ATTACK2;
	}
	else if (buttons & IN_USE)
	{
		g_iQueuedThrow[client] = 2;
		buttons |= IN_ATTACK2;
	}
	else
	{
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
