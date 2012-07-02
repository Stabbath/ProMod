#pragma semicolon 1

#define L4D2UTIL_STOCKS_ONLY
#define TEAM_SURVIVOR   2
#define TEAM_INFECTED   3

#include <sourcemod>
#include <sdktools>
#include <l4d2util>
#include <l4d2_direct>
#include <left4downtown>

new String:teamATank[32];
new String:teamBTank[32];

new Handle:hTeamATanks;
new Handle:hTeamBTanks;

public Plugin:myinfo = {
    name = "L4D2 Tank Control",
    author = "Jahze",
    version = "1.1",
    description = "Forces each player to play the tank once before resetting the pool."
};

public OnPluginStart() {
    hTeamATanks = CreateArray(32);
    hTeamBTanks = CreateArray(32);
}

public Action:L4D_OnTryOfferingTankBot(tank_index, &bool:enterStatis) {
    if (!IsFakeClient(tank_index)) {

        for (new i=1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i))
                continue;
        
            if (GetClientTeam(i) != TEAM_INFECTED)
                continue;

            PrintHintText(i, "Rage Meter Refilled");
            PrintToChat(i, "\x01[Tank Control] (\x03%N\x01) \x04Rage Meter Refilled", tank_index);
        }
        SetTankFrustration(tank_index, 100);
        L4D2Direct_SetTankPassedCount(L4D2Direct_GetTankPassedCount() + 1);
        return Plugin_Handled;
    }

    ChooseTank(true);
    
    if (GetDesignatedTank() != -1) {
        ForceTankPlayer();
    }
    
    return Plugin_Continue;
}

static GetDesignatedTank() {
    return GetInfectedPlayerBySteamId(GameRules_GetProp("m_bAreTeamsFlipped") ? teamBTank : teamATank);
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
    new bool:bTeamsFlipped = bool:GameRules_GetProp("m_bAreTeamsFlipped");
    
    for (new i = 1; i < MaxClients+1; i++) {
        if (!IsClientConnected(i) || !IsClientInGame(i)) {
            continue;
        }
        
        if (IsFakeClient(i) || !IsInfected(i) || HasBeenTank(i)) {
            continue;
        }
        
        GetClientAuthString(i, SteamId, sizeof(SteamId));
        PushArrayString(SteamIds, SteamId);
    }
    
    if (GetArraySize(SteamIds) == 0) {
        if (bFirstPass) {
            ClearArray(bTeamsFlipped ? hTeamBTanks : hTeamATanks);
            ChooseTank(false);
        }
        return;
    }
    
    new idx = GetRandomInt(0, GetArraySize(SteamIds)-1);
    GetArrayString(SteamIds, idx, bTeamsFlipped ? teamBTank : teamATank, sizeof(teamBTank));
    PushArrayString(bTeamsFlipped ? hTeamBTanks : hTeamATanks, bTeamsFlipped ? teamBTank : teamATank);
}

static ForceTankPlayer() {
    new tank = GetDesignatedTank();
    
    for (new i = 1; i < MaxClients+1; i++) {
        if (!IsClientConnected(i) || !IsClientInGame(i)) {
            continue;
        }
        
        if (IsInfected(i)) {
            if (tank == i) {
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

