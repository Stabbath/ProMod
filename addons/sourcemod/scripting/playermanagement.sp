#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <colors>

#define ZC_TANK 8

public Plugin:myinfo =
{
	name = "Player Management Plugin",
	author = "CanadaRox",
	description = "Player management!  Swap players/teams and spectate!",
	version = "6",
	url = ""
};

enum L4D2Team
{
	L4D2Team_None = 0,
	L4D2Team_Spectator,
	L4D2Team_Survivor,
	L4D2Team_Infected
}

new const L4D2Team:oppositeTeamMap[] =
{
	L4D2Team_None,
	L4D2Team_Spectator,
	L4D2Team_Infected,
	L4D2Team_Survivor
};

new Handle:survivor_limit;
new Handle:z_max_player_zombies;

new L4D2Team:pendingSwaps[MAXPLAYERS+1];
new bool:blockVotes[MAXPLAYERS+1];
new bool:isMapActive = false;

new Handle:l4d_pm_supress_spectate;

public OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegAdminCmd("sm_swap", Swap_Cmd, ADMFLAG_BAN, "sm_swap <player1> [player2] ... [playerN] - swap all listed players to opposite teams");
	RegAdminCmd("sm_swapto", SwapTo_Cmd, ADMFLAG_BAN, "sm_swapto [force] <teamnum> <player1> [player2] ... [playerN] - swap all listed players to <teamnum> (1,2, or 3)");
	RegAdminCmd("sm_swapteams", SwapTeams_Cmd, ADMFLAG_BAN, "sm_swapteams - swap the players between both teams");
	RegAdminCmd("sm_fixbots", FixBots_Cmd, ADMFLAG_BAN, "sm_fixbots - Spawns survivor bots to match survivor_limit");
	RegConsoleCmd("sm_spectate", Spectate_Cmd, "Moves you to the spectator team");
	RegConsoleCmd("sm_spec", Spectate_Cmd, "Moves you to the spectator team");
	RegConsoleCmd("sm_s", Spectate_Cmd, "Moves you to the spectator team");

	AddCommandListener(Vote_Listener, "vote");
	AddCommandListener(Vote_Listener, "callvote");

	survivor_limit = FindConVar("survivor_limit");
	SetConVarBounds(survivor_limit, ConVarBound_Upper, false);
	HookConVarChange(survivor_limit, survivor_limitChanged);

	z_max_player_zombies = FindConVar("z_max_player_zombies");
	SetConVarBounds(z_max_player_zombies, ConVarBound_Upper, false);

	l4d_pm_supress_spectate = CreateConVar("l4d_pm_supress_spectate", "0", "Don't print messages when players spectate", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public OnMapStart()
{
	isMapActive = true;
}

public OnMapEnd()
{
	isMapActive = false;
}

public Action:FixBots_Cmd(client, args)
{
	if (client != 0)
	{
		PrintToChatAll("[SM] %N is attempting to fix bot counts");
	}
	else
	{
		PrintToChatAll("[SM] Console is attempting to fix bot counts");
	}
	FixBotCount();
	return Plugin_Handled;
}

public survivor_limitChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	FixBotCount();
}

public OnClientDisconnect_Post(client)
{
	if (isMapActive)
		FixBotCount();
}

public Action:Spectate_Cmd(client, args)
{
	if (!GetConVarBool(l4d_pm_supress_spectate))
	{
		CPrintToChatAllEx(client, "{teamcolor}%N{default} has become a spectator!", client);
	}
	new L4D2Team:team = GetClientTeamEx(client);
	if (team == L4D2Team_Survivor)
	{
		ChangeClientTeamEx(client, L4D2Team_Spectator, true);
	}
	else if (team == L4D2Team_Infected)
	{
		if (GetZombieClass(client) != ZC_TANK)
		{
			ForcePlayerSuicide(client);
		}
		ChangeClientTeamEx(client, L4D2Team_Spectator, true);
	}
	else
	{
		blockVotes[client] = true;
		ChangeClientTeamEx(client, L4D2Team_Infected, true);
		CreateTimer(0.1, RespecDelay_Timer, client);
	}
	return Plugin_Handled;
}

public Action:RespecDelay_Timer(Handle:timer, any:client)
{
	ChangeClientTeamEx(client, L4D2Team_Spectator, true);
	blockVotes[client] = false;
}

public Action:Vote_Listener(client, const String:command[], argc)
{
	return blockVotes[client] ? Plugin_Handled : Plugin_Continue;
}

public Action:SwapTeams_Cmd(client, args)
{
	for (new cli = 1; cli <= MaxClients; cli++)
	{
		if(IsClientInGame(cli) && !IsFakeClient(cli) && IsPlayer(cli))
		{
			pendingSwaps[cli] = oppositeTeamMap[GetClientTeamEx(cli)];
		}
	}
	ApplySwaps(client, false);
	return Plugin_Handled;
}

public Action:Swap_Cmd(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_swap <player1> <player2> ... <playerN>");
		return Plugin_Handled;
	}

	decl String:argbuf[MAX_NAME_LENGTH];

	decl targets[MaxClients+1];
	decl target;
	decl targetCount;
	decl String:target_name[MAX_TARGET_LENGTH];
	decl bool:tn_is_ml;

	for (new i = 1; i <= args; i++)
	{
		GetCmdArg(i, argbuf, sizeof(argbuf));
		targetCount = ProcessTargetString(
				argbuf,
				0,
				targets,
				MaxClients+1,
				COMMAND_FILTER_NO_BOTS,
				target_name,
				sizeof(target_name),
				tn_is_ml);
		
		for (new j = 0; j < targetCount; j++)
		{
			target = targets[j];
			if(IsClientInGame(target))
			{
				pendingSwaps[target] = oppositeTeamMap[GetClientTeamEx(target)];
			}
		}
	}

	ApplySwaps(client, false);

	return Plugin_Handled;
}

public Action:SwapTo_Cmd(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_swapto <teamnum> <player1> <player2> ... <playerN>\n%d = Spectators, %d = Survivors, %d = Infected", L4D2Team_Spectator, L4D2Team_Survivor, L4D2Team_Infected);
		ReplyToCommand(client, "[SM] Usage: sm_swapto force <teamnum> <player1> <player2> ... <playerN>\n%d = Spectators, %d = Survivors, %d = Infected", L4D2Team_Spectator, L4D2Team_Survivor, L4D2Team_Infected);
		return Plugin_Handled;
	}

	decl String:argbuf[MAX_NAME_LENGTH];
	new bool:force = false;

	GetCmdArg(1, argbuf, sizeof(argbuf));
	if (StrEqual(argbuf, "force"))
	{
		force = true;
		GetCmdArg(2, argbuf, sizeof(argbuf));
	}

	new L4D2Team:team = L4D2Team:StringToInt(argbuf);
	if (team < L4D2Team_Spectator || team > L4D2Team_Infected)
	{
		ReplyToCommand(client, "[SM] Valid teams: %d = Spectators, %d = Survivors, %d = Infected", L4D2Team_Spectator, L4D2Team_Survivor, L4D2Team_Infected);
		return Plugin_Handled;
	}

	decl targets[MaxClients+1];
	decl target;
	decl targetCount;
	decl String:target_name[MAX_TARGET_LENGTH];
	decl bool:tn_is_ml;

	for (new i = force?3:2; i <= args; i++)
	{
		GetCmdArg(i, argbuf, sizeof(argbuf));
		targetCount = ProcessTargetString(
				argbuf,
				0,
				targets,
				MaxClients+1,
				COMMAND_FILTER_NO_BOTS,
				target_name,
				sizeof(target_name),
				tn_is_ml);
		
		for (new j = 0; j < targetCount; j++)
		{
			target = targets[j];
			if(IsClientInGame(target))
			{
				pendingSwaps[target] = team;
			}
		}
	}

	ApplySwaps(client, force);

	return Plugin_Handled;
}

stock ApplySwaps(sender, bool:force)
{
	decl L4D2Team:clientTeam;
	/* Swap everyone to spec first so we know the correct number of slots on the teams */
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			clientTeam = GetClientTeamEx(client);
			if (clientTeam != pendingSwaps[client] && pendingSwaps[client] != L4D2Team_None)
			{
				if (clientTeam == L4D2Team_Infected && GetZombieClass(client) != ZC_TANK)
					ForcePlayerSuicide(client);
				ChangeClientTeamEx(client, L4D2Team_Spectator, true);
			}
		}
	}

	/* Now lets try to put them on teams */
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && pendingSwaps[client] != L4D2Team_None)
		{
			if (!ChangeClientTeamEx(client, pendingSwaps[client], force))
			{
				if (sender > 0)
				{
					PrintToChat(sender, "%N could not be switched because the target team was full or has no bot to take over.", client);
				}
			}
			pendingSwaps[client] = L4D2Team_None;

		}
	}

	/* Just in case MaxClients ever changes */
	for (new i = MaxClients+1; i <= MAXPLAYERS; i++)
	{
		pendingSwaps[i] = L4D2Team_None;
	}
}

stock bool:ChangeClientTeamEx(client, L4D2Team:team, bool:force)
{
	if (GetClientTeamEx(client) == team)
		return true;
	else if (!force && GetTeamHumanCount(team) == GetTeamMaxHumans(team))
		return false;

	if (team != L4D2Team_Survivor)
	{
		ChangeClientTeam(client, _:team);
		return true;
	}
	else
	{
		new bot = FindSurvivorBot();
		if (bot > 0)
		{
			new flags = GetCommandFlags("sb_takecontrol");
			SetCommandFlags("sb_takecontrol", flags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "sb_takecontrol");
			SetCommandFlags("sb_takecontrol", flags);
			return true;
		}
	}
	return false;
}

stock GetTeamHumanCount(L4D2Team:team)
{
	new humans = 0;
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeamEx(client) == team)
		{
			humans++;
		}
	}
	
	return humans;
}

stock GetTeamMaxHumans(L4D2Team:team)
{
	if (team == L4D2Team_Survivor)
	{
		return GetConVarInt(survivor_limit);
	}
	else if (team == L4D2Team_Infected)
	{
		return GetConVarInt(z_max_player_zombies);
	}
	return MaxClients;
}

/* return -1 if no bot found, clientid otherwise */
stock FindSurvivorBot()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsFakeClient(client) && GetClientTeamEx(client) == L4D2Team_Survivor)
		{
			return client;
		}
	}
	return -1;
}

stock IsPlayer(client)
{
	new L4D2Team:team = GetClientTeamEx(client);
	return (team == L4D2Team_Survivor || team == L4D2Team_Infected);
}

stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");

stock FixBotCount()
{
	new survivor_count = 0;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeamEx(client) == L4D2Team_Survivor)
		{
			survivor_count++;
		}
	}
	new limit = GetConVarInt(survivor_limit);
	if (survivor_count < limit)
	{
		decl bot;
		for (; survivor_count < limit; survivor_count++)
		{
			bot = CreateFakeClient("SurvivorBot");
			if (bot != 0)
			{
				ChangeClientTeam(bot, _:L4D2Team_Survivor);
				if (DispatchKeyValue(bot, "classname", "survivorbot") && DispatchSpawn(bot))
				{
					CreateTimer(0.1, KickFakeClient_Timer, bot);
				}
			}
		}
	}
	else if (survivor_count > limit)
	{
		for (new client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeamEx(client) == L4D2Team_Survivor)
			{
				if (IsFakeClient(client))
				{
					KickClient(client);
				}
			}
		}
		PrintToChatAll("[SM] Make sure there are no duplicate survivors and everyone is able to gain points, or restart the map.");
	}
}

public Action:KickFakeClient_Timer(Handle:timer, any:bot)
{
	if (IsClientConnected(bot) && IsFakeClient(bot))
	{
		KickClient(bot, "I hope you aren't a real boy");
	}
}

stock L4D2Team:GetClientTeamEx(client)
{
	return L4D2Team:GetClientTeam(client);
}
