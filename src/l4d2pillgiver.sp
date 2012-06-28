#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <l4d2lib>
 
public Plugin:myinfo =
{
	name = "L4D2 Pill Giver",
	author = "Blade",
	description = "Gives pills to survivors at the start of each round.",
	version = "1.3.3",
	url = "nope"
}

public OnPluginStart()
{
    HookEvent("player_left_start_area", PlayerLeftStartArea);
}

public Action:PlayerLeftStartArea(Handle:event, const String:name[], bool:dontBroadcast)
{
	new flags = GetCommandFlags("give");	
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i)==2) FakeClientCommand(i, "give pain_pills");
	}
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}