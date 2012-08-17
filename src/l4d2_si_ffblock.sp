#include <sourcemod>
#include <sdkhooks>


public Plugin:myinfo = 
{
	name = "L4D2 Infected Friendly Fire Disable",
	author = "ProdigySim, Don",
	description = "Disables friendly fire between infected players.",
	version = "1.2",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}

new bool:lateLoad
new Handle:cvar_ffblock;
new Handle:cvar_allow_tank_ff;

public OnPluginStart()
{
	cvar_ffblock=CreateConVar("l4d2_block_infected_ff", "1", "Disable SI->SI friendly fire");
	cvar_allow_tank_ff=CreateConVar("l4d2_infected_ff_allow_tank", "0", "Do not disable friendly fire for tanks on other SI");
	if(lateLoad)
	{
		for(new cl=1; cl <= MaxClients; cl++)
		{
			if(IsClientInGame(cl))
			{
				SDKHook(cl, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	lateLoad=late;
	return APLRes_Success;
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if(GetConVarBool(cvar_ffblock) && IsClientAndInGame(victim) && GetClientTeam(victim) == 3 && IsClientAndInGame(attacker) && GetClientTeam(attacker) == 3)
	{
		if(!GetConVarBool(cvar_allow_tank_ff) || GetEntProp(attacker, Prop_Send, "m_zombieClass") != 8) // If no tank ff or attacker is not tank
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

bool:IsClientAndInGame(index)
{
	return (index > 0 && index <= MaxClients && IsClientInGame(index));
}
