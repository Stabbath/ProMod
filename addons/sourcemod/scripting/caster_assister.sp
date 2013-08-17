#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "Caster Assister",
	author = "CanadaRox",
	description = "Allows spectators to control their own specspeed and move vertically",
	version = "1",
	url = ""
};

new Float:currentMulti[MAXPLAYERS+1] = { 1.0, ... };
new Float:currentIncrement[MAXPLAYERS+1] = { 0.1, ... };
new Float:verticalIncrement[MAXPLAYERS+1] = { 10.0, ... };

public OnPluginStart()
{
	RegConsoleCmd("sm_set_specspeed_mutli", SetSpecspeed_Cmd);
	RegConsoleCmd("sm_set_specspeed_increment", SetSpecspeedIncrement_Cmd);
	RegConsoleCmd("sm_increase_specspeed", IncreaseSpecspeed_Cmd);
	RegConsoleCmd("sm_decrease_specspeed", DecreaseSpecspeed_Cmd);
	RegConsoleCmd("sm_set_vertical_increment", SetVerticalIncrement_Cmd);

	HookEvent("player_team", PlayerTeam_Event);
}

public PlayerTeam_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new team = GetEventInt(event, "team");
	if (team == 1)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", currentMulti[client]);
	}
}

public OnClientAuthorized(client, const String:auth[])
{
	decl String:buffer[10];
	if (GetClientInfo(client, "specspeed_multi", buffer, sizeof(buffer)))
	{
		currentMulti[client] = StringToFloat(buffer);
	}
	if (GetClientInfo(client, "specspeed_increment", buffer, sizeof(buffer)))
	{
		currentIncrement[client] = StringToFloat(buffer);
	}
	if (GetClientInfo(client, "specspeed_vert_increment", buffer, sizeof(buffer)))
	{
		verticalIncrement[client] = StringToFloat(buffer);
	}
}

public OnClientDisconnect(client)
{
	currentMulti[client] = 1.0;
	currentIncrement[client] = 0.1;
}

public Action:SetSpecspeed_Cmd(client, args)
{
	if (GetClientTeam(client) != 1)
	{
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "Usage: sm_set_specspeed_multi # (default: 1.0)");
		return Plugin_Handled;
	}
	decl String:buffer[10];
	GetCmdArg(1, buffer, sizeof(buffer));
	new Float:newVal = StringToFloat(buffer);
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", newVal);
	currentMulti[client] = newVal;
	return Plugin_Handled;
}

public Action:SetSpecspeedIncrement_Cmd(client, args)
{
	if (GetClientTeam(client) != 1)
	{
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "Usage: sm_set_specspeed_increment # (default: 0.1)");
		return Plugin_Handled;
	}
	decl String:buffer[10];
	GetCmdArg(1, buffer, sizeof(buffer));
	currentIncrement[client] = StringToFloat(buffer);
	return Plugin_Handled;
}

public Action:IncreaseSpecspeed_Cmd(client, args)
{
	if (GetClientTeam(client) != 1)
	{
		return Plugin_Handled;
	}

	IncreaseSpecspeed(client, currentIncrement[client]);
	return Plugin_Handled;
}

public Action:DecreaseSpecspeed_Cmd(client, args)
{
	if (GetClientTeam(client) != 1)
	{
		return Plugin_Handled;
	}

	IncreaseSpecspeed(client, -currentIncrement[client]);
	return Plugin_Handled;
}

stock IncreaseSpecspeed(client, Float:difference)
{
	new Float:curVal = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", curVal + difference);
	currentMulti[client] = curVal + difference;
}

public Action:SetVerticalIncrement_Cmd(client, args)
{
	if (GetClientTeam(client) != 1)
	{
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "Usage: sm_set_vertical_increment # (default: 10.0)");
		return Plugin_Handled;
	}
	decl String:buffer[10];
	GetCmdArg(1, buffer, sizeof(buffer));
	verticalIncrement[client] = StringToFloat(buffer);
	return Plugin_Handled;
}

public Action:OnPlayerRunCmd(client, &buttons)
{
	if (GetClientTeam(client) == 1)
	{
		if (buttons & IN_USE)
		{
			MoveUp(client, verticalIncrement[client]);
		}
		else if (buttons & IN_RELOAD)
		{
			MoveUp(client, -verticalIncrement[client]);
		}
	}
}

stock MoveUp(client, Float:distance)
{
	decl Float:origin[3];
	GetClientAbsOrigin(client, origin);
	origin[2] += distance;
	TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
}
