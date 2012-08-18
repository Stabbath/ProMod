#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define WP_PAIN_PILLS 15
#define WP_ADRENALINE 23

new iBotHad[MAXPLAYERS + 1];

public Plugin:myinfo = 
{
	name = "Simplified Bot Pop Stop",
	author = "Stabby & CanadaRox",
	description = "Removes pills from bots if they try to use them and restores them when a human takes over.",
	version = "1.2",
	url = "no url"
}

public OnPluginStart()
{
	HookEvent("weapon_fire",Event_WeaponFire);
	HookEvent("bot_player_replace",Event_PlayerJoined);
}

// Take pills from the bot before they get used
public Action:Event_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client   = GetClientOfUserId(GetEventInt(event,"userid"));
	new weaponid = GetEventInt(event,"weaponid");

	if (IsFakeClient(client) && (weaponid == WP_PAIN_PILLS || weaponid == WP_ADRENALINE))
	{
		iBotHad[client] = weaponid;
		RemovePlayerItem(client, GetPlayerWeaponSlot(client,4));
	}

}

// Give the human player the pills back when they join
public Action:Event_PlayerJoined(Handle:event, const String:name[], bool:dontBroadcast)
{
	new leavingBot = GetClientOfUserId(GetEventInt(event,"bot"));

	if (iBotHad[leavingBot])
	{
		RestoreItem(GetClientOfUserId(GetEventInt(event, "player")), leavingBot);
		iBotHad[leavingBot] = 0;
	}
}

RestoreItem(client, leavingBot)
{
	// manually create entity and the equip it since GivePlayerItem() doesn't work in L4D2
	new entity = CreateEntityByName(iBotHad[leavingBot] == WP_PAIN_PILLS ? "weapon_pain_pills" : "weapon_adrenaline");
	decl Float:clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	TeleportEntity(entity, clientOrigin, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	EquipPlayerWeapon(client, entity);
}
