#pragma semicolon 1

#include <sourcemod>
#include <colors>
#include <readyup>

#define EXTRA_KEY_DELAY 1.0

public Plugin:myinfo =
{
	name = "Pause plugin",
	author = "CanadaRox",
	description = "Adds pause functionality without breaking pauses",
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

new String:teamString[L4D2Team][] =
{
	"None",
	"Spectator",
	"Survivor",
	"Infected"
};

new Handle:menuPanel;
new Handle:readyCountdownTimer;
new Handle:sv_pausable;
new bool:adminPause;
new bool:isPaused;
new bool:teamReady[L4D2Team];
new bool:was_pressing_IN_USE[MAXPLAYERS + 1];
new readyDelay;
new Handle:pauseDelayCvar;
new pauseDelay;

public OnPluginStart()
{
	RegConsoleCmd("sm_pause", Pause_Cmd);
	RegConsoleCmd("sm_unpause", Unpause_Cmd);
	RegConsoleCmd("sm_ready", Unpause_Cmd);
	RegConsoleCmd("sm_unready", Unready_Cmd);

	RegAdminCmd("sm_forcepause", ForcePause_Cmd, ADMFLAG_BAN);
	RegAdminCmd("sm_forceunpause", ForceUnpause_Cmd, ADMFLAG_BAN);

	AddCommandListener(Say_Callback, "say");
	AddCommandListener(TeamSay_Callback, "say_team");
	AddCommandListener(Unpause_Callback, "unpause");

	sv_pausable = FindConVar("sv_pausable");

	pauseDelayCvar = CreateConVar("sm_pausedelay", "0", "Delay to apply before a pause happens.  Could be used to prevent Tactical Pauses");
}

public OnClientPutInServer(client)
{
	if (isPaused)
	{
		PrintToChatAll("\x01[SM] \x03%N \x01is now fully loaded in game", client);
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!isPaused)
	{
		was_pressing_IN_USE[client] = !!(buttons & IN_USE);
	}
	else if (isPaused && was_pressing_IN_USE[client])
	{
		buttons |= IN_USE;
	}
}

public Action:Pause_Cmd(client, args)
{
	if (!IsInReady() && pauseDelay == 0 && !isPaused && IsPlayer(client))
	{
		PrintToChatAll("[SM] %N paused the game", client);
		pauseDelay = GetConVarInt(pauseDelayCvar);
		if (pauseDelay == 0)
			Pause();
		else
			CreateTimer(1.0, PauseDelay_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:PauseDelay_Timer(Handle:timer)
{
	if (pauseDelay == 0)
	{
		PrintToChatAll("Paused!");
		Pause();
		return Plugin_Stop;
	}
	else
	{
		PrintToChatAll("Game pausing in: %d", pauseDelay);
		pauseDelay--;
	}
	return Plugin_Continue;
}

public Action:Unpause_Cmd(client, args)
{
	if (isPaused && IsPlayer(client))
	{
		new L4D2Team:clientTeam = L4D2Team:GetClientTeam(client);
		if (!teamReady[clientTeam])
		{
			PrintToChatAll("[SM] %N marked %s as ready", client, teamString[L4D2Team:GetClientTeam(client)]);
		}
		teamReady[clientTeam] = true;
		if (CheckFullReady())
		{
			InitiateLiveCountdown();
		}
	}
	return Plugin_Handled;
}

public Action:Unready_Cmd(client, args)
{
	if (isPaused && IsPlayer(client) && !adminPause)
	{
		new L4D2Team:clientTeam = L4D2Team:GetClientTeam(client);
		if (teamReady[clientTeam])
		{
			PrintToChatAll("[SM] %N marked %s as not ready", client, teamString[L4D2Team:GetClientTeam(client)]);
		}
		teamReady[clientTeam] = false;
		CancelFullReady(client);
	}
	return Plugin_Handled;
}

public Action:ForcePause_Cmd(client, args)
{
	if (isPaused)
	{
		adminPause = true;
		Pause();
	}
}

public Action:ForceUnpause_Cmd(client, args)
{
	if (isPaused)
	{
		InitiateLiveCountdown();
	}
}

Pause()
{
	for (new L4D2Team:team; team < L4D2Team; team++)
	{
		teamReady[team] = false;
	}

	isPaused = true;
	readyCountdownTimer = INVALID_HANDLE;

	CreateTimer(1.0, MenuRefresh_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SetConVarBool(sv_pausable, true);
			FakeClientCommand(client, "pause");
			SetConVarBool(sv_pausable, false);
			break;
		}
	}
}

Unpause()
{
	isPaused = false;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SetConVarBool(sv_pausable, true);
			FakeClientCommand(client, "unpause");
			SetConVarBool(sv_pausable, false);
			break;
		}
	}
}

public Action:MenuRefresh_Timer(Handle:timer)
{
	if (isPaused)
	{
		UpdatePanel();
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

UpdatePanel()
{
	if (menuPanel != INVALID_HANDLE)
	{
		CloseHandle(menuPanel);
		menuPanel = INVALID_HANDLE;
	}

	menuPanel = CreatePanel();

	DrawPanelText(menuPanel, "Team Status");
	DrawPanelText(menuPanel, teamReady[L4D2Team_Survivor] ? "->1. Survivors: Ready" : "->1. Survivors: Not ready");
	DrawPanelText(menuPanel, teamReady[L4D2Team_Infected] ? "->2. Infected: Ready" : "->2. Infected: Not ready");

	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			SendPanelToClient(menuPanel, client, DummyHandler, 1);
		}
	}
}

InitiateLiveCountdown()
{
	if (readyCountdownTimer == INVALID_HANDLE)
	{
		PrintToChatAll("Going live!\nSay !unready to cancel");
		readyDelay = 5;
		readyCountdownTimer = CreateTimer(1.0, ReadyCountdownDelay_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:ReadyCountdownDelay_Timer(Handle:timer)
{
	if (readyDelay == 0)
	{
		PrintToChatAll("Round is live!");
		Unpause();
		return Plugin_Stop;
	}
	else
	{
		PrintToChatAll("Live in: %d", readyDelay);
		readyDelay--;
	}
	return Plugin_Continue;
}

CancelFullReady(client)
{
	if (readyCountdownTimer != INVALID_HANDLE)
	{
		CloseHandle(readyCountdownTimer);
		readyCountdownTimer = INVALID_HANDLE;
		PrintToChatAll("%N cancelled the countdown!", client);
	}
}

public Action:Say_Callback(client, const String:command[], argc)
{
	if (isPaused)
	{
		decl String:buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		StripQuotes(buffer);
		CPrintToChatAllEx(client, "{teamcolor}%N{default}: %s", client, buffer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:TeamSay_Callback(client, const String:command[], argc)
{
	if (isPaused)
	{
		decl String:buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		StripQuotes(buffer);
		PrintToTeam(client, L4D2Team:GetClientTeam(client), buffer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Unpause_Callback(client, const String:command[], argc)
{
	if (0 == client && isPaused)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

bool:CheckFullReady()
{
	return teamReady[L4D2Team_Survivor] && teamReady[L4D2Team_Infected];
}

stock IsPlayer(client)
{
	new L4D2Team:team = L4D2Team:GetClientTeam(client);
	return (client && (team == L4D2Team_Survivor || team == L4D2Team_Infected));
}

stock PrintToTeam(author, L4D2Team:team, const String:buffer[])
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && L4D2Team:GetClientTeam(client) == team)
		{
			CPrintToChatEx(client, author, "(%s) {teamcolor}%N{default}: %s", teamString[L4D2Team:GetClientTeam(author)], author, buffer);
		}
	}
}

public DummyHandler(Handle:menu, MenuAction:action, param1, param2) { }
