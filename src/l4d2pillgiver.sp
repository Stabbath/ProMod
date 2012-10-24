#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "L4D2 Pill Giver",
	author = "Blade, CircleSquared",
	description = "Gives pills or kits to survivors at the start of each round.",
	version = "1.4",
	url = "nope"
}

new Handle:hCvarHealthType;

public OnPluginStart()
{
	hCvarHealthType = CreateConVar("pg_health_type", "1", "Type of health given when leaving saferoom (0 = none, 1 = pills, 2 = adren, 3 = kits)", FCVAR_PLUGIN);
	HookEvent("player_left_start_area", PlayerLeftStartArea);
}

public Action:PlayerLeftStartArea(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl entity;
	decl Float:clientOrigin[3];
	if (GetConVarInt(hCvarHealthType) > 0) {
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i)==2)
			{
				if(GetConVarInt(hCvarHealthType) == 1) {
					entity = CreateEntityByName("weapon_pain_pills");
				}
				else if(GetConVarInt(hCvarHealthType) == 2) {
					entity = CreateEntityByName("weapon_adrenaline");
				}
				else {
					entity = CreateEntityByName("weapon_first_aid_kit");
				}
				GetClientAbsOrigin(i, clientOrigin);
				TeleportEntity(entity, clientOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(entity);
				EquipPlayerWeapon(i, entity);
			}
		}
	}
}