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
#pragma semicolon 1

#include <sourcemod>
//#include <left4downtown.inc>

new Handle: hCommonLimit = INVALID_HANDLE;
new iCommonLimit;                                               // stored for efficiency


/*
    -----------------------------------------------------------------------------------------------------------------------------------------------------

    Changelog
    ---------


    -----------------------------------------------------------------------------------------------------------------------------------------------------
 */

public Plugin:myinfo = 
{
    name = "Director-scripted common limit blocker",
    author = "Tabun",
    description = "Prevents director scripted overrides of z_common_limit. Only affects scripted common limits higher than the cvar.",
    version = "0.1a",
    url = "nope"
}

/* -------------------------------
 *      Init
 * ------------------------------- */

public OnPluginStart()
{
    // cvars
    hCommonLimit = FindConVar("z_common_limit");
    iCommonLimit = GetConVarInt(hCommonLimit);
    HookConVarChange(hCommonLimit, Cvar_CommonLimitChange);
}


public Cvar_CommonLimitChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) { iCommonLimit = StringToInt(newValue); }
    

/* -------------------------------
 *      General hooks / events
 * ------------------------------- */

public OnMapStart()
{
    // do something?
}

public Action:L4D_OnGetScriptValueInt(const String:key[], &retVal)
{
    if (StrEqual(key,"CommonLimit"))
    {
        if (retVal > iCommonLimit)
        {
            retVal = iCommonLimit;
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}
