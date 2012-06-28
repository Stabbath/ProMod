#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <l4d2lib>

new g_iDefaultCommonLimit;
new Handle:g_hCvarCommonLimit = INVALID_HANDLE;
 
public Plugin:myinfo =
{
	name = "L4D2 Starter Common",
	author = "Blade",
	description = "Decreases amount of common before leaving the saferoom.",
	version = "1.0.2",
	url = "nope"
}

public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_left_start_area", PlayerLeftStartArea);
	g_hCvarCommonLimit = FindConVar("z_common_limit");	
	g_iDefaultCommonLimit = GetConVarInt(g_hCvarCommonLimit);
}

public OnPluginEnd()
{
	ResetConVar(FindConVar("z_common_limit"));
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetConVarInt(g_hCvarCommonLimit, g_iDefaultCommonLimit / 6);
}

public Action:PlayerLeftStartArea(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(5.0, CommonLimitDelayOne);
}

public Action:CommonLimitDelayOne(Handle:timer)
{
	SetConVarInt(g_hCvarCommonLimit, g_iDefaultCommonLimit / 4);
	CreateTimer(5.0, CommonLimitDelayTwo);
}

public Action:CommonLimitDelayTwo(Handle:timer)
{
	SetConVarInt(g_hCvarCommonLimit, g_iDefaultCommonLimit / 2);
	CreateTimer(5.0, CommonLimitDelayFinish);
}

public Action:CommonLimitDelayFinish(Handle:timer)
{
	SetConVarInt(g_hCvarCommonLimit, g_iDefaultCommonLimit);
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	ResetConVar(FindConVar("z_common_limit"));
}