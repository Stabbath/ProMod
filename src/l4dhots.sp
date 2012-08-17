#pragma semicolon 1
#include <sourcemod>


public Plugin:myinfo = 
{
	name = "L4D HOTs",
	author = "ProdigySim",
	description = "Pills and Adrenaline heal over time",
	version = "0.2",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
}

new bool:IsL4D2;

new Handle:g_hPillCvar;
new OldPillValue;
new Handle:g_hAdrenCvar;
new OldAdrenValue;
public OnPluginStart()
{
	IsL4D2 = IsTargetL4D2();
	
	g_hPillCvar=FindConVar("pain_pills_health_value");
	new Handle:pillhot = CreateConVar("l4d_pills_hot", "0", "Pills heal over time (10 hp each 1s)", FCVAR_PLUGIN);
	if(GetConVarBool(pillhot))
	{
		EnablePillHot();
	}
	HookConVarChange(pillhot, PillHotChanged);
	if(IsL4D2)
	{
		g_hAdrenCvar = FindConVar("adrenaline_health_buffer");
		new Handle:adrenhot = CreateConVar("l4d_adrenaline_hot", "0", "Adrenaline heals over time (15+10 hp each 1s)", FCVAR_PLUGIN);
		if(GetConVarBool(adrenhot))
		{
			EnableAdrenHot();
		}
		HookConVarChange(adrenhot, AdrenHotChanged);
	}
}

public OnPluginEnd()
{
	DisablePillHot(false);
	if(IsL4D2)
	{
		DisableAdrenHot(false);
	}
}

public PillHotChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new bool:newval = StringToInt(newValue)!=0;
	if(newval && StringToInt(oldValue) ==0)
	{
		EnablePillHot();
	}
	else if(!newval && StringToInt(oldValue) != 0)
	{
		DisablePillHot();
	}
}

public AdrenHotChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new bool:newval = StringToInt(newValue)!=0;
	if(newval && StringToInt(oldValue) ==0)
	{
		EnableAdrenHot();
	}
	else if(!newval && StringToInt(oldValue) != 0)
	{
		DisableAdrenHot();
	}
}

EnablePillHot()
{
	OldPillValue=GetConVarInt(g_hPillCvar);
	SetConVarInt(g_hPillCvar, 0);
	HookEvent("pills_used", PillsUsed_Event);
}

DisablePillHot(bool:unhook=true)
{
	if(unhook) UnhookEvent("pills_used", PillsUsed_Event);
	SetConVarInt(g_hPillCvar, OldPillValue);
}

EnableAdrenHot()
{
	OldAdrenValue=GetConVarInt(g_hAdrenCvar);
	SetConVarInt(g_hAdrenCvar, 0);
	HookEvent("adrenaline_used", AdrenalineUsed_Event);
}

DisableAdrenHot(bool:unhook=true)
{
	if(unhook) UnhookEvent("adrenaline_used", AdrenalineUsed_Event);
	SetConVarInt(g_hAdrenCvar, OldAdrenValue);
}


public Action:PillsUsed_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	HealEntityOverTime(client, 1.0, 10, 50);
}

public Action:AdrenalineUsed_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	HealEntityOverTime(client, 1.0, 15, 25);
}

stock HealEntityOverTime(client, Float:interval, increment, total)
{
	new maxhp=GetEntProp(client, Prop_Send, "m_iMaxHealth", 2);
	
	if(client==0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	if(increment >= total)
	{
		HealTowardsMax(client, total, maxhp);
	}
	else
	{
		HealTowardsMax(client, increment, maxhp);
		new Handle:myDP;
		CreateDataTimer(interval, __HOT_ACTION, myDP, 
			TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(myDP, client);
		WritePackCell(myDP, increment);
		WritePackCell(myDP, total-increment);
		WritePackCell(myDP, maxhp);
	}
}

public Action:__HOT_ACTION(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new increment = ReadPackCell(pack);
	new pos = GetPackPosition(pack);
	new remaining = ReadPackCell(pack);
	new maxhp = ReadPackCell(pack);
	
//	PrintToChatAll("HOT: %d %d %d %d", client, increment, remaining, maxhp);
	
	if(client==0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	
	if(increment >= remaining)
	{
		HealTowardsMax(client, remaining, maxhp);
		return Plugin_Stop;
	}
	HealTowardsMax(client, increment, maxhp);
	SetPackPosition(pack, pos);
	WritePackCell(pack, remaining-increment);
	
	return Plugin_Continue;
}

stock HealTowardsMax(client, amount, max)
{
	new Float:hb = float(amount) + GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	new Float:overflow = (hb+GetClientHealth(client))-max;
	if(overflow > 0)
	{
		hb -= overflow;
	}
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", hb);
}

bool:IsTargetL4D2()
{
    decl String:gameFolder[32];
    GetGameFolderName(gameFolder, sizeof(gameFolder));
    return StrContains(gameFolder, "left4dead2") >= -1;
}