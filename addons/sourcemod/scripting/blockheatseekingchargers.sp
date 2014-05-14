/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
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