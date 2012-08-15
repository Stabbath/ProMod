#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define WP_PAIN_PILLS 15
//#define WP_ADRENALINE 23	- maybe add adren later if needed

new bool:bBotHadPills[MAXPLAYERS + 1];

public Plugin:myinfo = 
{
	name = "Bot Pop Stop",
	author = "Stabby",
	description = "Stops survivor bots from popping pills.",
	version = "1.2",
	url = "no url"
}

public OnPluginStart()
{	
	HookEvent("weapon_fire",Event_WeaponFire);
	HookEvent("bot_player_replace",Event_PlayerJoined);
	HookEvent("weapon_given",Event_PillsGiven);
	HookEvent("item_pickup",Event_PillsPickup);
}

/*
 *	Stopping bots from acquiring new sets of pills
 */

public Action:Event_PillsPickup(Handle:event, const String:name[], bool:dontBroadcast)
{	
	new client	 = GetClientOfUserId(GetEventInt(event,"userid"));
	if (!IsFakeClient(client)) { return; }	
	
	decl String:sWeapon[32];
	GetEventString(event, "item", sWeapon, sizeof(sWeapon));
	if (!StrEqual(sWeapon,"pain_pills")) { return; } //just in case it fires in other situations
	
	RemovePlayerItem(client, GetPlayerWeaponSlot(client,4));
	GivePlayerItem(client, "weapon_pain_pills");	//spawn it at his position again - could perhaps spawn it at the exact same location as the picked set was?
}

//blocks pill passes to survivor bots - making it so that the bot simply couldnt grab them could lead to pills flying into unreachable areas
public Action:Event_PillsGiven(Handle:event, const String:name[], bool:dontBroadcast)
{
	new receiver = GetClientOfUserId(GetEventInt(event,"userid"));
	if (!IsFakeClient(receiver)) { return; } //only block for bots	
	
	new weaponid = GetEventInt(event, "weapon");
	if (weaponid != WP_PAIN_PILLS) { return; } //just in case it fires in other situations
	
	new giver	 = GetClientOfUserId(GetEventInt(event,"giver"));
	if (giver > 0 && giver <= MaxClients) { return; } //in case non-client givers are possible and stuff
	
	GivePills(giver);	//event fires before the pills arrive apparently, gotta time it
	CreateTimer(0.0001, Timed_TakePillsAway, receiver);	
}

public Action:Timed_TakePillsAway(Handle:timer_unused, any:client)
{						
	RemovePlayerItem(client, GetPlayerWeaponSlot(client,4));
}

/*
 *	Removal and giving of pills on crash/reconnect
 */

//track when a bot tries to take pills
public Action:Event_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client   = GetClientOfUserId(GetEventInt(event,"userid"));
	new weaponid = GetEventInt(event,"weaponid");
		
	//no SI attacks ever have the pain_pills wepid, no need to check team
	if (!IsFakeClient(client) || (weaponid != WP_PAIN_PILLS))	{ return; }
		
	//remove pills	- removing non-permanently lead to a stalemate with the AI
	RemovePlayerItem(client, GetPlayerWeaponSlot(client,4));
	bBotHadPills[client] = true;
	return;
}

public Action:Event_PlayerJoined(Handle:event, const String:name[], bool:dontBroadcast)
{
	new leavingBot 	= GetClientOfUserId(GetEventInt(event,"bot"));
	
	if (bBotHadPills[leavingBot])	//had pills that were removed because of bot stupidity?
	{	//no biggie, give em back
		GivePills(GetClientOfUserId(GetEventInt(event,"player")));
		bBotHadPills[leavingBot] = false;
	}
}

/*
 * 	Stocks
 */

stock GivePills(client)
{
	new flCmd = GetCommandFlags("give");
	
	SetCommandFlags("give", flCmd & ~FCVAR_CHEAT);
	FakeClientCommand(client, "give pain_pills");	//if adding adren, simply make the second half of this string variable
	SetCommandFlags("give", flCmd | FCVAR_CHEAT);
}

