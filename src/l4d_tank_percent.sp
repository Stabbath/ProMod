#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <l4d2lib>

new bool:bSecondRound;
new iTankFlow;

new Handle:cvar_tankPercent;

new String:sTankFlowMsg[128];

public Plugin:myinfo = {
    name        = "L4D2 Tank Percent",
    author      = "Jahze + CircleSquared",
    version     = "1.2a",
    description = "Tell players when the tank will spawn"
};

public OnPluginStart() {
    cvar_tankPercent = CreateConVar("l4d_tank_percent", "1", "Tell players when the tank will spawn", FCVAR_PLUGIN);
    HookConVarChange(cvar_tankPercent, TankPercentChange);
    
    RegConsoleCmd("sm_tank", TankCmd);
    
    PluginEnable();
}

public OnPluginEnd() {
    PluginDisable();
}

public OnMapStart() {
    bSecondRound    = false;
    sTankFlowMsg[0] = 0;
}

public OnMapEnd() {
    bSecondRound = false;
}

PluginEnable() {
    HookEvent("round_end", DeathwishRoundEnd);
    HookEvent("player_left_start_area", DeathwishPlayerLeftStartArea);
}

PluginDisable() {
    UnhookEvent("round_end", DeathwishRoundEnd);
    UnhookEvent("player_left_start_area", DeathwishPlayerLeftStartArea);
}

public TankPercentChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if ( StringToInt(newValue) == 0 ) {
        PluginDisable();
    }
    else {
        PluginEnable();
    }
}

public Action:DeathwishPlayerLeftStartArea( Handle:event, const String:name[], bool:dontBroadcast ) {
    if ( !bSecondRound ) {    
        decl Float:tankFlows[2];
        
        L4D2_GetVersusTankFlowPercent(tankFlows);
        iTankFlow = RoundToNearest(tankFlows[0] * 100.0);
        
        // Block certain tank spawns based on map info
        AdjustTankFlow();
        
        Format(sTankFlowMsg, sizeof(sTankFlowMsg), "\x01[Tank] The tank will spawn at [\x04%d%s\x01] through the map.", iTankFlow, "%%");
    }
    
    PrintToChatAll(sTankFlowMsg);
}

public Action:DeathwishRoundEnd( Handle:event, const String:name[], bool:dontBroadcast ) {
    bSecondRound = true;
}


public Action:TankCmd(client, args) {
    if ( strlen(sTankFlowMsg) ) {
        ReplyToCommand(client, sTankFlowMsg);
    }
}

AdjustTankFlow() {
    new minFlow = L4D2_GetMapValueInt("tank_ban_flow_min", -1);
    new maxFlow = L4D2_GetMapValueInt("tank_ban_flow_max", -1);
    
    // Check inputs exist and are sensible
    if ( minFlow == -1 || maxFlow == -1 || maxFlow < minFlow ) {
        return;
    }

    // Is the tank in the allowed spawn range?    
    if ( iTankFlow < minFlow || iTankFlow > maxFlow ) {
        return;
    }
    
    LogMessage("[Deathwish] Found a banned tank spawn at %d (banned area: %d to %d)",
        iTankFlow, minFlow, maxFlow);
    
    minFlow = minFlow < 15 ? 15 : minFlow;
    maxFlow = maxFlow > 85 ? 85 : maxFlow;
    
    // XXX: Spawn the tank between 15% and 85% cutting out the banned area
    new range = maxFlow - minFlow;
    new r     = 15 + GetRandomInt(0, 70-range);
    iTankFlow = r >= minFlow ? r + range : r;
    
    new Float:flows[2];
    
    flows[0] = float(iTankFlow)/100.0;
    flows[1] = flows[0];
    
    LogMessage("[Deathwish] Adjusted tank spawn to %d (%f)", iTankFlow, flows[0]);
    
    L4D2_SetVersusTankFlowPercent(flows);
}