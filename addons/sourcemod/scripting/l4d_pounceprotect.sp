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
#include <dhooks>

public Plugin:myinfo =
{
	name        = "L4D2 Pounce Protect",
	author      = "ProdigySim",
	description = "Prevent damage from blocking a hunter's ability to pounce",
	version     = "1.0",
	url         = "http://www.l4dnation.com/"
}

new Handle:hCBaseAbility_OnOwnerTakeDamage;
public OnPluginStart()
{
	new Handle:gameConf = LoadGameConfigFile("l4d_pounceprotect"); 
	new OnOwnerTakeDamageOffset = GameConfGetOffset(gameConf, "CBaseAbility_OnOwnerTakeDamage");
	
	hCBaseAbility_OnOwnerTakeDamage = DHookCreate(
		OnOwnerTakeDamageOffset, 
		HookType_Entity, 
		ReturnType_Void, 
		ThisPointer_Ignore, 
		CBaseAbility_OnOwnerTakeDamage);
	DHookAddParam(hCBaseAbility_OnOwnerTakeDamage, HookParamType_ObjectPtr);
	
	DHookAddEntityListener(ListenType_Created, OnEntityCreated);
}

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "ability_lunge"))
	{
		DHookEntity(hCBaseAbility_OnOwnerTakeDamage, false, entity); 
	}
}

// During this function call the game simply validates the owner entity 
// and then sets a bool saying you can't pounce again if you're already mid-pounce.
// afaik
public MRESReturn:CBaseAbility_OnOwnerTakeDamage(Handle:hParams)
{
	// Skip the whole function plox
	return MRES_Supercede;
}
