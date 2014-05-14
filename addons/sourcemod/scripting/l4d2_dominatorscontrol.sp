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

#define DEBUG		0
#define NUM_SI_CLASSES	6
#define DOMINATORS_DEFAULT 53

static g_iDominators = DOMINATORS_DEFAULT;
static Address:g_pDominatorsAddress =  Address_Null;
static Handle:g_hCvarDominators = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "Dominators Control",
	author = "vintik",
	description = "Changes bIsDominator flag for infected classes. Allows to have native-order quad-caps.",
	version = "1.1",
	url = "https://bitbucket.org/vintik/various-plugins"
}

public OnPluginStart()
{
	decl String:sGame[256];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "left4dead2", false))
	{
		SetFailState("Plugin 'Dominators Control' supports Left 4 Dead 2 only!");
	}
	new Handle:hGConf = LoadGameConfigFile("l4d2_dominators");
	if ((hGConf == INVALID_HANDLE)
		|| (g_pDominatorsAddress = GameConfGetAddress(hGConf, "bIsDominator")) == Address_Null)
	{
		SetFailState("Can't find 'bIsDominator' signature!");
	}
	#if DEBUG
	PrintToServer("[DEBUG] bIsDominator's signature is found. Address: %08x", g_pDominatorsAddress);
	#endif
	
	g_hCvarDominators = CreateConVar("l4d2_dominators", "53",
	"Which infected class is considered as dominator (bitmask: 1 - smoker, 2 - boomer, 4 - hunter, 8 - spitter, 16 - jockey, 32 - charger)",
	FCVAR_PLUGIN | FCVAR_SPONLY);
	
	new iCvarValue = GetConVarInt(g_hCvarDominators);
	if (!IsValidCvarValue(iCvarValue))
	{
		SetConVarInt(g_hCvarDominators, DOMINATORS_DEFAULT);
		iCvarValue = DOMINATORS_DEFAULT;
	}
	if (g_iDominators != iCvarValue)
	{
		g_iDominators = iCvarValue;
		SetDominators();
	}
	HookConVarChange(g_hCvarDominators, OnCvarDominatorsChange);
}

public OnPluginEnd()
{
	g_iDominators = DOMINATORS_DEFAULT;
	SetDominators();
}

public OnCvarDominatorsChange(Handle:hCvar, const String:sOldVal[], const String:sNewVal[])
{
	new iNewVal = StringToInt(sNewVal);
	if (iNewVal == g_iDominators) return;
	if (IsValidCvarValue(iNewVal))
	{
		g_iDominators = iNewVal;
		#if DEBUG
		PrintToServer("[DEBUG] sm_dominators changed to %d", g_iDominators);
		#endif
		SetDominators();
	}
	else
	{
		PrintToChatAll("[SM] Incorrect value of 'sm_dominators'! min: 0, max: %d", (1 << NUM_SI_CLASSES) - 1);
		SetConVarString(hCvar, sOldVal);
	}
}

stock bool:IsValidCvarValue(iValue)
{
	return ((iValue >= 0) && (iValue < (1 << NUM_SI_CLASSES)));
}

stock SetDominators()
{
	new bool:bIsDominator;
	for (new i = 0; i < NUM_SI_CLASSES; i++)
	{
		bIsDominator = (((1 << i) & g_iDominators) != 0);
		#if DEBUG
		PrintToServer("[DEBUG] Class %d is %sdominator now", i, bIsDominator ? "" : "NOT ");
		#endif
		StoreToAddress(g_pDominatorsAddress + Address:i, _:bIsDominator, NumberType_Int8);
	}
}
