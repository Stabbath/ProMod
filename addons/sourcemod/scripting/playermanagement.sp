#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <colors>

#define GAMECONFIG_FILE "left4downtown.l4d2"
#define ZC_TANK 8

public Plugin:myinfo =
{
	name = "Player Management Plugin",
	author = "CanadaRox",
	description = "Player management!  Swap players/teams and spectate!",
	version = "2",
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

new L4D2Team:pendingSwaps[MAXPLAYERS];

public OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegAdminCmd("sm_swap", Swap_Cmd, ADMFLAG_BAN, "sm_swap <player1> [player2] ... [playerN] - swap all listed players to opposite teams");
	RegAdminCmd("sm_swapto", SwapTo_Cmd, ADMFLAG_BAN, "sm_swapto <teamnum> <player1> [player2] ... [playerN] - swap all listed players to <teamnum> (1,2, or 3)");
	RegAdminCmd("sm_swapteams", SwapTeams_Cmd, ADMFLAG_BAN, "sm_swapteams - swap the players between both teams");
	RegConsoleCmd("sm_spectate", Spectate_Cmd);
	RegConsoleCmd("sm_spec", Spectate_Cmd);
	RegConsoleCmd("sm_s", Spectate_Cmd);

	survivor_limit = FindConVar("survivor_limit");
	z_max_player_zombies = FindConVar("z_max_player_zombies");
}

public Action:Spectate_Cmd(client, args)
{
	CPrintToChatAllEx(client, "{teamcolor}%N{default} has become a spectator!", client);
	if (L4D2Team:GetClientTeam(client) == L4D2Team_Infected && GetZombieClass(client) != ZC_TANK)
	{
		ForcePlayerSuicide(client);
	}
	ChangePlayerTeam(client, L4D2Team_Infected);
	CreateTimer(0.01, RespecDelay_Timer, client);
	return Plugin_Handled;
}

public Action:RespecDelay_Timer(Handle:timer, any:client)
{
	ChangePlayerTeam(client, L4D2Team_Spectator);
}

public Action:SwapTeams_Cmd(client, args)
{
	for (new cli = 1; cli <= MaxClients; cli++)
	{
		if(IsClientInGame(cli) && !IsFakeClient(cli) && IsPlayer(cli))
		{
			pendingSwaps[cli] = oppositeTeamMap[L4D2Team:GetClientTeam(cli)];
		}
	}
	ApplySwaps(client);
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
				pendingSwaps[target] = oppositeTeamMap[L4D2Team:GetClientTeam(target)];
			}
		}
	}

	ApplySwaps(client);

	return Plugin_Handled;
}

public Action:SwapTo_Cmd(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_swapto <teamnum> <player1> <player2> ... <playerN>\n%d = Spectators, %d = Survivors, %d = Infected", L4D2Team_Spectator, L4D2Team_Survivor, L4D2Team_Infected);
		return Plugin_Handled;
	}

	decl String:argbuf[MAX_NAME_LENGTH];

	GetCmdArg(1, argbuf, sizeof(argbuf));
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

	for (new i = 2; i <= args; i++)
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

	ApplySwaps(client);

	return Plugin_Handled;
}

stock ApplySwaps(sender)
{
	decl L4D2Team:clientTeam;
	/* Swap everyone to spec first so we know the correct number of slots on the teams */
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			clientTeam = L4D2Team:GetClientTeam(client);
			if (clientTeam != pendingSwaps[client] && pendingSwaps[client] != L4D2Team_None)
			{
				if (clientTeam == L4D2Team_Infected && GetZombieClass(client) != ZC_TANK)
					ForcePlayerSuicide(client);
				ChangePlayerTeam(client, L4D2Team_Spectator);
			}
		}
	}

	/* Now lets try to put them on teams */
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && pendingSwaps[client] != L4D2Team_None)
		{
			if (!ChangePlayerTeam(client, pendingSwaps[client]))
				PrintToChat(sender, "%N could not be switched because the target team was full.", client);
			pendingSwaps[client] = L4D2Team_None;

		}
	}

	/* Just in case MaxClients ever changes */
	for (new i = MaxClients+1; i < MAXPLAYERS; i++)
	{
		pendingSwaps[i] = L4D2Team_None;
	}
}

stock bool:ChangePlayerTeam(client, L4D2Team:team)
{
	if (L4D2Team:GetClientTeam(client) == team)
		return true;
	else if (GetTeamHumanCount(team) == GetTeamMaxHumans(team))
		return false;

	if (team != L4D2Team_Survivor)
		ChangeClientTeam(client, _:team);
	if (L4D2Team_Survivor == team && !IsPlayerAlive(client))
	{
		new bot = FindSurvivorBot();
		if (-1 == bot) /* we couldn't find a bot, how the hell do we deal with this efficiently?? */
		{
			ChangeClientTeam(client, _:team);
			new flags = GetCommandFlags("respawn");
			SetCommandFlags("respawn", flags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "respawn");
			SetCommandFlags("respawn", flags);
		}
		else
		{
			new flags = GetCommandFlags("sb_takecontrol");
			SetCommandFlags("sb_takecontrol", flags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "sb_takecontrol");
			SetCommandFlags("sb_takecontrol", flags);
		}
	}
	return true;
}

stock GetTeamHumanCount(L4D2Team:team)
{
	new humans = 0;
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && L4D2Team:GetClientTeam(client) == team)
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
	else if (team == L4D2Team_Spectator)
	{
		return MaxClients;
	}
	
	return -1;
}

/* return -1 if no bot found, clientid otherwise */
stock FindSurvivorBot()
{
	decl bot;
	for(bot = 1; bot <= MaxClients && (!IsClientInGame(bot) || !IsFakeClient(bot) || (L4D2Team:GetClientTeam(bot) != L4D2Team_Survivor)); bot++) {}
	return (bot == MaxClients+1) ? -1 : bot;
}

stock IsPlayer(client)
{
	new L4D2Team:team = L4D2Team:GetClientTeam(client);
	return (team == L4D2Team_Survivor || team == L4D2Team_Infected);
}

stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");
