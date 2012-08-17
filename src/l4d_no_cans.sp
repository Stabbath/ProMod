#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define MAX_CAN_NAMES       4

new bool:bNoCans = true;

new Handle:cvar_noCans;

static const String:CAN_MODEL_NAMES[MAX_CAN_NAMES][] = {
    "models/props_junk/gascan001a.mdl",
    "models/props_junk/propanecanister001a.mdl",
    "models/props_equipment/oxygentank01.mdl",
    "models/props_junk/explosive_box001.mdl"
};

public Plugin:myinfo =
{
    name        = "L4D2 Remove Cans",
    author      = "Jahze",
    version     = "0.2",
    description = "Removes oxygen, propane, gas cans, and fireworks"
}

public OnPluginStart() {
    cvar_noCans = CreateConVar("l4d_no_cans", "1", "Removes oxygen, propane, gas cans, and fireworks", FCVAR_PLUGIN);
    HookConVarChange(cvar_noCans, NoCansChange);
    
    PluginEnable();
}

public OnPluginEnd() {
    PluginDisable();
}

PluginDisable() {
    UnhookEvent("round_start", RoundStartHook);
}

PluginEnable() {
    HookEvent("round_start", RoundStartHook);
}

public NoCansChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if ( StringToInt(newValue) == 0 ) {
        bNoCans = false;
        PluginDisable();
    }
    else {
        bNoCans = true;
        PluginEnable();
    }
}

IsCan( iEntity ) {
    decl String:sModelName[128];
    
    GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
    
    for ( new i = 0; i < MAX_CAN_NAMES; i++ ) {
        if ( StrEqual(sModelName, CAN_MODEL_NAMES[i], false) ) {
            if ( bool:GetEntProp(iEntity, Prop_Send, "m_isCarryable", 1) ) {
                return true;
            }
        }
    }
    
    return false;
}

public Action:RoundStartHook( Handle:event, const String:name[], bool:dontBroadcast ) {
    CreateTimer(1.0, RoundStartNoCans);
}

public Action:RoundStartNoCans( Handle:timer ) {
    if ( !bNoCans ) {
        return;
    }
    
    new iEntity;
    
    while ( (iEntity = FindEntityByClassname(iEntity, "prop_physics")) != -1 ) {
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) ) {
            continue;
        }
        
        // We found a gas can
        if ( IsCan(iEntity) ) {
            AcceptEntityInput(iEntity, "Kill");
        }
    }
}
