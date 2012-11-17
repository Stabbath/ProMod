#include <sourcemod>
#include <sdktools>

#define NUM_OF_SURVS 4

new incap_count[NUM_OF_SURVS];
new preheal_temp[NUM_OF_SURVS];
new preheal_perm[NUM_OF_SURVS];

new Handle:sdkRevive;

new Handle:hEnabled;
new bool:bEnabled;

public Plugin:myinfo =
{
	name = "Temp Health Medkits",
	author = "CanadaRox",
	description = "A plugin that replaced health gained by medkits with temporary health",
	version = "0.3",
	url = "https://bitbucket.org/CanadaRox/random-sourcemod-stuff/"
}

public OnPluginStart()
{
	hEnabled = CreateConVar("l4d2_temphealthmedkits_enable", "1", "Enable temp health medkits");
	HookConVarChange(hEnabled, Enabled_Change);
	
	bEnabled = GetConVarBool(hEnabled);
	
	HookEvent("heal_success",	HealSuccess_Event);
	HookEvent("heal_end",		HealEnd_Event);
	
	
	new Handle:config = LoadGameConfigFile("left4downtown.l4d2");
	if(config == INVALID_HANDLE)
	{
		SetFailState("Unable to find the gamedata file, check that it is installed correctly!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(config, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	sdkRevive = EndPrepSDKCall();
	if(sdkRevive == INVALID_HANDLE)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::OnRevived(void)\" signature, check the file version!");
	}
	CloseHandle(config);
}

public Enabled_Change(Handle:c, const String:n[], const String:o[]) bEnabled = GetConVarBool(hEnabled);

public HealEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!bEnabled) return;
	
	new iSurvCount = 0;
	decl character;
	for (new client = 1; client <= MaxClients && iSurvCount < 4; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == 2)
		{
			character = GetSurvivorCharacter(client);
			
			preheal_temp[character] = GetSurvivorTempHealth(client);
			preheal_perm[character] = GetSurvivorPermanentHealth(client);
			incap_count[character] = GetEntProp(client, Prop_Send, "m_currentReviveCount");
			
			iSurvCount++;
		}
	}
}

public HealSuccess_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!bEnabled) return;
	
	new client = GetClientOfUserId(GetEventInt(event, "subject"));
	new character = GetSurvivorCharacter(client);
	new max_health = GetEntProp(client, Prop_Send, "m_iMaxHealth", 2);
	new preheal_total = preheal_perm[character] + preheal_temp[character];
	
	new new_temp =  preheal_temp[character] + RoundToCeil((max_health - preheal_total) * GetConVarFloat(FindConVar("first_aid_heal_percent")));
	
	
	if (incap_count[character] == GetConVarInt(FindConVar("survivor_max_incapacitated_count")))
	{
		SetBlackAndWhite(client, preheal_perm[character], new_temp);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", incap_count[character]);
		SetSurvivorTempHealth(client, new_temp);
		SetEntityHealth(client, preheal_perm[character]);
	}
}




stock GetSurvivorPermanentHealth(client)
{
	return GetEntProp(client, Prop_Send, "m_iHealth");
}

stock GetSurvivorCharacter(client)
{
	return GetEntProp(client, Prop_Send, "m_survivorCharacter");
}

stock GetSurvivorTempHealth(client)
{
	new temphp = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(FindConVar("pain_pills_decay_rate")))) - 1;
	return temphp > 0 ? temphp : 0;
}

stock SetSurvivorTempHealth(client, hp)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	new Float:newOverheal = hp * 1.0;
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", newOverheal);
}

stock SetBlackAndWhite(target, health, temp_health)
{
	if(target > 0 && IsValidEntity(target) && IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
	{
		SetEntProp(target, Prop_Send, "m_currentReviveCount", GetConVarInt(FindConVar("survivor_max_incapacitated_count"))-1);
		SetEntProp(target, Prop_Send, "m_isIncapacitated", 1);
		SDKCall(sdkRevive, target);
		SetEntityHealth(target, health);
		SetSurvivorTempHealth(target, temp_health);
	}
}