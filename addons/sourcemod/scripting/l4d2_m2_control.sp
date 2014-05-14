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

#define L4D2UTIL_STOCKS_ONLY

#include <sourcemod>
#include <l4d2util>
#include <l4d2_direct>

// The z_gun_swing_vs_amt_penalty cvar is the amount of cooldown time you get
// when you are on your maximum m2 penalty. However, whilst testing I found that
// a magic number of ~0.7s was always added to this.
#define COOLDOWN_EXTRA_TIME 0.7

// Sometimes the ability timer doesn't get reset if the timer interval is the
// stagger time. Use an epsilon to set it slightly before the stagger is over.
#define STAGGER_TIME_EPS 0.1

new Handle:hMaxShovePenaltyCvar;
new Handle:hShovePenaltyAmtCvar;
new Handle:hPounceCrouchDelayCvar;
new Handle:hMaxStaggerDurationCvar;
new Handle:hLeapIntervalCvar;
new Handle:hPenaltyIncreaseCvar;

new g_iPenaltyIncrease;

public Plugin:myinfo =
{
    name        = "L4D2 M2 Control",
    author      = "Jahze",
    version     = "1.1",
    description = "Blocks instant repounces and gives maximum m2 penalty after a deadstop"
}

public OnPluginStart() {
    HookEvent("player_shoved", OutSkilled);
    hMaxShovePenaltyCvar = FindConVar("z_gun_swing_vs_max_penalty");
    hShovePenaltyAmtCvar = FindConVar("z_gun_swing_vs_amt_penalty");
    hPounceCrouchDelayCvar = FindConVar("z_pounce_crouch_delay");
    hMaxStaggerDurationCvar = FindConVar("z_max_stagger_duration");
    hLeapIntervalCvar = FindConVar("z_leap_interval");

    hPenaltyIncreaseCvar = CreateConVar("l4d2_deadstop_penalty", "0", "How much penalty gets added when you deadstop a hunter or jockey");
    HookConVarChange(hPenaltyIncreaseCvar, PenaltyIncreaseChange);
    g_iPenaltyIncrease = GetConVarInt(hPenaltyIncreaseCvar);
}

public PenaltyIncreaseChange(Handle:hCvar, const String:oldVal[], const String:newVal[]) {
    g_iPenaltyIncrease = StringToInt(newVal);
}

public Action:OutSkilled(Handle:event, const String:name[], bool:dontBroadcast) {
    new shovee = GetClientOfUserId(GetEventInt(event, "userid"));
    new shover = GetClientOfUserId(GetEventInt(event, "attacker"));

    if (!IsSurvivor(shover) || !IsInfected(shovee))
        return;

    new L4D2_Infected:zClass = GetInfectedClass(shovee);

    if (zClass == L4D2Infected_Hunter || zClass == L4D2Infected_Jockey) {
        new maxPenalty = GetConVarInt(hMaxShovePenaltyCvar);
        new penalty = L4D2Direct_GetShovePenalty(shover);

        penalty += g_iPenaltyIncrease;
        if (penalty > maxPenalty) {
            penalty = maxPenalty;
        }

        L4D2Direct_SetShovePenalty(shover, penalty);
        L4D2Direct_SetNextShoveTime(shover, CalcNextShoveTime(penalty, maxPenalty));

        new Float:staggerTime = GetConVarFloat(hMaxStaggerDurationCvar);
        CreateTimer(staggerTime - STAGGER_TIME_EPS, ResetAbilityTimer, shovee);
    }
}

public Action:ResetAbilityTimer(Handle:event, any:shovee) {
    new Float:time = GetGameTime();
    new L4D2_Infected:zClass = GetInfectedClass(shovee);
    new Float:recharge;

    if (zClass == L4D2Infected_Hunter)
        recharge = GetConVarFloat(hPounceCrouchDelayCvar);
    else
        recharge = GetConVarFloat(hLeapIntervalCvar);

    new Float:timestamp;
    new Float:duration;
    if (! GetInfectedAbilityTimer(shovee, timestamp, duration))
        return;

    duration = time + recharge + STAGGER_TIME_EPS;
    if (duration > timestamp)
        SetInfectedAbilityTimer(shovee, duration, recharge);
}

static Float:CalcNextShoveTime(penalty, max) {
    new Float:time = GetGameTime();
    new Float:maxPenalty = float(max);
    new Float:currentPenalty = float(penalty);
    new Float:ratio = currentPenalty/maxPenalty;
    new Float:maxTime = GetConVarFloat(hShovePenaltyAmtCvar);

    return time + ratio*maxTime + COOLDOWN_EXTRA_TIME;
}
