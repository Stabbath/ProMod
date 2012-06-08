#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
 
#define L4DBUILD 1
 
new bool:bLateLoad;
new Handle:cvar_siSlowdown;
#if defined(L4DBUILD)
new Handle:cvar_siexcept;
#endif
 
public Plugin:myinfo = {
    name        = "L4D2 Remove Slowdown Modified",
    author      = "Jahze, Blade, ProdigySim",
    version     = "1.1b",
    description = "Removes the slow down from special infected"
};
 
public APLRes:AskPluginLoad2( Handle:plugin, bool:late, String:error[], errMax ) {
    bLateLoad = late;
    return APLRes_Success;    
}
 
public OnPluginStart() {
    cvar_siSlowdown = CreateConVar("l4d2_no_slowdown", "1", "Enables/disables removal of the slow down that weapons to do special infected", FCVAR_PLUGIN);
#if defined(L4DBUILD)
    cvar_siexcept = CreateConVar("l4d2_slowdown_except_si_flags", "0", "Bitfield for exempting SI in no slowdown functionality. From least significant: Smoker, Boomer, Hunter, Spitter, Jockey, Charger, Tank", FCVAR_PLUGIN);
#endif
   
    if ( bLateLoad ) {
        for ( new i = 1; i < MaxClients+1; i++ ) {
            if ( IsClientInGame(i) ) {
                SDKHook(i, SDKHook_OnTakeDamagePost, SiSlowdown);
            }
        }
    }
}
 
public OnClientPutInServer( client ) {
    SDKHook(client, SDKHook_OnTakeDamagePost, SiSlowdown);
}
 
public Action:SiSlowdown( victim, &attacker, &inflictor, &Float:damage, &damageType, &weapon, Float:damageForce[3], Float:damagePosition[3] ) {
        if (GetConVarBool(cvar_siSlowdown) && IsSi(victim)) {
                new class = GetEntProp(victim, Prop_Send, "m_zombieClass");
                if(class == 8) // tank
                {
                        --class;
                }
                class--;
                new except = GetConVarInt(cvar_siexcept);
                if(class >=0 && class <=6 && ((1 << class) & except))
                {
                        return Plugin_Continue;
                }
                SetEntPropFloat(victim, Prop_Send, "m_flVelocityModifier", 1.0);
			}
	return Plugin_Continue;
		}     
       
bool:IsSi( client ) {
    if ( IsClientConnected(client)
    && IsClientInGame(client)
    && GetClientTeam(client) == 3 ) {
        return true;
    }
   
    return false;
}