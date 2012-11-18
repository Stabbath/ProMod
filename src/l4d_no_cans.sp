#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define MAX_CAN_NAMES       4

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
    version     = "1.0",
    description = "Removes oxygen, propane, gas cans, and fireworks"
}

public OnPluginStart() {
   HookEvent("round_start", RoundStartHook);
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

public OnEntityCreated(entity, const String:classname[]) {
    if (entity <= 0 || entity > 2048) {
        return;
    }

    if (StrEqual("prop_physics", classname)) {
        SDKHook(entity, SDKHook_SpawnPost, CanCheck);
    }
}

public CanCheck(entity) {
    if (IsCan(entity)) {
        AcceptEntityInput(entity, "Kill");
    }
}

