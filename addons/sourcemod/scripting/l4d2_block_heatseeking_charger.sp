#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown.inc>

#define TEAM_SURVIVOR 		2
#define TEAM_INFECTED 		3

#define ZC_CHARGER              6

#define DISCONNECT_DELAY        0.1


// CVars
new     Handle:         hPluginEnabled                  = INVALID_HANDLE;               // convar: enable plugin
new     bool:           bIsCharging[MAXPLAYERS+1];                                      // whether client is charging

/*
    -----------------------------------------------------------------------------------------------------------------------------------------------------

    To-Do
    ---------
        - only works with 1 charger right now. might make it work (well) with multiple chargers
        

    Changelog
    ---------
        0.2
            - fixed false positive-problem. Replaced flawed m_isCharging check with tracking hooks.
            
        0.1
            - fixed charger turning immortal. Duh.
            - stumbles any charger that gets sent AI mid-charge on tank pass or client disconnect
            
    -----------------------------------------------------------------------------------------------------------------------------------------------------
 */

public Plugin:myinfo = 
{
    name = "Block Heat Seeking Charger",
    author = "Tabun",
    description = "Blocks heatseeking chargers (ones that go AI mid-charge).",
    version = "0.2",
    url = "nope"
}


/* -------------------------------
 *      Init
 * ------------------------------- */

public OnPluginStart()
{
    // cvars
    hPluginEnabled = CreateConVar("sm_blockhscharge_enabled", "1", "Block the heatseeking charger.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    
    // hooks / events
    HookEvent("round_start",            Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("tank_spawn",             Event_TankSpawned, EventHookMode_Post);
    HookEvent("charger_charge_start",   Event_ChargeStart);
    HookEvent("charger_charge_end",	Event_ChargeEnd);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    ResetAllClientStatus();
}

public OnMapStart()
{
    ResetAllClientStatus();
}


/* -------------------------------
 *      Detect HS Chargers
 * ------------------------------- */

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

public Event_TankSpawned(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (!GetConVarBool(hPluginEnabled))
            return;
    
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if (!bIsCharging[client])
        return;
    
    // client left a charging charger behind when becoming tank..
    // it is a heatseeking charger (or it is very likely to be one)
    FixHeatSeeker(client);    
}

public OnClientDisconnect(client)
{
    if (!GetConVarBool(hPluginEnabled))
        return;
    
    if (IsFakeClient(client))
        return;
    
    if (!bIsCharging[client])
        return;
    
    // player was charging before the quit...
    //  needs a delay, or the charger won't exist yet
    CreateTimer(DISCONNECT_DELAY, Timer_FixHeatSeeker, client);
}

public Action:Timer_FixHeatSeeker(Handle:timer, any:client)
{
    FixHeatSeeker(client);
}


FixHeatSeeker(client)
{
    bIsCharging[client] = false;
    
    new chargeClient = FindHeatSeekingChargerClient();
    
    if (chargeClient)
    {
        StumblePlayer(chargeClient);
        
        if (IsClientAndInGame(client)) {
            PrintToChatAll("[chargeblock] Heatseeking charger detected, fired by %N.", client);
        } else {
            PrintToChatAll("[chargeblock] Heatseeking charger detected, fired by disconnected player.");
        }
    }
}

FindHeatSeekingChargerClient()
{
    for (new client=1; client <= MaxClients; client++)
    {
        
        if (!IsClientAndInGame(client))
            continue;
        
        if (GetClientTeam(client) != TEAM_INFECTED      ||
            !IsPlayerAlive(client)                      ||
            !IsFakeClient(client)                       ||
            GetEntProp(client, Prop_Send, "m_zombieClass") != ZC_CHARGER)
            continue;
        
        return client;
    }
    return 0;
}


/* --------------------------------------
 *     Shared function(s)
 * -------------------------------------- */

bool:IsClientAndInGame(index)
{
    if (index > 0 && index < MaxClients)
    {
        return IsClientInGame(index);
    }
    return false;
}

stock ResetAllClientStatus()
{
    for (new i=0; i<= MaxClients; i++)
    {
        bIsCharging[i] = false;
    }
}


public StumblePlayer(client)
{
    
    decl Float:vPos[3], String:sTemp[16];
    GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vPos);

    // shake
    new entity = CreateEntityByName("env_shake");
    if( entity != -1 )
    {
        DispatchKeyValue(entity, "spawnflags", "8");
        DispatchKeyValue(entity, "amplitude", "16.0");
        DispatchKeyValue(entity, "frequency", "1.5");
        DispatchKeyValue(entity, "duration", "0.9");
        FloatToString(1.0, sTemp, sizeof(sTemp));           // distance = 1.0? test.
        DispatchKeyValue(entity, "radius", sTemp);
        DispatchSpawn(entity);
        ActivateEntity(entity);
        AcceptEntityInput(entity, "Enable");
        TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
        AcceptEntityInput(entity, "StartShake");
        SetVariantString("OnUser1 !self:Kill::1.1:1");
        AcceptEntityInput(entity, "AddOutput");
        AcceptEntityInput(entity, "FireUser1");
    }
    new shake = entity;
    
    //SetEntProp(client, Prop_Data, "m_takedamage", 0);
    L4D_StaggerPlayer(client, shake, vPos);
}


