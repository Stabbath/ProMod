#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <l4d2lib>

new g_iDefaultCommonLimit;
new Handle:g_hCvarCommonLimit = INVALID_HANDLE;

new Handle:hTimer 	= INVALID_HANDLE;
new bool:bGameStart = false;
new iTickCount 		= 3;
new iInfectedNum 	= 0;	// could be changed to use a single decrementing variable, but why bother
new iStartCommonMax	= 0;	//

public Plugin:myinfo =
{
	name = "L4D2 Starter Common",
	author = "Blade, Stabby",
	description = "Decreases amount of common before leaving the saferoom.",
	version = "1.1",
	url = "nope"
}

public OnEntityCreated(entity, const String:classname[])
{	
	if (!bGameStart && StrEqual(classname, "infected"))
	{
		if (++iInfectedNum > iStartCommonMax) { AcceptEntityInput(entity, "Kill"); }
	}
	return;
}

public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_left_start_area", PlayerLeftStartArea);	
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{	//only two of these instructions need to be done every round start, but who cares?
	bGameStart = false;
	
	g_hCvarCommonLimit = FindConVar("z_common_limit");
	g_iDefaultCommonLimit = GetConVarInt(g_hCvarCommonLimit);	

	new buffer = g_iDefaultCommonLimit / 6;
	SetConVarInt(g_hCvarCommonLimit, buffer);
	iStartCommonMax = buffer;
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (hTimer != INVALID_HANDLE) { KillTimer(hTimer); }
	iTickCount 		= 3;
	iInfectedNum 	= 0;
}

public Action:PlayerLeftStartArea(Handle:event, const String:name[], bool:dontBroadcast)
{
	bGameStart = true;	
	CreateTimer(5.0, CommonLimitDelay, INVALID_HANDLE, TIMER_REPEAT);
}

public Action:CommonLimitDelay(Handle:timer)
{	
	SetConVarInt(g_hCvarCommonLimit, g_iDefaultCommonLimit / (1 << --iTickCount));
	
	if (!iTickCount)	{ return Plugin_Stop; }
	
	return Plugin_Continue;
}