/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <sourcemod>
#include <sdktools>
#include <l4d2lib>

const AI_THROW_RANGE=17001;

new Float:fDefaultThrowRange;
new Handle:hTankGodTime;
new Handle:tank_throw_allow_range;

public OnPluginStart()
{
	hTankGodTime = CreateConVar("l4d_tank_god_time", "3.0", "Time that a tank will have god mode and fire immunity after the first player tanks control");
	tank_throw_allow_range = FindConVar("tank_throw_allow_range");
	fDefaultThrowRange = GetConVarFloat(tank_throw_allow_range);
}

public L4D2_OnTankFirstSpawn(tankClient)
{
	if (IsFakeClient(tankClient))
	{
		FreezeTank(tankClient);
		CreateTimer(GetConVarFloat(FindConVar("director_tank_lottery_selection_time")) + GetConVarFloat(hTankGodTime), UnlockAI_Timer, GetClientUserId(tankClient));
	}
	else
	{
		GodTank(tankClient);
		CreateTimer(GetConVarFloat(hTankGodTime), MortalTank_Timer, tankClient);
	}
}

public L4D2_OnTankPassControl(oldTank, newTank, passCount)
{
	if (IsFakeClient(oldTank))
	{
		ThawTank(newTank);
		GodTank(newTank);
		CreateTimer(GetConVarFloat(hTankGodTime), MortalTank_Timer, newTank);
	}
}

stock FreezeTank(tank)
{
	SetConVarInt(tank_throw_allow_range, AI_THROW_RANGE);
	if (IsValidEntity(tank))
	{
		SetEntityMoveType(tank, MOVETYPE_NONE);
		SetEntProp(tank, Prop_Send, "m_isGhost", 1, 1);
	}
}

stock ThawTank(tank)
{
	SetConVarFloat(tank_throw_allow_range, fDefaultThrowRange);
	if (IsValidEntity(tank))
	{
		SetEntityMoveType(tank, MOVETYPE_CUSTOM);
		SetEntProp(tank, Prop_Send, "m_isGhost", 0, 1);
	}
}

public Action:UnlockAI_Timer(Handle:timer, any:tank)
{
	new client = GetClientOfUserId(tank);
	if (client > 0 && IsClientConnected(client) && IsPlayerAlive(client) && IsFakeClient(client))
	{
		ThawTank(client);
	}
	//TODO: make sure this works (should probably add a zombo class check
}

public Action:MortalTank_Timer(Handle:timer, any:tank)
{
	ExtinguishEntity(tank);
	MortalTank(tank);
}

stock GodTank(tank)
{
	SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);
}

stock MortalTank(tank)
{
	SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
}
