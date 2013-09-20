#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <weapons>

#define TEAM_SURVIVOR 2
#define MAX_DIST_SQUARED 48400 /* Normal pill pass range is ~220 units */
#define TRACE_TOLERANCE 30.0

public Plugin:myinfo =
{
	name = "Easier Pill Passer",
	author = "CanadaRox",
	description = "Lets players pass pills and adrenaline with +reload when they are holding one of those items",
	version = "3",
	url = "http://github.com/CanadaRox/sourcemod-plugins/"
};

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (buttons & IN_RELOAD && !(buttons & IN_USE) && !IsFakeClient(client))
	{
		decl String:weapon_name[64];
		GetClientWeapon(client, weapon_name, sizeof(weapon_name));
		/* L4D2 specific stuff here */
		new WeaponId:wep = WeaponNameToId(weapon_name);
		if (wep == WEPID_PAIN_PILLS || wep == WEPID_ADRENALINE)
		{
			/* end of L4D2 specific stuff */
			new target = GetClientAimTarget(client);
			if (target != -1 && GetClientTeam(target) == TEAM_SURVIVOR && GetPlayerWeaponSlot(target, 4) == -1 && !IsPlayerIncap(target))
			{
				decl Float:clientOrigin[3], Float:targetOrigin[3];
				GetClientAbsOrigin(client, clientOrigin);
				GetClientAbsOrigin(target, targetOrigin);
				if (GetVectorDistance(clientOrigin, targetOrigin, true) < MAX_DIST_SQUARED)
				{
					if (IsVisibleTo(client, target) || IsVisibleTo(client, target, true))
					{
						AcceptEntityInput(GetPlayerWeaponSlot(client, 4), "Kill");
						new ent = CreateEntityByName(WeaponNames[wep]);
						DispatchSpawn(ent);
						EquipPlayerWeapon(target, ent);

						new Handle:hFakeEvent = CreateEvent("weapon_given");
						SetEventInt(hFakeEvent, "userid", GetClientUserId(target));
						SetEventInt(hFakeEvent, "giver", GetClientUserId(client));
						SetEventInt(hFakeEvent, "weapon", _:wep);
						SetEventInt(hFakeEvent, "weaponentid", ent);
						FireEvent(hFakeEvent);
					}
				}
			}
		}
	}
}

stock bool:IsPlayerIncap(client) return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated");

stock bool:IsVisibleTo(client, client2, bool:ghetto_lagcomp = false) // check an entity for being visible to a client
{
	decl Float:vAngles[3], Float:vOrigin[3], Float:vEnt[3], Float:vLookAt[3];
	decl Float:vClientVelocity[3], Float:vClient2Velocity[3];

	GetClientEyePosition(client, vOrigin); // get both player and zombie position
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vClientVelocity);

	GetClientAbsOrigin(client2, vEnt);
	GetEntPropVector(client2, Prop_Data, "m_vecAbsVelocity", vClient2Velocity);

	new Float:ping = GetClientAvgLatency(client, NetFlow_Outgoing);
	new Float:lerp = GetEntPropFloat(client, Prop_Data, "m_fLerpTime");
	lerp *= 4;
	/* This number is pretty much pulled out of my ass with a little bit of testing on a local server with NF */
	/* If you have a problem with this number, blame NF!!! */

	if (ghetto_lagcomp)
	{
		vOrigin[0] += vClientVelocity[0] * (ping + lerp) * -1;
		vOrigin[1] += vClientVelocity[1] * (ping + lerp) * -1;
		vOrigin[2] += vClientVelocity[2] * (ping + lerp) * -1;

		vEnt[0] += vClient2Velocity[0] * (ping) * -1;
		vEnt[1] += vClient2Velocity[1] * (ping) * -1;
		vEnt[2] += vClient2Velocity[2] * (ping) * -1;
	}

	MakeVectorFromPoints(vOrigin, vEnt, vLookAt); // compute vector from player to zombie

	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace

	// execute Trace
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_OPAQUE_AND_NPCS, RayType_Infinite, TraceFilter);

	new bool:isVisible = false;
	if (TR_DidHit(trace))
	{
		decl Float:vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint

		if ((GetVectorDistance(vOrigin, vStart, false) + TRACE_TOLERANCE) >= GetVectorDistance(vOrigin, vEnt))
		{
			isVisible = true;
		}
	}
	else
	{
		isVisible = true;
	}
	CloseHandle(trace);
	return isVisible;
}

public bool:TraceFilter(entity, contentsMask)
{
	if (entity <= MaxClients)
		return false;
	return true;
}
