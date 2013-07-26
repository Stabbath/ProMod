#pragma semicolon 1

#define L4D2UTIL_STOCKS_ONLY

#include <sourcemod>
#include <sdktools>
#include <l4d2util>
#include <l4d2_direct>
#include <left4downtown>

new queuedTank;
new String:tankSteamId[32];

new Handle:hTeamATanks;
new Handle:hTeamBTanks;

public Plugin:myinfo = {
    name = "L4D2 Tank Control",
    author = "Jahze, vintik",
    version = "1.2",
    description = "Forces each player to play the tank once before resetting the pool."
};

public OnPluginStart() {
    hTeamATanks = CreateArray(32);
    hTeamBTanks = CreateArray(32);
    RegConsoleCmd("sm_boss", BossCmd);
    RegConsoleCmd("sm_tank", BossCmd);
    RegConsoleCmd("sm_witch", BossCmd);
    HookEvent("player_left_start_area", EventHook:LeftStartAreaEvent, EventHookMode_PostNoCopy);
    HookEvent("round_end", EventHook:RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_team", OnTeamChange, EventHookMode_PostNoCopy);
}

public Action:BossCmd(client, args) {
    new L4D2_Team:iTeam = L4D2_Team:GetClientTeam(client);
    if (iTeam == L4D2Team_Spectator) {
        if (queuedTank) PrintToChat(client, "\x05%N \x01will become a tank", queuedTank);
        return Plugin_Handled;
    }
    for (new i = 1; i < MaxClients+1; i++) {
        if (IsClientConnected(i) && IsClientInGame(i) && L4D2_Team:GetClientTeam(i) == iTeam) {
            if (queuedTank) PrintToChat(i, "\x05%N \x01will become a tank", queuedTank);
        }
    }
    return Plugin_Handled;
}

public RoundEnd( ) {
    queuedTank = 0;
}

public LeftStartAreaEvent( ) {
    queuedTank = 0;
    ChooseTank(true);
    if (queuedTank) PrintToChatAll("\x05%N \x01will become a tank", queuedTank);
}

public OnTeamChange(Handle:event, String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client && client == queuedTank) {
        ChooseTank(true);
        if (queuedTank) PrintToChatAll("\x05%N \x01will become a tank", queuedTank);
    }
}

public OnClientDisconnect(client) {
    if (client && client == queuedTank) {
        ChooseTank(true);
        if (queuedTank) PrintToChatAll("\x05%N \x01will become a tank", queuedTank);
    }
}

public Action:L4D_OnTryOfferingTankBot(tank_index, &bool:enterStatis) {
    if (!IsFakeClient(tank_index)) {
        for (new i=1; i <= MaxClients; i++) {
            if (!IsClientInGame(i))
                continue;
        
            if (!IsInfected(i))
                continue;

            PrintHintText(i, "Rage Meter Refilled");
            PrintToChat(i, "\x01[Tank Control] (\x03%N\x01) \x04Rage Meter Refilled", tank_index);
        }
        SetTankFrustration(tank_index, 100);
        L4D2Direct_SetTankPassedCount(L4D2Direct_GetTankPassedCount() + 1);
        return Plugin_Handled;
    }
    
    if (queuedTank != 0) {
        ForceTankPlayer();
        PushArrayString(GameRules_GetProp("m_bAreTeamsFlipped") ? hTeamBTanks : hTeamATanks, tankSteamId);
        queuedTank = 0;
    }
    
    return Plugin_Continue;
}

static bool:HasBeenTank(client) {
    decl String:SteamId[32];
    GetClientAuthString(client, SteamId, sizeof(SteamId));
    for (new i = 0; i < GetArraySize(GameRules_GetProp("m_bAreTeamsFlipped") ? hTeamBTanks : hTeamATanks); ++i)
    {
        decl String:name[32];
        GetArrayString(GameRules_GetProp("m_bAreTeamsFlipped") ? hTeamBTanks : hTeamATanks, i, name, sizeof(name));
    }
    return (FindStringInArray(GameRules_GetProp("m_bAreTeamsFlipped") ? hTeamBTanks : hTeamATanks, SteamId) != -1);
}

static ChooseTank(bool:bFirstPass) {
    decl String:SteamId[32];
    new Handle:SteamIds = CreateArray(32);
    
    for (new i = 1; i < MaxClients+1; i++) {
        if (!IsClientConnected(i) || !IsClientInGame(i)) {
            continue;
        }
        
        if (IsFakeClient(i) || !IsInfected(i) || HasBeenTank(i) || i == queuedTank) {
            continue;
        }
        
        GetClientAuthString(i, SteamId, sizeof(SteamId));
        PushArrayString(SteamIds, SteamId);
    }
    
    if (GetArraySize(SteamIds) == 0) {
        if (bFirstPass) {
            ClearArray(GameRules_GetProp("m_bAreTeamsFlipped") ? hTeamBTanks : hTeamATanks);
            ChooseTank(false);
        }
        else queuedTank = 0;
        return;
    }
    
    new idx = GetRandomInt(0, GetArraySize(SteamIds)-1);
    GetArrayString(SteamIds, idx, tankSteamId, sizeof(tankSteamId));
    queuedTank = GetInfectedPlayerBySteamId(tankSteamId);
}

static ForceTankPlayer() {
    for (new i = 1; i < MaxClients+1; i++) {
        if (!IsClientConnected(i) || !IsClientInGame(i)) {
            continue;
        }
        
        if (IsInfected(i)) {
            if (queuedTank == i) {
                L4D2Direct_SetTankTickets(i, 20000);
            }
            else {
                L4D2Direct_SetTankTickets(i, 0);
            }
        }
    }
}

static GetInfectedPlayerBySteamId(const String:SteamId[]) {
    decl String:cmpSteamId[32];
   
    for (new i = 1; i < MaxClients+1; i++) {
        if (!IsClientConnected(i)) {
            continue;
        }
        
        if (!IsInfected(i)) {
            continue;
        }
        
        GetClientAuthString(i, cmpSteamId, sizeof(cmpSteamId));
        
        if (StrEqual(SteamId, cmpSteamId)) {
            return i;
        }
    }
    
    return -1;
}

