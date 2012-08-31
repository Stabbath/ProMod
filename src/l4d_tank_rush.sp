#pragma semicolon 1

#include <sourcemod>
#include <left4downtown>

const TANK_ZOMBIE_CLASS = 8;

new bool:bSecondRound = false;
new bool:bTankAlive = false;
new bool:bHooked = false;

new iDistance;

new Handle:cvar_noTankRush;

public Plugin:myinfo = {
    name = "L4D2 No Tank Rush",
    author = "Jahze, vintik",
    version = "1.1",
    description = "Stops distance points accumulating whilst the tank is alive"
};

public OnPluginStart() {
    cvar_noTankRush = CreateConVar("l4d_no_tank_rush", "1", "Prevents survivor team from accumulating points whilst the tank is alive", FCVAR_PLUGIN);
    HookConVarChange(cvar_noTankRush, NoTankRushChange);
    if (GetConVarBool(cvar_noTankRush)) {
        PluginEnable();
    }
}

public OnPluginEnd() {
    bHooked = false;
    PluginDisable();
}

public OnMapStart() {
    bSecondRound = false;
    bTankAlive = false;
}

PluginEnable() {
    if ( !bHooked ) {
        HookEvent("round_start", RoundStart);
        HookEvent("round_end", RoundEnd);
        HookEvent("tank_spawn", TankSpawn);
        HookEvent("player_death", PlayerDeath);
        
        if ( FindTank() > 0 ) {
            FreezePoints();
        }
        bHooked = true;
    }
}

PluginDisable() {
    if ( bHooked ) {
        UnhookEvent("round_start", RoundStart);
        UnhookEvent("round_end", RoundEnd);
        UnhookEvent("tank_spawn", TankSpawn);
        UnhookEvent("player_death", PlayerDeath);
        
        bHooked = false;
    }
    UnFreezePoints();
}

public NoTankRushChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if ( StringToInt(newValue) == 0 ) {
        PluginDisable();
    }
    else {
        PluginEnable();
    }
}

public Action:RoundStart( Handle:event, const String:name[], bool:dontBroadcast ) {
    if ( bSecondRound ) {
        UnFreezePoints();
    }
}

public Action:RoundEnd( Handle:event, const String:name[], bool:dontBroadcast ) {
    bSecondRound = true;
}

public Action:TankSpawn( Handle:event, const String:name[], bool:dontBroadcast ) {
    FreezePoints(true);
}

public Action:PlayerDeath( Handle:event, const String:name[], bool:dontBroadcast ) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( IsTank(client) ) {
        CreateTimer(0.1, CheckForTanksDelay, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public OnClientDisconnect( client ) {
    if ( IsTank(client) ) {
        CreateTimer(0.1, CheckForTanksDelay, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action:CheckForTanksDelay( Handle:timer ) {
    if ( FindTank() == -1 ) {
        UnFreezePoints(true);
    }
}

FreezePoints( bool:show_message = false ) {
    if ( !bTankAlive ) {
        iDistance = L4D_GetVersusMaxCompletionScore();
        if ( show_message ) PrintToChatAll("[NoTankRush] Tank spawned. Freezing distance points!");
        L4D_SetVersusMaxCompletionScore(0);
        bTankAlive = true;
    }
}

UnFreezePoints( bool:show_message = false ) {
    if ( bTankAlive ) {
        if ( show_message ) PrintToChatAll("[NoTankRush] Tank is dead. Unfreezing distance points!");
        L4D_SetVersusMaxCompletionScore(iDistance);
        bTankAlive = false;
    }
}

FindTank() {
    for ( new i = 1; i <= MaxClients; i++ ) {
        if ( IsTank(i) && IsPlayerAlive(i) ) {
            return i;
        }
    }
    
    return -1;
}

bool:IsTank( client ) {
    if ( client <= 0
    || !IsClientInGame(client)
    || GetClientTeam(client) != 3 ) {
        return false;
    }
    
    new playerClass = GetEntProp(client, Prop_Send, "m_zombieClass");
    
    if ( playerClass == TANK_ZOMBIE_CLASS ) {
        return true;
    }
    
    return false;
}