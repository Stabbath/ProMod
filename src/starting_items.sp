#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define HEALTH_FIRST_AID_KIT    1
#define HEALTH_DEFIBRILLATOR    2
#define HEALTH_PAIN_PILLS       4
#define HEALTH_ADRENALINE       8

#define THROWABLE_PIPE_BOMB     16
#define THROWABLE_MOLOTOV       32
#define THROWABLE_VOMITJAR      64


public Plugin:myinfo =
{
    name = "Starting Items",
    author = "CircleSquared",
    description = "Gives health items and throwables to survivors at the start of each round",
    version = "1.0",
    url = "none"
}

new Handle:hCvarItemType;
new iItemFlags;

public OnPluginStart()
{
    hCvarItemType = CreateConVar("starting_item_flags", "0", "Item flags to give on leaving the saferoom (1: Kit, 2: Defib, 4: Pills, 8: Adren, 16: Pipebomb, 32: Molotov, 64: Bile)", FCVAR_PLUGIN);
    HookEvent("player_left_start_area", PlayerLeftStartArea);
}

public Action:PlayerLeftStartArea(Handle:event, const String:name[], bool:dontBroadcast)
{
    new String:strItemName[32];
    iItemFlags = GetConVarInt(hCvarItemType);

    if (iItemFlags) {
        if (iItemFlags & HEALTH_FIRST_AID_KIT) {
            strItemName = "weapon_first_aid_kit";
            giveStartingItem(strItemName);
        }
        else if (iItemFlags & HEALTH_DEFIBRILLATOR) {
            strItemName = "weapon_defibrillator";
            giveStartingItem(strItemName);
        }
        if (iItemFlags & HEALTH_PAIN_PILLS) {
            strItemName = "weapon_pain_pills";
            giveStartingItem(strItemName);
        }
        else if (iItemFlags & HEALTH_ADRENALINE) {
            strItemName = "weapon_adrenaline";
            giveStartingItem(strItemName);
        }
        if (iItemFlags & THROWABLE_PIPE_BOMB) {
            strItemName = "weapon_pipe_bomb";
            giveStartingItem(strItemName);
        }
        else if (iItemFlags & THROWABLE_MOLOTOV) {
            strItemName = "weapon_molotov";
            giveStartingItem(strItemName);
        }
        else if (iItemFlags & THROWABLE_VOMITJAR) {
            strItemName = "weapon_vomitjar";
            giveStartingItem(strItemName);
        }
    }
}

giveStartingItem(const String:strItemName[32])
{
    new startingItem;
    new Float:clientOrigin[3];

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && GetClientTeam(i) == 2) {
            startingItem = CreateEntityByName(strItemName);
            GetClientAbsOrigin(i, clientOrigin);
            TeleportEntity(startingItem, clientOrigin, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(startingItem);
            EquipPlayerWeapon(i, startingItem);
        }
    }
}