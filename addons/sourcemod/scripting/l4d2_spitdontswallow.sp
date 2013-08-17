#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <l4d2_direct>

#define GAMEDATA_FILE       "l4d2_zcs"
#define TEAM_SURVIVOR       2
#define TEAM_INFECTED       3

enum ZombieClass
{
	ZC_NONE = 0,
	ZC_SMOKER,
	ZC_BOOMER,
	ZC_HUNTER,
	ZC_SPITTER,
	ZC_JOCKEY,
	ZC_CHARGER,
	ZC_WITCH,
	ZC_TANK,
	ZC_NOTINFECTED
};

public Plugin:myinfo =
{
	name = "L4D2 Spit Don't Swallow",
	author = "CanadaRox",
	description = "Allows infected to swap out any SI for a spitter",
	version = "1",
	url = ""
};

// SDKTools stuff
new Handle:g_hSetClass;
new Handle:g_hCreateAbility;
new Handle:g_hGameConf;
new g_oAbility;

new bool:isTankUp;
new Handle:z_versus_spitter_limit;
new Handle:versus_special_respawn_interval;
new oldSpitterLimit;

public OnPluginStart()
{
	g_hGameConf = LoadGameConfigFile(GAMEDATA_FILE);
	if (g_hGameConf == INVALID_HANDLE)
		SetFailState("Spit Don't Swallow Error: Unable to load gamedata file");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "SetClass");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSetClass = EndPrepSDKCall();
	if (g_hSetClass == INVALID_HANDLE)
		SetFailState("Spit Don't Swallow Error: Unable to to find SetClass signature.");

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CreateAbility");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hCreateAbility = EndPrepSDKCall();
	if (g_hCreateAbility == INVALID_HANDLE)
		SetFailState("Spit Don't Swallow Error: Unable to find CreateAbility signature.");

	g_oAbility = GameConfGetOffset(g_hGameConf, "oAbility");

	CloseHandle(g_hGameConf);

	HookEvent("round_end", RoundEnd_Event, EventHookMode_PostNoCopy);
	HookEvent("tank_spawn", TankSpawn_Event);
	HookEvent("player_death", PlayerDeath_Event);

	z_versus_spitter_limit = FindConVar("z_versus_spitter_limit");
	versus_special_respawn_interval = FindConVar("versus_special_respawn_interval");
}

public RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	isTankUp = true;
	SetConVarInt(z_versus_spitter_limit, oldSpitterLimit);
}

public TankSpawn_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!isTankUp)
	{
		isTankUp = true;
		oldSpitterLimit = GetConVarInt(z_versus_spitter_limit);
		SetConVarInt(z_versus_spitter_limit, 0);
	}
}

public PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && client <= MaxClients && IsPlayerZombie(client)
			&& GetZombieClass(client) == ZC_TANK)
	{
		new bool:foundTank = false;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (client != i && IsClientInGame(i) && IsPlayerZombie(client)
					&& GetZombieClass(i) == ZC_TANK)
			{
				foundTank = true;
				break;
			}
		}
		if (!foundTank)
		{
			isTankUp = false;
			SetConVarInt(z_versus_spitter_limit, oldSpitterLimit);
		}
	}
}

public Action:OnPlayerRunCmd(client, &buttons)
{
	if (!IsFakeClient(client) && isTankUp && IsPlayerAlive(client) && IsPlayerZombie(client)
			&& IsPlayerGhost(client) && buttons & IN_ZOOM
			&& L4D2_ITimerGetElapsedTime(L4D2IT_SpitterDeathTimer)
			> GetConVarFloat(versus_special_respawn_interval)
			&& CurrentSpitters() < oldSpitterLimit)
	{
		SetZombieClass(client, ZC_SPITTER);
	}
}

stock CurrentSpitters()
{
	new count = 0;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && IsPlayerZombie(client)
				&& GetZombieClass(client) == ZC_SPITTER)
		{
			count++;
		}
	}
	return count;
}

stock SetZombieClass(client, ZombieClass:zombie)
{
	decl WeaponIndex;
	while ((WeaponIndex = GetPlayerWeaponSlot(client, 0)) != -1)
	{
		RemovePlayerItem(client, WeaponIndex);
		RemoveEdict(WeaponIndex);
	}

	SDKCall(g_hSetClass, client, _:zombie);
	AcceptEntityInput(MakeCompatEntRef( GetEntProp(client, Prop_Send, "m_customAbility")), "Kill");
	SetEntProp(client, Prop_Send, "m_customAbility", GetEntData(SDKCall(g_hCreateAbility, client),
				g_oAbility));
}

stock Float:GetSpecialRespawnInterval()
{
	return SDKCall(g_hGetSpecialRespawnInterval, L4D2Direct_GetCDirector());
}

stock bool:IsPlayerGhost(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isGhost");
}

stock bool:IsPlayerZombie(client)
{
	return GetClientTeam(client) == TEAM_INFECTED;
}

stock ZombieClass:GetZombieClass(client)
{
	return ZombieClass:GetEntProp(client, Prop_Send, "m_zombieClass");
}
