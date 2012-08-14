#pragma semicolon 1

#define L4D2UTIL_STOCKS_ONLY

#include <sourcemod>
#include <sdktools>
#include <l4d2_direct>
#include <l4d2lib>
#include <l4d2util>

public Plugin:myinfo = {
    name = "L4D2 Boss Flow Announce",
    author = "ProdigySim, Jahze, Stabby",
    version = "1.1",
    description = "Announce boss flow percents!"
};

new iWitchPercent	= 0;
new iTankPercent	= 0;

new Handle:g_hVsBossBuffer;
new Handle:g_hVsBossFlowMax;
new Handle:g_hVsBossFlowMin;

public OnPluginStart() {
    g_hVsBossBuffer = FindConVar("versus_boss_buffer");
    g_hVsBossFlowMax = FindConVar("versus_boss_flow_max");
    g_hVsBossFlowMin = FindConVar("versus_boss_flow_min");
    
    RegConsoleCmd("sm_boss", BossCmd);
    RegConsoleCmd("sm_tank", BossCmd);
    RegConsoleCmd("sm_witch", BossCmd);
    
    HookEvent("player_left_start_area", EventHook:LeftStartAreaEvent, EventHookMode_PostNoCopy);
    HookEvent("round_start", EventHook:RoundStartEvent, EventHookMode_PostNoCopy);
}

public LeftStartAreaEvent( ) {
    new iRoundNumber = InSecondHalfOfRound() ? 1 : 0;
    
    iTankPercent = RoundToNearest(GetTankFlow(iRoundNumber)*100);
    if (L4D2Direct_GetVSWitchToSpawnThisRound(iRoundNumber)) {
        iWitchPercent = RoundToNearest(GetWitchFlow(iRoundNumber)*100);
    }
    else {
        iWitchPercent = 0;
    }
	
    PrintToChatAll("\x01Tank spawn: [\x04%d%%\x01]", iTankPercent);

    if (iWitchPercent) {
        PrintToChatAll("\x01Witch spawn: [\x04%d%%\x01]", iWitchPercent);
    }
}

public RoundStartEvent() {
    CreateTimer(0.5, AdjustBossFlow);
}

PrintBossPercents(client) {
    if (iTankPercent) {
        PrintToChat(client, "\x01Tank spawn: [\x04%d%%\x01]", iTankPercent);
    }
    
    if (iWitchPercent) {
        PrintToChat(client, "\x01Witch spawn: [\x04%d%%\x01]", iWitchPercent);
    }
}

public Action:BossCmd(client, args) {    
    new L4D2_Team:iTeam = L4D2_Team:GetClientTeam(client);
    if (iTeam == L4D2Team_Spectator) {
        PrintBossPercents(client);
        return Plugin_Handled;
    }
    
    for (new i = 1; i < MaxClients+1; i++) {
        if (IsClientConnected(i) && IsClientInGame(i) && L4D2_Team:GetClientTeam(i) == iTeam) {
            PrintBossPercents(i);
            return Plugin_Handled;
        }
    }
	
    return Plugin_Continue;
}

Float:GetTankFlow(round) {
    return L4D2Direct_GetVSTankFlowPercent(round) -
        ( Float:GetConVarInt(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance() );
}

Float:GetWitchFlow(round) {
    return L4D2Direct_GetVSWitchFlowPercent(round) -
        ( Float:GetConVarInt(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance() );
}

public Action:AdjustBossFlow(Handle:timer) {
    new iMinFlow = L4D2_GetMapValueInt("tank_ban_flow_min", -1);
    new iMaxFlow = L4D2_GetMapValueInt("tank_ban_flow_max", -1);
    
    // Check inputs exist and are sensible
    if (iMinFlow == -1 || iMaxFlow == -1 || iMaxFlow < iMinFlow) {
        return;
    }

    new iRoundNumber = InSecondHalfOfRound() ? 1 : 0;
    new Float:fMinFlow = Float:float(iMinFlow) / 100.0;
    new Float:fMaxFlow = Float:float(iMaxFlow) / 100.0;
    new Float:fTankFlow = L4D2Direct_GetVSTankFlowPercent(iRoundNumber);
    
    // Is the tank in the allowed spawn range?
    if (fTankFlow < fMinFlow || fTankFlow > fMaxFlow) {
        return;
    }
    
    new Float:fCvarMaxFlow = GetConVarFloat(g_hVsBossFlowMax);
    new Float:fCvarMinFlow = GetConVarFloat(g_hVsBossFlowMin);
    new Float:fCvarFlowRange = fCvarMaxFlow - fCvarMinFlow;
    
    fMinFlow = fMinFlow < fCvarMinFlow ? fCvarMinFlow : fMinFlow;
    fMaxFlow = fMaxFlow > fCvarMaxFlow ? fCvarMaxFlow : fMaxFlow;
    
    // XXX: Spawn the tank between the allowed min and max cutting out the
    // banned area
    new Float:fFlowRange = fMaxFlow - fMinFlow;
    new Float:fFlow = fCvarMinFlow + GetRandomFloat(0.0, fCvarFlowRange-fFlowRange);
    fFlow = fFlow >= fMinFlow ? fFlow + fFlowRange : fFlow;
    
    L4D2Direct_SetVSTankFlowPercent(0, fFlow);
    L4D2Direct_SetVSTankFlowPercent(1, fFlow);
}