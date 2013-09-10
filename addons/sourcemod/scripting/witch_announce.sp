#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

public Plugin:myinfo =
{
	name = "Witch Announce++",
	author = "CanadaRox",
	description = "Prints damage done to witches!",
	version = "1",
	url = ""
};

enum clientDamageEnum
{
	CDE_client,
	CDE_damage
};

new Handle:z_witch_health;
new Handle:witchTrie;
new bool:g_bLateLoad;

public APLRes:AskPluginLoad2(Handle:plugin, bool:late, String:error[], errMax)
{
	g_bLateLoad = late;
}

public OnPluginStart()
{
	witchTrie = CreateTrie();

	HookEvent("witch_spawn", WitchSpawn_Event);
	HookEvent("witch_killed", WitchKilled_Event);

	z_witch_health = FindConVar("z_witch_health");

	if (g_bLateLoad)
	{
		for (new client = 1; client < MaxClients + 1; client++)
		{
			if (IsClientInGame(client))
			{
				SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public WitchSpawn_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new witch = GetEventInt(event, "witchid");
	SDKHook(witch, SDKHook_OnTakeDamagePost, OnTakeDamage_Post);

	new witch_dmg_array[MAXPLAYERS+2];
	decl String:witch_key[10];
	FormatEx(witch_key, sizeof(witch_key), "%x", witch);
	witch_dmg_array[MAXPLAYERS+1] = GetConVarInt(z_witch_health);
	SetTrieArray(witchTrie, witch_key, witch_dmg_array, MAXPLAYERS+2, false);
}

public WitchKilled_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new witch = GetEventInt(event, "witchid");
	SDKUnhook(witch, SDKHook_OnTakeDamagePost, OnTakeDamage_Post);
	PrintWitchDamageAndRemove(witch);
}

public OnEntityDestroyed(entity)
{
	SDKUnhook(entity, SDKHook_OnTakeDamagePost, OnTakeDamage_Post);
	decl String:witch_key[10];
	FormatEx(witch_key, sizeof(witch_key), "%x", entity);
	RemoveFromTrie(witchTrie, witch_key);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (victim > 0 && victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == 2)
	{
		decl String:classname[64];
		GetEdictClassname(attacker, classname, sizeof(classname));
		if (StrEqual(classname, "witch"))
		{
			/* This assumes that a "fail" happens when a witch hits a non-incap */
			if (!IsPlayerIncap(victim))
			{
				PrintWitchDamageAndRemove(attacker);
			}
		}
	}
}

public OnTakeDamage_Post(victim, attacker, inflictor, Float:damage, damagetype)
{
	decl String:classname[64];
	GetEdictClassname(victim, classname, sizeof(classname));
	if (StrEqual(classname, "witch"))
	{
		decl String:witch_key[10];
		FormatEx(witch_key, sizeof(witch_key), "%x", victim);
		decl witch_dmg_array[MAXPLAYERS+2]; /* index 0: infected damage, index MAXPLAYERS+1: witch health */
		if (!GetTrieArray(witchTrie, witch_key, witch_dmg_array, MAXPLAYERS+2))
		{
			for (new i = 0; i <= MAXPLAYERS; i++)
			{
				witch_dmg_array[i] = 0;
			}
			witch_dmg_array[MAXPLAYERS+1] = GetConVarInt(z_witch_health);
			SetTrieArray(witchTrie, witch_key, witch_dmg_array, MAXPLAYERS+2, false);
		}
		if (attacker > 0 && attacker <= MAXPLAYERS && IsClientInGame(attacker))
		{
			witch_dmg_array[GetClientTeam(attacker) == 3 ? 0 : attacker] += RoundToFloor(damage);
			witch_dmg_array[MAXPLAYERS+1] -= RoundToFloor(damage);
			SetTrieArray(witchTrie, witch_key, witch_dmg_array, MAXPLAYERS+2, true);
		}
	}
}

PrintWitchDamageAndRemove(witch)
{
	decl witch_dmg_array[MAXPLAYERS+2];
	new Handle:damage_array = CreateArray(2);
	decl clientDamageEnum:current_client[clientDamageEnum];

	decl String:witch_key[10];
	FormatEx(witch_key, sizeof(witch_key), "%x", witch);
	if (GetTrieArray(witchTrie, witch_key, witch_dmg_array, MAXPLAYERS+2))
	{
		for (new client = 1; client <= MAXPLAYERS; client++)
		{
			if (witch_dmg_array[client] > 0)
			{
				current_client[CDE_client] = client;
				current_client[CDE_damage] = witch_dmg_array[client];
				PushArrayArray(damage_array, current_client[0]);
			}
		}
		SortADTArrayCustom(damage_array, sortFunc);
		new array_size = GetArraySize(damage_array);
		new witch_health = GetConVarInt(z_witch_health);
		new witch_remaining_health = witch_dmg_array[MAXPLAYERS+1];
		if (witch_remaining_health > 0)
		{
			PrintToChatAll("\x01[SM] The witch had \x05%d\x01 [\x05%d%%\x01] health left!", witch_remaining_health, witch_remaining_health*100/witch_health);
		}
		else
		{
			PrintToChatAll("\x01[SM] The witch has been killed!");
		}
		for (new i = 0; i < array_size; i++)
		{
			GetArrayArray(damage_array, i, current_client);
			if (IsClientInGame(current_client[CDE_client]))
			{
				PrintToChatAll("\x03%N: \x05%d\x01 [\x05%d%%\x01]", current_client[CDE_client], current_client[CDE_damage], current_client[CDE_damage]*100/witch_health);
			}
			else
			{
				PrintToChatAll("\x03Unknown: \x05%d\x01 [\x05%d%%\x01]", current_client[CDE_damage], current_client[CDE_damage]*100/witch_health);
			}
		}
		if (witch_dmg_array[0])
		{
			PrintToChatAll("\x03Infected: \x05%d\x01 [\x05%d%%\x01]", witch_dmg_array[0], witch_dmg_array[0]*100/witch_health);
		}
	}
	SDKUnhook(witch, SDKHook_OnTakeDamagePost, OnTakeDamage_Post);
	RemoveFromTrie(witchTrie, witch_key);
	ClearArray(damage_array);
}

public sortFunc(index1, index2, Handle:array, Handle:hndl)
{
	decl item1[2];
	GetArrayArray(array, index1, item1, 2);

	decl item2[2];
	GetArrayArray(array, index2, item2, 2);

	if (item1[1] > item2[1])
		return -1;
	else if (item1[1] < item2[1])
		return 1;
	else
		return 0;
}

stock bool:IsPlayerIncap(client) return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated");
