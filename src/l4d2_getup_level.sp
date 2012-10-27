#pragma semicolon 1

#define L4D2UTIL_STOCKS_ONLY 1

#include <sourcemod>
#include <l4d2util>

// frames 116 fps 30 = 3.867
#define ANIM_LENGTH             3.9
#define GETUP_TIMER_INTERVAL    0.5

new const g_GetUpAnimations[SurvivorCharacter] = {
    // 0: Coach, 1: Nick, 2: Rochelle, 3: Ellis
    660, 671, 678, 675,
    // 4: Louis, 5: Zoey, 6: Bill, 7: Francis
    763, 823, 763, 766
};

public Plugin:myinfo =
{
    name        = "L4D2 Getup After Level Fix",
    author      = "Jahze",
    version     = "1.0",
    description = "Prevents a get up animation on a survivor who cleared himself from a charger"
}

public OnPluginStart() {
    HookEvent("charger_killed", ChargerKilled);
}

public Action:ChargerKilled(Handle:event, const String:name[], bool:dontBroadcast) {
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if (attacker <=0 || attacker > MaxClients+1) {
        return;
    }

    CreateTimer(GETUP_TIMER_INTERVAL, GetupTimer, attacker);
}

public Action:GetupTimer(Handle:timer, any:attacker) {
    new seq = GetEntProp(attacker, Prop_Send, "m_nSequence");
    new SurvivorCharacter:character = IdentifySurvivor(attacker);

    if (character == SC_NONE)
        return;

    if (seq == g_GetUpAnimations[character]) {
        SetEntPropFloat(attacker, Prop_Send, "m_flCycle", ANIM_LENGTH);
    }
}

