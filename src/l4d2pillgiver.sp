#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

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
	decl entity;
	decl Float:clientOrigin[3];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i)==2)
		{
			entity = CreateEntityByName("weapon_pain_pills");
			GetClientAbsOrigin(i, clientOrigin);
			TeleportEntity(entity, clientOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity);
			EquipPlayerWeapon(i, entity);
		}
	}
}
