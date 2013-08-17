#include <sourcemod>

public Plugin:myinfo =
{
	name = "Block Trolls",
	description = "Prevents calling votes while others are loading",
	author = "ProdigySim, CanadaRox",
	version = "2.0.0.0",
	url = "http://www.sourcemod.net/"
};
new bool:g_bBlockCallvote;

enum L4D2Team
{
	L4D2Team_None = 0,
	L4D2Team_Spectator,
	L4D2Team_Survivor,
	L4D2Team_Infected
}

public OnPluginStart()
{
	AddCommandListener(Vote_Listener, "callvote");
	AddCommandListener(Vote_Listener, "vote");
}

public OnMapStart()
{
	g_bBlockCallvote = true;
	CreateTimer(60.0, EnableCallvoteTimer);
}

public Action:Vote_Listener(client, const String:command[], argc)
{
	if (g_bBlockCallvote)
	{
		ReplyToCommand(client,
				"[SM] Voting is not enabled until 60s into the round");
		return Plugin_Handled;
	}
	new L4D2Team:team = L4D2Team:GetClientTeam(client);
	if (client && IsClientInGame(client) &&
			(team == L4D2Team_Survivor || team == L4D2Team_Infected))
	{
		return Plugin_Continue;
	}
	ReplyToCommand(client,
			"[SM] You must be ingame and not a spectator to vote");
	return Plugin_Handled;
}

public Action:CallvoteCallback(client, args)
{
	if (g_bBlockCallvote)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:EnableCallvoteTimer(Handle:timer)
{
	g_bBlockCallvote = false;
	return Plugin_Stop;
}
