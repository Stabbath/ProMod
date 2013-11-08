#pragma semicolon 1

#include <sourcemod>
#include <l4d2_direct>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>

new bool:isTankActive;
new tankClient = -1;
new Handle:burnDurationCvar;
new bool:hiddenTankPanel[MAXPLAYERS + 1];

public OnPluginStart()
{
	HookEvent("round_start", Round_Event, EventHookMode_PostNoCopy);
	HookEvent("round_end", Round_Event, EventHookMode_PostNoCopy);
	HookEvent("tank_spawn", TankSpawn_Event);
	HookEvent("player_death", PlayerDeath_Event);

	burnDurationCvar = FindConVar("tank_burn_duration");
	
	RegConsoleCmd("sm_tankhud", ToggleTankPanel_Cmd, "Toggles the tank panel visibility so other menus can be seen");
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
		CreateTimer(0.5, MenuRefresh_Timer, _, TIMER_REPEAT);
	}
}

stock UpdateTank(client) {
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

public PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && client <= MaxClients && GetClientTeam(client) == 3 && GetZombieClass(client) == 8)
	{
		UpdateTank(client);
	}
}

public Action:MenuRefresh_Timer(Handle:timer)
{
	static Handle:menuPanel = INVALID_HANDLE;
	if (isTankActive)
	{
		static String:buffer[64], String:rageBuffer[64];
		if (menuPanel != INVALID_HANDLE)
		{
			CloseHandle(menuPanel);
		}
		menuPanel = CreatePanel();

		// Header
		SetPanelTitle(menuPanel, "Tank HUD"); 

		// Name
		if (!IsFakeClient(tankClient))
		{
			GetClientName(tankClient, buffer, sizeof(buffer));
			
			if (strlen(buffer) > 25)
			{
				buffer[23] = '.';
				buffer[24] = '.';
				buffer[25] = '.';
				buffer[26] = 0;
			}
			
			Format(buffer, sizeof(buffer), "Control: %s", buffer);
			DrawPanelText(menuPanel, buffer);
		}
		else
		{
			DrawPanelText(menuPanel, "Control: AI");
		}

		// Health
		static maxHealth = -1;
		if (maxHealth < 0) {
			maxHealth = RoundToNearest(GetConVarFloat(FindConVar("z_tank_health"))*1.5);
		}
		new health = GetClientHealth(tankClient);
		Format(buffer, sizeof(buffer), "Health : %i / %.1f%%", health, 100.0*health/maxHealth);
		DrawPanelText(menuPanel, buffer);

		// Rage
		if (!IsFakeClient(tankClient)) {
			FormatEx(rageBuffer, sizeof(rageBuffer), "Rage   : %d%% (Pass #%i)", GetTankFrustration(tankClient), L4D2Direct_GetTankPassedCount());
			DrawPanelText(menuPanel, rageBuffer);
		}

		// Fire
		if (GetEntityFlags(tankClient) & FL_ONFIRE)
		{
			FormatEx(buffer, sizeof(buffer), "Burning: %.1f sec", health/GetConVarInt(burnDurationCvar));
			DrawPanelText(menuPanel, buffer);
		}

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != 2 && i != tankClient && !hiddenTankPanel[tankClient])
			{
				SendPanelToClient(menuPanel, i, DummyHandler, 3);
			}
		}


		// tank-only hud
		static Handle:tankPanel = INVALID_HANDLE;
		if (!IsFakeClient(tankClient) && !hiddenTankPanel[tankClient]) {
			if (tankPanel != INVALID_HANDLE)
			{
				CloseHandle(tankPanel);
			}
			tankPanel = CreatePanel();

			SetPanelTitle(tankPanel, "Tank HUD");
			DrawPanelText(tankPanel, rageBuffer);

			SendPanelToClient(tankPanel, tankClient, DummyHandler, 3);
		}

		return Plugin_Continue;
	}

	return Plugin_Stop;
}

stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");
public DummyHandler(Handle:menu, MenuAction:action, param1, param2) { }

public Action:ToggleTankPanel_Cmd(client,args)
{
	hiddenTankPanel[tankClient] = !hiddenTankPanel[tankClient];
	if(hiddenTankPanel[tankClient])
	{
		ReplyToCommand(client,"Tank HUD is now disabled.");
	}
	else
	{
		ReplyToCommand(client,"Tank HUD is now enabled.");
	}
}

public OnClientDisconnect(client)
{
	if (client == tankClient) {
		UpdateTank(client);
	}
	hiddenTankPanel[client] = false;
}
