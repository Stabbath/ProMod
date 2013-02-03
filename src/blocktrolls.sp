#include <sourcemod>

public Plugin:myinfo =
{
	name = "Block Trolls",
	description = "Prevents calling votes while others are loading",
	author = "ProdigySim",
	version = "1.0.0.0",
	url = "http://www.sourcemod.net/"
};
new bool:g_bBlockCallvote;

public OnPluginStart()
{
	RegConsoleCmd("callvote", CallvoteCallback);
}

public OnMapStart()
{
	g_bBlockCallvote = true;
	CreateTimer(60, EnableCallvoteTimer);
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