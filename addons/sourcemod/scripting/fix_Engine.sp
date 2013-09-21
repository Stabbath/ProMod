#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

#pragma semicolon 1

/*=====< debug >=====*/
#define debug 0 // on,off

public Plugin:myinfo =
{
	name = "Engine Fix",
	author = "raziEiL [disawar1]",
	description = "Blocking ladder speed glitch, no fall damage bug, health boost glitch.",
	version = PLUGIN_VERSION,
	url = ""
}

static		Handle:g_Warning, Handle:g_HRate, Handle:Timer[MAXPLAYERS+1], count[MAXPLAYERS+1], chat[MAXPLAYERS+1],
			Float:g_CvarHRate, bool:g_CvarWarn;

public OnPluginStart()
{
	g_HRate = FindConVar("pain_pills_decay_rate");
	
	CreateConVar("engine_fix_version", PLUGIN_VERSION, "Engine Fix plugin version", FCVAR_REPLICATED|FCVAR_NOTIFY);

	g_Warning = CreateConVar("engine_warning", "1", "1: Display a warning message, 0: Disable notification.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	AutoExecConfig(true, "Fix_Engine");

	HookConVarChange(g_HRate, OnPillsRateChange);
	HookConVarChange(g_Warning, OnCVarChange);
		
	HookEvent("pills_used", Event_PillsUsed);
	HookEvent("heal_success", Event_HealSuccess);

	#if debug
	RegConsoleCmd("debug", CmdDebug);
	#endif
}
/*										+==========================================+
										|		 		LADDER GLITCH			   |
										|			  NO FALL DMG GLITCH		   |
										+==========================================+	
*/
public OnClientDisconnect(client)
{
	if (client && !IsFakeClient(client))
		chat[client] = false;
}

public Action:OnPlayerRunCmd(client, &buttons)
{
	if(IsPlayerAlive(client) && !IsFakeClient(client))
	{
		if (GetEntityMoveType(client) == MOVETYPE_LADDER){
		
			if (g_CvarWarn){
			
				if (buttons & 512 && (8 || 16) || buttons & 1024 && (8 || 16)){
					count[client]++;
					
					if (count[client] > 48){
						WarningsMsg(client, 1);
						count[client] = 0;
					}
				}
				else if (count[client] != 0) count[client] = 0;
			}
			if (buttons & 512 && (8 || 16)) buttons &=~IN_MOVELEFT;
			if (buttons & 1024 && (8 || 16)) buttons &=~IN_MOVERIGHT;
		}
		if (GetClientTeam(client) == 2 && IsFallDamage(client) && buttons & IN_USE){
			buttons &=~IN_USE;
			
			if (g_CvarWarn && !chat[client]){
				chat[client] = true;
				WarningsMsg(client, 2);
				CreateTimer(5.0, UnlockWarn, client);
			}
		}
	}
	return Plugin_Continue;
}

public Action:UnlockWarn(Handle:timer, any:client) chat[client] = false;

bool:IsFallDamage(client)
{
	return GetEntPropFloat(client, Prop_Send, "m_flFallVelocity") > 440;
}
/*										+==========================================+
										|		  		DROWN GLITCH		 	   |
										|						  				   |
										+==========================================+	
*/
public Action:Event_PillsUsed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (iDrownNotEqual(client)){
		TimeToKill(client);
		Timer[client] = CreateTimer(0.1, FixPillsGlitch, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:Event_HealSuccess(Handle:event, const String:name[], bool:dontBroadcast)
{
	new healer = GetClientOfUserId(GetEventInt(event, "userid"));
	new client = GetClientOfUserId(GetEventInt(event, "subject"));
	
	if (iDrownNotEqual(healer) || iDrownNotEqual(client)){
		new id;

		if (iDrownNotEqual(healer))
			id = healer;
		else 
			id = client;
	
		TimeToKill(id);
		Timer[id] = CreateTimer(0.1, FixPillsGlitch, id, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:FixPillsGlitch(Handle:timer, any:client)
{
	if (IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && iDrownNotEqual(client)){
	
		if ((CalculateLife(client) > 100 || GetClientHealth(client) == 100) && !IsPlayerIncap(client)){

			if (g_CvarWarn)
				WarningsMsg(client, 3);

			if (CalculateLife(client) > 100){
			
				new temp = CalculateLife(client) - 100;

				new Float:fGameTime = GetGameTime();
				new Float:fHealthTime = GetEntPropFloat(client, Prop_Send, "m_healthBufferTime");
				new Float:Prop = temp + (fGameTime - fHealthTime) * g_CvarHRate;
				
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - Prop);
			}

			SetEntProp(client, Prop_Data, "m_idrownrestored", GetEntProp(client, Prop_Data, "m_idrowndmg"));
			TimeToKill(client);
		}
	}
	else TimeToKill(client);
}

TimeToKill(client)
{
	if (Timer[client] != INVALID_HANDLE){
		KillTimer(Timer[client]);
		Timer[client] = INVALID_HANDLE;
	}
}
// @ Code by SilverShot
CalculateLife(client)
{
	new iHealth = GetClientHealth(client);
	new Float:fGameTime = GetGameTime();

	new Float:fHealthTime = GetEntPropFloat(client, Prop_Send, "m_healthBufferTime");
	new Float:fHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	fHealth -= (fGameTime - fHealthTime) * g_CvarHRate;
	if( fHealth < 0.0 )
		fHealth = 0.0;
	return RoundToFloor(fHealth) + iHealth;
}

IsPlayerIncap(client)
{
	return GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

iDrownNotEqual(client)
{
	return GetEntProp(client, Prop_Data, "m_idrowndmg") != GetEntProp(client, Prop_Data, "m_idrownrestored");
}

WarningsMsg(client, msg)
{
	decl String:STEAM_ID[32];
	GetClientAuthString(client, STEAM_ID, sizeof(STEAM_ID));
	
	if (msg == 1)
		PrintToChatAll("%N (%s) attempted to use a ladder speed glitch.", client, STEAM_ID);
	if (msg == 2)
		PrintToChatAll("%N (%s) is suspected of using a no fall damage bug.", client, STEAM_ID);
	if (msg == 3)
		PrintToChatAll("%N (%s) attempted to use a health boost glitch.", client, STEAM_ID);
}

public OnCVarChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	GetCVars();
}

public OnPillsRateChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	g_CvarHRate = GetConVarFloat(g_HRate);
}

public OnConfigsExecuted()
{
	GetCVars();
}

GetCVars()
{
	g_CvarWarn = GetConVarBool(g_Warning);
}
/*										+==========================================+
										|		 		Debug Stuff	   		  	   |
										+==========================================+	
*/
#if debug
static bool:ok[MAXPLAYERS+1], Handle:DebugTimer[MAXPLAYERS+1];
public Action:CmdDebug(client, agrs)
{
	ok[client] = !ok[client];

	if (ok[client]){
		PrintHintText(client, "LOADING...");
		CreateTimer(1.0, LoadDebug, client);
	}
	else {
		DisableDebug(client);
		PrintHintText(client, "Developers Stuff by raziEiL", client);
	}
	return Plugin_Handled;
}

public Action: LoadDebug(Handle:timer, any:client) DebugTimer[client] = CreateTimer(0.1, DebugMe, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

public Action:DebugMe(Handle:timer, any:client)
{
	if (IsClientInGame(client)){
		new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flGroundSpeed");
		new Float:fall = GetEntPropFloat(client, Prop_Send, "m_flFallVelocity");
		
		PrintCenterText(client, "%d/%d", GetEntProp(client, Prop_Data, "m_idrownrestored"), GetEntProp(client, Prop_Data, "m_idrowndmg"));
		
		if (GetEntityMoveType(client) == MOVETYPE_LADDER){
			if (speed > 130)
				PrintHintText(client, "Ground Speed %f WARNING!!!!", speed);
			else 
				PrintHintText(client, "Ground Speed %f", speed);
		}
		else {
			if (fall != 0){
				PrintHintText(client, "Move type %d | Flags %d\n Fall Speed: %f\n Health %d/%d", GetEntityMoveType(client), GetEntityFlags(client), fall, GetClientHealth(client), CalculateLife(client));
				if (fall > 500)
					PrintCenterText(client, "FALL DMG!");
			}
			else
				PrintHintText(client, "Move type %d | Flags %d\n Ground Speed %f\n Health %d/%d", GetEntityMoveType(client), GetEntityFlags(client), speed, GetClientHealth(client), CalculateLife(client));
		}
	}
	else DisableDebug(client);
}

DisableDebug(client)
{
	if (DebugTimer[client] != INVALID_HANDLE){
		KillTimer(DebugTimer[client]);
		DebugTimer[client] = INVALID_HANDLE;
	}
}
#endif
