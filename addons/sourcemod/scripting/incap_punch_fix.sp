#pragma semicolon 1

#include <sourcemod>

public Plugin:myinfo =
{
	name = "Incap Punch Fix",
	author = "CanadaRox",
	description = "Survivors go flying when they are incapped with a punch!!",
	version = "1",
	url = ""
};

public OnPluginStart()
{
	HookEvent("player_incapacitated", PlayerIncap);
}

public Action:PlayerIncap(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new String:weapon[256];
	GetEventString(event, "weapon", weapon, 256);

	if (StrEqual(weapon, "tank_claw"))
	{
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
		SetEntityHealth(client, 0);
		CreateTimer(0.1, Reincap_Timer, client);
	}
}

public Action:Reincap_Timer(Handle:timer, any:client)
{
	SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
	SetEntityHealth(client, 300);
}
