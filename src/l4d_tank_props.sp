#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define TANK_ZOMBIE_CLASS   8

new bool:tankSpawned;

new iTankClient = -1;

new Handle:cvar_tankProps;

new Handle:hTankProps       = INVALID_HANDLE;
new Handle:hTankPropsHit    = INVALID_HANDLE;

public Plugin:myinfo = {
    name        = "L4D2 Tank Props",
    author      = "Jahze",
    version     = "1.1",
    description = "Stop tank props from fading whilst the tank is alive"
};

public OnPluginStart() {
    cvar_tankProps = CreateConVar("l4d_tank_props", "1", "Prevent tank props from fading whilst the tank is alive", FCVAR_PLUGIN);
    HookConVarChange(cvar_tankProps, TankPropsChange);
    
    PluginEnable();
}

PluginEnable() {
    SetConVarBool(FindConVar("sv_tankpropfade"), false);
    
    hTankProps = CreateArray();
    hTankPropsHit = CreateArray();
    
    HookEvent("round_start", TankPropRoundReset);
    HookEvent("round_end", TankPropRoundReset);
    HookEvent("tank_spawn", TankPropTankSpawn);
    HookEvent("player_death", TankPropTankKilled);
}

PluginDisable() {
    SetConVarBool(FindConVar("sv_tankpropfade"), true);
    
    CloseHandle(hTankProps);
    CloseHandle(hTankPropsHit);
    
    UnhookEvent("round_start", TankPropRoundReset);
    UnhookEvent("round_end", TankPropRoundReset);
    UnhookEvent("tank_spawn", TankPropTankSpawn);
    UnhookEvent("player_death", TankPropTankKilled);
}

public TankPropsChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if ( StringToInt(newValue) == 0 ) {
        PluginDisable();
    }
    else {
        PluginEnable();
    }
}

public Action:TankPropRoundReset( Handle:event, const String:name[], bool:dontBroadcast ) {
    tankSpawned = false;
    
    UnhookTankProps();
    ClearArray(hTankPropsHit);
}

public Action:TankPropTankSpawn( Handle:event, const String:name[], bool:dontBroadcast ) {
    if ( !tankSpawned ) {
        UnhookTankProps();
        ClearArray(hTankPropsHit);
        
        HookTankProps();
        
        tankSpawned = true;
    }    
}

public Action:TankPropTankKilled( Handle:event, const String:name[], bool:dontBroadcast ) {
    if ( !tankSpawned ) {
        return;
    }
    
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( client != iTankClient ) {
        return;
    }
    
    CreateTimer(0.1, TankDeadCheck);
}

public Action:TankDeadCheck( Handle:timer ) {
    if ( GetTankClient() == -1 ) {
        UnhookTankProps();
        CreateTimer(5.0, FadeTankProps);
        tankSpawned = false;
    }
}

public PropDamaged(victim, attacker, inflictor, Float:damage, damageType) {
    if ( attacker == GetTankClient() || FindValueInArray(hTankPropsHit, inflictor) != -1 ) {
        if ( FindValueInArray(hTankPropsHit, victim) == -1 ) {
            PushArrayCell(hTankPropsHit, victim);
        }
    }
}

public Action:FadeTankProps( Handle:timer ) {
    for ( new i = 0; i < GetArraySize(hTankPropsHit); i++ ) {
        if ( IsValidEdict(GetArrayCell(hTankPropsHit, i)) ) {
            RemoveEdict(GetArrayCell(hTankPropsHit, i));
        }
    }
    
    ClearArray(hTankPropsHit);
}

bool:IsTankProp( iEntity ) {
    if ( !IsValidEdict(iEntity) ) {
        return false;
    }
    
    decl String:className[64];
    
    GetEdictClassname(iEntity, className, sizeof(className));
    if ( StrEqual(className, "prop_physics") ) {
        if ( GetEntProp(iEntity, Prop_Send, "m_hasTankGlow", 1) ) {
            return true;
        }
    }
    else if ( StrEqual(className, "prop_car_alarm") ) {
        return true;
    }
    
    return false;
}

HookTankProps() {
    new iEntCount = GetMaxEntities();
    
    for ( new i = 1; i <= iEntCount; i++ ) {
        if ( IsTankProp(i) ) {
            SDKHook(i, SDKHook_OnTakeDamagePost, PropDamaged);
            PushArrayCell(hTankProps, i);
        }
    }
}

UnhookTankProps() {
    for ( new i = 0; i < GetArraySize(hTankProps); i++ ) {
        SDKUnhook(GetArrayCell(hTankProps, i), SDKHook_OnTakeDamagePost, PropDamaged);
    }
    
    ClearArray(hTankProps);
}

GetTankClient() {
    if ( iTankClient == -1 || !IsTank(iTankClient) ) {
        iTankClient = FindTank();
    }
    
    return iTankClient;
}

FindTank() {
    for ( new i = 1; i <= MaxClients; i++ ) {
        if ( IsTank(i) ) {
            return i;
        }
    }
    
    return -1;
}

bool:IsTank( client ) {
    if ( client < 0
    || !IsClientConnected(client)
    || !IsClientInGame(client)
    || GetClientTeam(client) != 3
    || !IsPlayerAlive(client) ) {
        return false;
    }
    
    new playerClass = GetEntProp(client, Prop_Send, "m_zombieClass");
    
    if ( playerClass == TANK_ZOMBIE_CLASS ) {
        return true;
    }
    
    return false;
}
