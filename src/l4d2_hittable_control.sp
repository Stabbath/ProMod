#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new bool:	bIsBridge;			//for parish bridge cars
new bool:	bIgnoreOverkill		[MAXPLAYERS + 1];	//for hittable hits

//cvars
new Handle: hBridgeCarDamage		= INVALID_HANDLE;
new Handle: hLogStandingDamage		= INVALID_HANDLE;
new Handle: hHaybaleStandingDamage	= INVALID_HANDLE;
new Handle: hBaggageStandingDamage	= INVALID_HANDLE;
new Handle: hStandardIncapDamage	= INVALID_HANDLE;
new Handle: hTankSelfDamage			= INVALID_HANDLE;

public Plugin:myinfo = 
{
    name = "L4D2 Hittable Control",
    author = "Stabby",
    version = "0.1",
    description = "Removes godframes from witch slashes and tank hittables and allows for standardisation of hittable damage values."
};

public OnPluginStart()
{
	hBridgeCarDamage		= CreateConVar( "hc_bridge_car_damage",			"25.0",
											"Damage of cars in the parish bridge finale. Overrides standard incap damage on incapacitated players.",
											FCVAR_PLUGIN, true, 0.0, true, 100.0 );
	hLogStandingDamage		= CreateConVar( "hc_log_standing_damage",		"48.0",
											"Damage of hittable swamp fever (not BH) logs to non-incapped survivors.",
											FCVAR_PLUGIN, true, 0.0, true, 100.0 );
	hHaybaleStandingDamage	= CreateConVar( "hc_haybale_standing_damage",	"48.0",
											"Damage of hittable haybales to non-incapped survivors.",
											FCVAR_PLUGIN, true, 0.0, true, 100.0 );
	hBaggageStandingDamage	= CreateConVar( "hc_baggage_standing_damage",	"48.0",
											"Damage of hittable baggage carts to non-incapped survivors.",
											FCVAR_PLUGIN, true, 0.0, true, 100.0 );
	hStandardIncapDamage	= CreateConVar( "hc_incap_standard_damage",		"100.0",
											"Damage of all hittables to incapped players.",
											FCVAR_PLUGIN, true, 0.0, true, 300.0 );
	hTankSelfDamage			= CreateConVar( "hc_disable_self_damage",		"0",
											"If set, tank will not damage itself with hittables.",
											FCVAR_PLUGIN, true, 0.0, true, 1.0 );	
}

public OnMapStart()
{
	decl String:buffer[64];
	GetCurrentMap(buffer, sizeof(buffer));
	if (StrContains(buffer, "c5m5") != -1)
	{
		bIsBridge = true;
	}
	else
	{
		bIsBridge = false;	//in case of map changes or something
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage( victim, &attacker, &inflictor, &Float:damage, &damageType, &weapon, Float:damageForce[3], Float:damagePosition[3] )
{
	if (!IsValidEdict(attacker) || !IsValidEdict(victim) || !IsValidEdict(inflictor))	{ return Plugin_Continue; }
	
	decl String:sClass[64];
	GetEdictClassname(inflictor, sClass, sizeof(sClass));
	
	if (StrEqual(sClass,"prop_physics"))
	{
		if (bIgnoreOverkill[victim]) { return Plugin_Handled; }
				
		if (victim == attacker && GetConVarBool(hTankSelfDamage))	{ return Plugin_Handled; }
		if (GetClientTeam(victim) != 2)	{ return Plugin_Continue; }	
		
		decl String:sModelName[128];
		GetEntPropString(inflictor, Prop_Data, "m_ModelName", sModelName, 128);
		
		if (bIsBridge)
		{
			damage = 4.0*GetConVarFloat(hBridgeCarDamage);
			inflictor = 0;	//because valve is silly and damage on incapped players would be ignored otherwise
		}
		else
		{
			if (GetEntProp(victim, Prop_Send, "m_isIncapacitated"))
			{			
				damage = GetConVarFloat(hStandardIncapDamage);	//overriden if it's the bridge finale
			}
			else
			{	//elses for optimisation actually worth it? hmm..
				if (StrEqual(sModelName, "models/props_vehicles/airport_baggage_cart2.mdl"))
				{
					damage = GetConVarFloat(hBaggageStandingDamage);
				}
				else
				{
					if (StrEqual(sModelName, "models/props_unique/haybails_single.mdl"))
					{
						damage = GetConVarFloat(hHaybaleStandingDamage);
					}
					else
					{
						if (StrEqual(sModelName, "models/props_foliage/Swamp_FallenTree01_bare.mdl"))
						{
							damage = GetConVarFloat(hLogStandingDamage);
						}
					}
				}
			}
		}			
		
		bIgnoreOverkill[victim] = true;
		CreateTimer(1.2, Timed_ClearInvulnerability, victim);
				
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action:Timed_ClearInvulnerability(Handle:thisTimer, any:victim)
{
	bIgnoreOverkill[victim] = false;
}


