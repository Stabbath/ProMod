#include <sourcemod>
new bIsCharging[MAXPLAYERS + 1] = false;

public Plugin:myinfo =
{
	name = "Block heatseeking chargers",
	author = "Tabun, Greenice",
	description = "What name says",
	url = "http://steamcommunity.com/id/uk-greenice"
}

public OnPluginStart()
{
	HookEvent("player_bot_replace", BotReplacesPlayer);
	HookEvent("charger_charge_start", Event_ChargeStart);
	HookEvent("charger_charge_end", Event_ChargeEnd);
	HookEvent("player_first_spawn", OnPlayerFirstSpawn);
}

public Event_ChargeStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    bIsCharging[client] = true;
}

public Event_ChargeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    bIsCharging[client] = false;
}

public Action:BotReplacesPlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "player"));
	if (bIsCharging[client])
	{
		new bot = GetClientOfUserId(GetEventInt(event, "bot"));
		KickClient(bot, "Charger");
		bIsCharging[client] = false;
	}
}

public OnPlayerFirstSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new PlayerId = GetEventInt(event, "userid");
	new client = GetClientOfUserId(PlayerId);
	bIsCharging[client] = false;
}