#pragma semicolon 1

#include <sourcemod>
#include <l4d2_direct>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>

new bool:isTankActive;
new tankClient = -1;

public OnPluginStart()
{
	HookEvent("round_start", Round_Event, EventHookMode_PostNoCopy);
	HookEvent("round_end", Round_Event, EventHookMode_PostNoCopy);
	HookEvent("tank_spawn", TankSpawn_Event);
	HookEvent("player_death", PlayerDeath_Event);
}

public Round_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	isTankActive = false;
	tankClient = -1;
}

public TankSpawn_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	tankClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!isTankActive)
	{
		isTankActive = true;
		CreateTimer(0.1, MenuRefresh_Timer, _, TIMER_REPEAT);
		UpdatePanel();
	}
}

public PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && client <= MaxClients && GetClientTeam(client) == 3
			&& GetZombieClass(client) == 8)
	{
		new newTank = -1;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (client != i && IsClientInGame(i) && GetClientTeam(i) == 3
					&& GetZombieClass(i) == 8)
			{
				newTank = i;
				break;
			}
		}
		if (newTank <= 0)
		{
			isTankActive = false;
		}
	}
}

public Action:MenuRefresh_Timer(Handle:timer)
{
	if (isTankActive)
	{
		UpdatePanel();
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

UpdatePanel()
{
	if (isTankActive)
	{
		static Handle:menuPanel = INVALID_HANDLE;
		if (menuPanel != INVALID_HANDLE)
		{
			CloseHandle(menuPanel);
			menuPanel = INVALID_HANDLE;
		}

		menuPanel = CreatePanel();

		decl String:tankRage[24];
		Format(tankRage, sizeof(tankRage), "Rage: %d%%\nPass: #%d",
				GetTankFrustration(tankClient), L4D2Direct_GetTankPassedCount());
		DrawPanelText(menuPanel, tankRage);
		SendPanelToClient(menuPanel, tankClient, DummyHandler, 1);
	}
}

stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");
public DummyHandler(Handle:menu, MenuAction:action, param1, param2) { }
