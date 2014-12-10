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
#include <sdktools>
#include <sdkhooks>

// Plugin fields used in multiple places
#define PLUGIN_VERSION "1.3"
#define PLUGIN_AUTHOR "dcx2"
#define PLUGIN_NAME "L4D2 Undo Friendly Fire"
#define CVAR_FLAGS FCVAR_PLUGIN|FCVAR_NOTIFY

// Debug flags to minimize chatter
#define DEBUG_FLAG_OTD 0x01
#define DEBUG_FLAG_HURT 0x02
#define DEBUG_FLAG_INCAP 0x04
#define DEBUG_FLAG_FF 0x08
#define DEBUG_FLAG_CHARGER 0x10
#define DEBUG_FLAG_UNDO 0x20
#define DEBUG_FLAG_DIST 0x40
#define DEBUG_FLAG_BOTFF 0x80
#define DEBUG_FLAG_TA 0x100
#define DEBUG_FLAG_HEAL 0x200

// Macros for easily referencing the Undo Damage array
#define UNDO_PERM 0
#define UNDO_TEMP 1
#define UNDO_SIZE 16

// Macros for stack argument array
#define STACK_VICTIM 0
#define STACK_DAMAGE 1
#define STACK_DISTANCE 2
#define STACK_TYPE 3
#define STACK_SIZE 4

// Announcement flags
#define ANNOUNCE_NONE 0
#define ANNOUNCE_CONSOLE 1
#define ANNOUNCE_CHAT 2

// Flags for different types of Friendly Fire
#define FFTYPE_NOTUNDONE 0
#define FFTYPE_TOOCLOSE 1
#define FFTYPE_CHARGERCARRY 2
#define FFTYPE_STUPIDBOTS 4
#define FFTYPE_MELEEFLAG 0x8000

// Macros for referencing difficulties
#define EASY 0
#define NORMAL 1
#define ADVANCED 2
#define EXPERT 3

// Macros for determining client validity
#define IS_VALID_CLIENT(%1) (%1 > 0 && %1 <= MaxClients)
#define IS_CONNECTED_INGAME(%1) (IsClientConnected(%1) && IsClientInGame(%1))
#define IS_SURVIVOR(%1) (GetClientTeam(%1) == 2)
#define IS_INFECTED(%1) (GetClientTeam(%1) == 3)

#define IS_VALID_INGAME(%1) (IS_VALID_CLIENT(%1) && IS_CONNECTED_INGAME(%1))

#define IS_VALID_SURVIVOR(%1) (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_VALID_INFECTED(%1) (IS_VALID_INGAME(%1) && IS_INFECTED(%1))

#define IS_SURVIVOR_ALIVE(%1) (IS_VALID_SURVIVOR(%1) && IsPlayerAlive(%1))
#define IS_INFECTED_ALIVE(%1) (IS_VALID_INFECTED(%1) && IsPlayerAlive(%1))


// cvars and their cached variables
new Handle:g_cvarEnable = INVALID_HANDLE;
new g_EnabledFlags;
new Handle:g_cvarAnnounce = INVALID_HANDLE;
new g_AnnounceFlags;
new Handle:g_cvarBlockZeroDmg = INVALID_HANDLE;
new g_BlockZeroDmg;
new Handle:g_cvarDebug = INVALID_HANDLE;
new g_DebugFlags;
new Handle:g_cvarPermDamageFraction = INVALID_HANDLE;
new Float:g_flPermFrac;
new g_difficulty = NORMAL;

// Flags for knowing when to undo friendly fire
new bool:g_chargerCarryNoFF[MAXPLAYERS+1] = { false, ... };
new bool:g_stupidGuiltyBots[MAXPLAYERS+1] = { false, ... };

// The Undo Damage array, with correlated arrays for holding the last revive count and current undo index
new g_lastHealth[MAXPLAYERS+1][UNDO_SIZE][2];
new g_lastReviveCount[MAXPLAYERS+1] = { 0, ... };
new g_currentUndo[MAXPLAYERS+1] = { 0, ... };

// Healing is weird, so this keeps track of our target OR the target's temp health
new g_targetTempHealth[MAXPLAYERS+1] = { 0, ... };

// The permanent damage fraction requires some coordination between OnTakeDamage and player_hurt
new g_lastPerm[MAXPLAYERS+1] = { 100, ... };
new g_lastTemp[MAXPLAYERS+1] = { 0, ... };

// Stacks are used to condense the damage announcement for attacks that happen multiple times in one frame (e.g. shotgun, melee)
new Handle:g_iAnnounceStacks[MAXPLAYERS+1] = INVALID_HANDLE;


public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Prevents friendly fire under certain circumstances",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1745732#post1745732"
};

public OnPluginStart()
{
	// Desired order
	// 1) Create cvars
	// 2) Hook cvar changes
	// 3) AutoExec loads user's specific defaults
	// 4) Cache the newly loaded cvars
	// 5) Initialize globals
	// 6) Register commands
	// 7) Hook events
	
	g_cvarEnable = 				CreateConVar("l4d2_undoff_enable", 		"2", 	"Bit flag: Enables plugin features (add together): 1=too close, 2=Charger carry, 4=guilty bots, 7=all, 0=off", CVAR_FLAGS);
	g_cvarAnnounce = 			CreateConVar("l4d2_undoff_announce", 	"0", 	"Bit flag: Enable damage announcements: 2=chat, 1=console, 0=off", CVAR_FLAGS);
	g_cvarBlockZeroDmg =		CreateConVar("l4d2_undoff_blockzerodmg","0", 	"Bit flag: Block 0 damage friendly fire effects like recoil and vocalizations/stats (add together): 4=bot hits human block recoil, 2=block vocals/stats on ALL difficulties, 1=block vocals/stats on everything EXCEPT Easy (flag 2 has precedence), 0=off", CVAR_FLAGS);
	g_cvarDebug = 				CreateConVar("l4d2_undoff_debug", 		"0", 	"Print debug output (1023=all)", CVAR_FLAGS);
	g_cvarPermDamageFraction = 	CreateConVar("l4d2_undoff_permdmgfrac", "1.0", 	"Minimum fraction of damage applied to permanent health", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar							("l4d2_undoff_version", 	PLUGIN_VERSION, PLUGIN_NAME, CVAR_FLAGS|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	new Handle:difficulty = 	  FindConVar("z_difficulty");

	HookConVarChange(g_cvarEnable, 				OnUndoFFEnableChanged);
	HookConVarChange(g_cvarAnnounce, 			OnUndoFFAnnounceChanged);
	HookConVarChange(g_cvarBlockZeroDmg, 		OnUndoFFBlockZeroDmgChanged);
	HookConVarChange(g_cvarDebug,				OnUndoFFDebugChanged);
	HookConVarChange(g_cvarPermDamageFraction, 	OnPermFracChanged);
	HookConVarChange(difficulty, 				OnDifficultyChanged);
	
	AutoExecConfig(true, "L4D2UndoFF");
	
	g_EnabledFlags = GetConVarInt(g_cvarEnable);
	g_AnnounceFlags = GetConVarInt(g_cvarAnnounce);
	g_BlockZeroDmg = GetConVarInt(g_cvarBlockZeroDmg);
	g_DebugFlags = GetConVarInt(g_cvarDebug);
	g_flPermFrac = GetConVarFloat(g_cvarPermDamageFraction);
	
	decl String:difficultyString[32];
	GetConVarString(difficulty, difficultyString, sizeof(difficultyString));
	g_difficulty = GetDifficultyValue(difficultyString);

	// Initializers
	for (new i = 1; i <= MAXPLAYERS; i++)
	{
		for (new j=0; j<UNDO_SIZE; j++)
		{
			g_lastHealth[i][j][UNDO_PERM] = 0;
			g_lastHealth[i][j][UNDO_TEMP] = 0;
		}

		g_iAnnounceStacks[i] = CreateStack(STACK_SIZE);
	}

	LoadTranslations("common.phrases");	
	RegAdminCmd("sm_undodamage", Command_Undo, ADMFLAG_SLAY);

	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("friendly_fire", Event_FriendlyFire, EventHookMode_Pre);
	HookEvent("charger_carry_start", Event_ChargerCarryStart, EventHookMode_Post);
	HookEvent("charger_carry_end", Event_ChargerCarryEnd, EventHookMode_Post);
	HookEvent("heal_begin", Event_HealBegin, EventHookMode_Pre);
	HookEvent("heal_end", Event_HealEnd, EventHookMode_Pre);
	HookEvent("heal_success", Event_HealSuccess, EventHookMode_Pre);
	HookEvent("player_incapacitated_start", Event_PlayerIncapStart, EventHookMode_Pre);
}

// TODO: can we announce to console with colors?
// TODO: per-player announce settings that can be controlled via chat (e.g. !undoff off|console|chat)
// TODO: SQL store player preference for announcements?

// TODO: SI friendly fire?  1 to disable instant-kills, 2 to disable all SI FF?
// TODO: also disable world damage while in ghost mode?

public OnUndoFFEnableChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_EnabledFlags = StringToInt(newVal);
}

public OnUndoFFAnnounceChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_AnnounceFlags = StringToInt(newVal);
}

public OnUndoFFBlockZeroDmgChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_BlockZeroDmg = StringToInt(newVal);
}

// Track difficulty so that we can allow 0-damage friendly fire on Easy
// so that you know how bad you really are, otherwise this would guarantee 0 FF on easy
public OnDifficultyChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_difficulty = GetDifficultyValue(newValue);
}

public GetDifficultyValue(const String:Difficulty[])
{
	// assume normal by default
	new ret = NORMAL;
	if (StrEqual(Difficulty, "impossible", false)) ret = EXPERT;
	else if (StrEqual(Difficulty, "hard", false)) ret = ADVANCED;
	else if (StrEqual(Difficulty, "easy", false)) ret = EASY;
	return ret;
}

public OnUndoFFDebugChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_DebugFlags = StringToInt(newVal);
}

public OnPermFracChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_flPermFrac = StringToFloat(newVal);
}

// TODO: When the plugin is reloaded, existing clients' hooks are lost
// 		 How can I fix this?
public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageUndoFF);
    SDKHook(client, SDKHook_TraceAttack, TraceAttackUndoFF);
}

// The sole purpose of this hook is to prevent survivor bots from causing the vision of human survivors to recoil
public Action:TraceAttackUndoFF(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	decl String:victimName[MAX_TARGET_LENGTH];
	decl String:attackerName[MAX_TARGET_LENGTH];
	decl String:inflictorName[32];

	// If none of the flags are enabled, don't do anything
	if (!g_EnabledFlags) return Plugin_Continue;
	
	// Only interested in Survivor victims
	if (!IS_VALID_SURVIVOR(victim)) return Plugin_Continue;
	
	// Can't use %N because e.g. attacker could be world
	// TODO: use %N for victim since we know it will be Survivor..?
	GetClientOrEntityName(victim, victimName, sizeof(victimName));
	GetClientOrEntityName(attacker, attackerName, sizeof(attackerName));
	GetSafeEntityName(inflictor, inflictorName, sizeof(inflictorName));
	
	if (g_DebugFlags & DEBUG_FLAG_TA)	Announce("TAFF: %s hit %s (%d, %d) with %s (%x, %x) in %d for %f", attackerName, victimName, GetClientHealth(victim), L4D_GetPlayerTempHealth(victim), inflictorName, damagetype, ammotype, hitgroup, damage);
	
	// If a valid survivor bot shoots a valid survivor human, block it to prevent survivor vision from getting experiencing recoil (it would have done 0 damage anyway)
	// TODO: isn't there a cvar that lets bots do actual FF...?
	if ((g_BlockZeroDmg & 0x04) && IS_VALID_SURVIVOR(attacker) && IsFakeClient(attacker) && IS_VALID_SURVIVOR(victim) && !IsFakeClient(victim))
	{
		if (g_DebugFlags & DEBUG_FLAG_BOTFF)	Announce("\x01Blocked bot \x04%N\x01 from hitting human \x03%N\x01", attacker, victim);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

// We must use OnTakeDamage in order to block Friendly Fire before it happens
public Action:OnTakeDamageUndoFF(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	decl String:victimName[MAX_TARGET_LENGTH];
	decl String:attackerName[MAX_TARGET_LENGTH];
	decl String:weaponName[32];
	decl String:inflictorName[32];
	new bool:undone = false;

	// If none of the flags are enabled, don't do anything
	if (!g_EnabledFlags) return Plugin_Continue;
	
	// Only interested in Survivor victims
	if (!IS_VALID_SURVIVOR(victim)) return Plugin_Continue;
	
	// Can't use %N because e.g. attacker could be world
	// TODO: use %N for victim since we know it will be Survivor..?
	GetClientOrEntityName(victim, victimName, sizeof(victimName));
	GetClientOrEntityName(attacker, attackerName, sizeof(attackerName));
	GetSafeEntityName(weapon, weaponName, sizeof(weaponName));
	GetSafeEntityName(inflictor, inflictorName, sizeof(inflictorName));
	
	if (g_DebugFlags & DEBUG_FLAG_OTD)	Announce("OTDFF: %s hit %s (%d, %d) with %s / %s for %f", attackerName, victimName, GetClientHealth(victim), L4D_GetPlayerTempHealth(victim), weaponName, inflictorName, damage);
	
	new dmg = RoundToFloor(damage);	// Damage to survivors is rounded down
	
	// Only check damage to survivors
	// - if it is greater than 0, OR
	// - if a human survivor did 0 damage (so we know when the engine forgives our friendly fire for us)
	if (IS_VALID_SURVIVOR(victim) && (dmg > 0 || (IS_VALID_SURVIVOR(attacker) && !IsFakeClient(attacker))))
	{
		// Remember health for undo
		new victimPerm = GetClientHealth(victim);
		new victimTemp = L4D_GetPlayerTempHealth(victim);

		// if attacker is also a valid survivor and not ourself, check for undo damage
		if (IS_VALID_SURVIVOR(attacker) && attacker != victim)
		{
			new Float:Distance = GetClientsDistance(victim, attacker);
			new Float:FFDist = GetWeaponFFDist(weaponName);
			new type;
			

			if ((g_EnabledFlags & FFTYPE_TOOCLOSE) && (Distance < FFDist))
			{
				undone = true;
				type = FFTYPE_TOOCLOSE;
			}
			else if ((g_EnabledFlags & FFTYPE_CHARGERCARRY) && (g_chargerCarryNoFF[victim]))
			{
				undone = true;
				type = FFTYPE_CHARGERCARRY;
			}
			else if ((g_EnabledFlags & FFTYPE_STUPIDBOTS) && (g_stupidGuiltyBots[victim]))
			{
				undone = true;
				type = FFTYPE_STUPIDBOTS;
			}
			else if (dmg == 0)
			{
				// In order to get here, you must be a human Survivor doing 0 damage to another Survivor
				// We will undo these based on cvar, since this means easy difficulty is guaranteed 0 friendly fires, so we won't know how bad we really are
				// We want to announce these as "Did 0" instead of "Undid 0", so that we know it was the game, and not this plugin, that forgave the friendly fire
				undone = (g_BlockZeroDmg & 0x02) || ((g_BlockZeroDmg & 0x01) && g_difficulty != EASY);
				type = FFTYPE_NOTUNDONE;	// We say this is not undone, even though it was, so that it announces "Did 0"
			}
			
			// If it is blocked in this call, player_hurt won't be able to announce it
			if (undone) PrepareAnnounce(weaponName, victim, attacker, dmg, type, Distance);
		}
		
		// TODO: move to player_hurt?  and check to make sure damage was consistent between the two?
		// We prefer to do this here so we know what the player's state looked like pre-damage
		// Specifically, what portion of the damage was applied to perm and temp health,
		// since we can't tell after-the-fact what the damage was applied to
		// Unfortunately, not all calls to OnTakeDamage result in the player being hurt (e.g. damage during god frames)
		// So we use player_hurt to know when OTD actually happened
		if (!undone && dmg > 0)
		{			
			new PermDmg = RoundToCeil(g_flPermFrac * dmg);
			if (PermDmg >= victimPerm)
			{
				// Perm damage won't reduce permanent health below 1 if there is sufficient temp health
				PermDmg = victimPerm - 1;
			}
			new TempDmg = dmg - PermDmg;
			if (TempDmg > victimTemp)
			{
				// If TempDmg exceeds current temp health, transfer the difference to perm damage
				PermDmg += (TempDmg - victimTemp);
				TempDmg = victimTemp;
			}
		
			// Don't add to undo list if player is incapped
			if (!L4D_IsPlayerIncapacitated(victim))
			{
				// point at next undo cell
				new nextUndo = (g_currentUndo[victim] + 1) % UNDO_SIZE;
					
				if (PermDmg < victimPerm)
				{
					// This will call player_hurt, so we should store the damage done so that it can be added back if it is undone
					g_lastHealth[victim][nextUndo][UNDO_PERM] = PermDmg;
					g_lastHealth[victim][nextUndo][UNDO_TEMP] = TempDmg;
					
					// We need some way to tell player_hurt how much perm/temp health we expected the player to have after this attack
					// This is used to implement the fractional damage to perm health
					// We can't just set their health here because this attack might not actually do damage
					g_lastPerm[victim] = victimPerm - PermDmg;
					g_lastTemp[victim] = victimTemp - TempDmg;
				}
				else
				{
					// This will call player_incap_start, so we should store their exact health and incap count at the time of attack
					// If the incap is undone, we will restore these settings instead of adding them
					g_lastHealth[victim][nextUndo][UNDO_PERM] = victimPerm;
					g_lastHealth[victim][nextUndo][UNDO_TEMP] = victimTemp;
					
					// This is used to tell player_incap_start the exact amount of damage that was done by the attack
					g_lastPerm[victim] = PermDmg;
					g_lastTemp[victim] = TempDmg;
					
					// TODO: can we move to incapstart?
					g_lastReviveCount[victim] = L4D_GetPlayerReviveCount(victim);
				}
			}
		}
	}
	
	if (undone) return Plugin_Handled;
	return Plugin_Continue;
}

// Apply fractional permanent damage here
// Also announce damage, and undo guilty bot damage
public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_EnabledFlags) return Plugin_Continue;

	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IS_VALID_SURVIVOR(victim)) return Plugin_Continue;
	
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new dmg = GetEventInt(event, "dmg_health");
	new currentPerm = GetEventInt(event, "health");
	
	decl String:weaponName[32];
	GetEventString(event, "weapon", weaponName, sizeof(weaponName));
		
	if (g_DebugFlags & DEBUG_FLAG_HURT) Announce("PH: vic %N, atk %N, atkent %d, hlth %d, wep %s, dmg %d, hit %d, type %X", victim, attacker, GetEventInt(event, "attackerentid"), currentPerm, weaponName, dmg, GetEventInt(event, "hitgroup"), GetEventInt(event, "type"));
	
	// When incapped you continuously get hurt by the world, so we just ignore incaps altogether
	if (dmg > 0 && !L4D_IsPlayerIncapacitated(victim))
	{
		// Cycle the undo pointer when we have confirmed that the damage was actually taken
		g_currentUndo[victim] = (g_currentUndo[victim] + 1) % UNDO_SIZE;
		
		// victim values are what OnTakeDamage expected us to have, current values are what the game gave us
		new victimPerm = g_lastPerm[victim];
		new victimTemp = g_lastTemp[victim];
		new currentTemp = L4D_GetPlayerTempHealth(victim);

		// If this feature is enabled, some portion of damage will be applied to the temp health
		if (g_flPermFrac < 1.0 && victimPerm != currentPerm)
		{
			if (g_DebugFlags & DEBUG_FLAG_HURT) Announce("FRAC: Before %d / %d, after %d %d, dmg %d", currentPerm, currentTemp, victimPerm, victimTemp, dmg);

			// make sure we don't give extra health
			new totalHealthOld = currentPerm + currentTemp, totalHealthNew = victimPerm + victimTemp;
			if (totalHealthOld == totalHealthNew)
			{
				SetEntityHealth(victim, victimPerm);
				L4D_SetPlayerTempHealth(victim, victimTemp);
			}
		}
	}
	
	// Announce damage, and check for guilty bots that slipped through OnTakeDamage
	if (IS_VALID_SURVIVOR(attacker))
	{
		new type;
		
		// Unfortunately, the friendly fire event only fires *after* OnTakeDamage has been called so it can't be blocked in time
		// So we must check here to see if the bots are guilty and undo the damage after-the-fact
		if ((g_EnabledFlags & FFTYPE_STUPIDBOTS) && (g_stupidGuiltyBots[victim]))
		{
			UndoDamage(victim);
			type = FFTYPE_STUPIDBOTS;
		}
		else
		{
			type = FFTYPE_NOTUNDONE;
		}
		
		PrepareAnnounce(weaponName, victim, attacker, dmg, type, GetClientsDistance(victim, attacker));
	}

	return Plugin_Continue;
}

// When a Survivor is incapped by damage, player_hurt will not fire
// So you may notice that the code here has some similarities to the code for player_hurt
public Action:Event_PlayerIncapStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Cycle the incap pointer, now that the damage has been confirmed
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// Cycle the undo pointer when we have confirmed that the damage was actually taken
	g_currentUndo[victim] = (g_currentUndo[victim] + 1) % UNDO_SIZE;
	
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
 
	// Announce damage, and check for guilty bots that slipped through OnTakeDamage
	if (IS_VALID_SURVIVOR(attacker))
	{
		new dmg = g_lastPerm[victim] + g_lastTemp[victim];
		new type;
		decl String:weaponName[32];
		GetEventString(event, "weapon", weaponName, sizeof(weaponName));
		
		// Unfortunately, the friendly fire event only fires *after* OnTakeDamage has been called so it can't be blocked in time
		// So we must check here to see if the bots are guilty and undo the damage after-the-fact
		if ((g_EnabledFlags & FFTYPE_STUPIDBOTS) && (g_stupidGuiltyBots[victim]))
		{
			UndoDamage(victim);
			type = FFTYPE_STUPIDBOTS;
		}
		else
		{
			type = FFTYPE_NOTUNDONE;
		}
		
		PrepareAnnounce(weaponName, victim, attacker, dmg, type, GetClientsDistance(victim, attacker));
	}
}

public PrepareAnnounce(String:weaponName[], victim, attacker, dmg, type, Float:dist)
{
	// Stack all attacks, single shots will be sorted out later
	new stackArg[STACK_SIZE];
	new bool:isStackable = false;
	if (StrContains(weaponName, "shotgun") >= 0)
	{
		isStackable = true;	
	}
	else if (StrContains(weaponName, "melee") >= 0)
	{
		// Melee attacks hit multiple times, but only one strike does damage
		// So we treat their multiplier differently
		type |= FFTYPE_MELEEFLAG;
		isStackable = true;
	}
	stackArg[STACK_VICTIM] = victim;
	stackArg[STACK_DAMAGE] = dmg;
	stackArg[STACK_DISTANCE] = _:dist;
	stackArg[STACK_TYPE] = type;
	
	// Stacks are stored per attacker, because one attacker can hit multiple targets in the same frame
	new bool:notYetStacked = false;
	if (IsStackEmpty(g_iAnnounceStacks[attacker]))
	{
		notYetStacked = true;
	}
	
	PushStackArray(g_iAnnounceStacks[attacker], stackArg);

	// if the stack was empty and now it's not, fire the condensed announce timer
	// this allows the announcement to happen after every bullet has hit the target
	if (notYetStacked && !IsStackEmpty(g_iAnnounceStacks[attacker]))
	{
		// Only stack shotgun/melee attacks, others get announced immediately
		if (isStackable) CreateTimer(0.1, AnnounceDelay, attacker);
		else AnnounceAttack(attacker);
	}
}

// Instead of seeing an announcement for each pellet from a shotgun
// the damage from all pellets is condensed into one message
// This also displays melee attacks
public Action:AnnounceDelay(Handle:timer, any:attacker)
{
	AnnounceAttack(attacker);
}

public AnnounceAttack(any:attacker)
{
	// A shotgun can hit multiple people so we need these arrays to keep track of each person's total
	new types[MAXPLAYERS+1];
	new multipliers[MAXPLAYERS+1] = { -1, ... };	// -1 = not hit
	new damages[MAXPLAYERS+1];
	new Float:distances[MAXPLAYERS+1];
	
	// Process all entries in this attacker's stack
	// Note that the attack can strike multiple victims
	while (!IsStackEmpty(g_iAnnounceStacks[attacker]))
	{
		decl stackArg[STACK_SIZE];
		PopStackArray(g_iAnnounceStacks[attacker], stackArg);
		
		new victim = stackArg[STACK_VICTIM];
		types[victim] = stackArg[STACK_TYPE];
		distances[victim] = Float:stackArg[STACK_DISTANCE];
		
		if (multipliers[victim] < 0) multipliers[victim] = 0;	// If this is the first hit, initialize victim multiplier to 0

		// Melee weapons have multiple strikes, but only one does damage, so don't count 0-damage attacks in their multiplier
		// However non-melee (i.e. shotgun) can do all 0-damage attacks and we want to know their multiplier
		if (stackArg[STACK_DAMAGE] > 0 || !(stackArg[STACK_TYPE] & FFTYPE_MELEEFLAG))
		{
			multipliers[victim]++;
			damages[victim] = stackArg[STACK_DAMAGE];
		}
	}
	
	for (new i=1; i<=MaxClients; i++)
	{
		if (multipliers[i] < 0) continue;

		decl String:multString[32] = "";	// by default, no multiplier
		decl String:damageString[64];

		types[i] &= FFTYPE_TOOCLOSE | FFTYPE_CHARGERCARRY | FFTYPE_STUPIDBOTS;
		
		new bool:unhurt = types[i] || damages[i]==0, bool:undone = types[i] != FFTYPE_NOTUNDONE;
		
		// If the multiplier is more than 1, fill in the multiplier string (so we know how many bullets hit)
		if (multipliers[i] > 1)
		{
		//											[# bullets]x[color][dmg/bullet]
			FormatEx(multString, sizeof(multString), " (%dx%s%d\x01)", multipliers[i], (unhurt ? "\x03" : "\x05"), damages[i]);
		}
		
		//									[color][did/undid] [damage][mult]
		FormatEx(damageString, sizeof(damageString), "%s%s %d\x01%s", 	(unhurt ? "\x03" : "\x05"), // unhurt gets pretty light blue, hurt gets ugly olive
																		(undone ? "Undid" : "Did"),
																		(multipliers[i] * damages[i]),
																		multString);				// will be empty string if no multiplier
		
		// re-use multString for the reason
		switch(types[i])
		{
			case FFTYPE_STUPIDBOTS:		strcopy(multString, sizeof(multString), "(stupid bot)");
			case FFTYPE_CHARGERCARRY:	strcopy(multString, sizeof(multString), "(Charger carry)");
			case FFTYPE_TOOCLOSE,
				 FFTYPE_NOTUNDONE:		FormatEx(multString, sizeof(multString), "(dist %f)", distances[i]);
			default:					FormatEx(multString, sizeof(multString), "(dist %f)", distances[i]);
		}
		
		//	[damage] to [victim] from [attacker] [reason]
		Announce("%s to \x04%N\x01 from \x04%N\x01 %s", damageString, i, attacker, multString);
	}
}

// Announce allows the text to be directed to either chat, or each player's console
public Announce(const String:format[], any:...)
{
	decl String:buffer[300];
	VFormat(buffer, sizeof(buffer), format, 2);

	if (g_AnnounceFlags & ANNOUNCE_CHAT)
	{
		PrintToChatAll(buffer);
	}
	else if (g_AnnounceFlags & ANNOUNCE_CONSOLE)
	{
		for (new i=1; i<=MaxClients; i++)
		{
			// all in-game humans, regardless of team
			if (IS_VALID_INGAME(i) && !IsFakeClient(i)) PrintToConsole(i, buffer);
		}
	}
}

// If a bot is guilty of creating a friendly fire event, undo it
// Also give the human some reaction time to realize the bot ran in front of them
public Action:Event_FriendlyFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!(g_EnabledFlags & FFTYPE_STUPIDBOTS)) return Plugin_Continue;

	if (g_DebugFlags & DEBUG_FLAG_FF)		Announce("FF: victim %d, guilty %d, type %x", GetEventInt(event, "victim"), GetEventInt(event, "guilty"), GetEventInt(event, "type"));
	new client = GetClientOfUserId(GetEventInt(event, "guilty"));
	if (IsFakeClient(client))
	{
		g_stupidGuiltyBots[client] = true;
		CreateTimer(0.4, StupidGuiltyBotDelay, client);
		Announce("Undid damage (stupid bot)");
	}
	return Plugin_Continue;
}

public Action:StupidGuiltyBotDelay(Handle:timer, any:client)
{
	g_stupidGuiltyBots[client] = false;
}

// While a Charger is carrying a Survivor, undo any friendly fire done to them
// since they are effectively pinned and pinned survivors are normally immune to FF
public Action:Event_ChargerCarryStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!(g_EnabledFlags & FFTYPE_CHARGERCARRY)) return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "victim"));

	if (g_DebugFlags & DEBUG_FLAG_CHARGER)		Announce("CCS: victim %N", client);
	g_chargerCarryNoFF[client] = true;
	return Plugin_Continue;
}

// End immunity about one second after the carry ends
// (there is some time between carryend and pummelbegin,
// but pummelbegin does not always get called if the charger died first, so it is unreliable
// and besides the survivor has natural FF immunity when pinned)
public Action:Event_ChargerCarryEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "victim"));
	if (g_DebugFlags & DEBUG_FLAG_CHARGER)		Announce("CCE: victim %N", client);
	CreateTimer(1.0, ChargerCarryFFDelay, client);	
	return Plugin_Continue;
}

public Action:ChargerCarryFFDelay(Handle:timer, any:client)
{
	g_chargerCarryNoFF[client] = false;
}

// For health kit undo, we must remember the target in HealBegin
public Action:Event_HealBegin(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_EnabledFlags) 			return Plugin_Continue;	// Not enabled?  Done

	new subject = GetClientOfUserId(GetEventInt(event, "subject"));
	new userid = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IS_SURVIVOR_ALIVE(subject) || !IS_SURVIVOR_ALIVE(userid)) return Plugin_Continue;
	
	// Remember the target for HealEnd, since that parameter is a lie for that event
	g_targetTempHealth[userid] = subject;

	if (g_DebugFlags & DEBUG_FLAG_HEAL)
	{
		PrintToChatAll("%N began healing %N", userid, subject);
	}
	return Plugin_Continue;
}

// When healing ends, remember how much temp health the target had
// This way it can be restored in UndoDamage
public Action:Event_HealEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_EnabledFlags) 			return Plugin_Continue;	// Not enabled?  Done

	new userid = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject = g_targetTempHealth[userid];	// this is used first to carry the subject...
	new tempHealth;
	
	if (!IS_SURVIVOR_ALIVE(subject))
	{
		PrintToServer("Who did you heal? (%d)", subject);	
		return Plugin_Continue;
	}
	
	tempHealth =  L4D_GetPlayerTempHealth(subject);
	if (tempHealth < 0) tempHealth = 0;
	
	// ...and second it is used to store the subject's temp health (since success knows the subject)
	g_targetTempHealth[userid] = tempHealth;
	
	if (g_DebugFlags & DEBUG_FLAG_HEAL)
	{
		PrintToChatAll("%N stopped healing (fake %N) (real %N) (%d temp)", userid, GetClientOfUserId(GetEventInt(event, "subject")), subject, tempHealth);
	}
	return Plugin_Continue;
}

// Save the amount of health restored as negative so it can be undone
public Action:Event_HealSuccess(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_EnabledFlags) 			return Plugin_Continue;	// Not enabled?  Done
	
	new subject = GetClientOfUserId(GetEventInt(event, "subject"));
	new userid = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IS_SURVIVOR_ALIVE(subject)) return Plugin_Continue;

	new nextUndo = (g_currentUndo[subject] + 1) % UNDO_SIZE;
	g_lastHealth[subject][nextUndo][UNDO_PERM] = -GetEventInt(event, "health_restored");
	g_lastHealth[subject][nextUndo][UNDO_TEMP] = g_targetTempHealth[userid];
	g_currentUndo[subject] = nextUndo;
	
	if (g_DebugFlags & DEBUG_FLAG_HEAL)
	{
		PrintToChatAll("Saving health kit undo for %N (%d, %d)", subject, g_lastHealth[subject][nextUndo][UNDO_PERM], g_lastHealth[subject][nextUndo][UNDO_TEMP]);
	}

	return Plugin_Continue;
}

// sm_undo
public Action:Command_Undo(client, args) {
	
	decl String:arg1[MAX_TARGET_LENGTH];
	decl String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS+1];
	new target_count;
	new bool:tn_is_ml;
	
	// TODO: help arg?
	
	// Assume only self
	target_count = 1;
	target_list[0] = client;
	
	if (args > 0)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	 
		if ((target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
	}

	for (new i = 0; i < target_count; i++)
	{
		UndoDamage(target_list[i], true);
	}

	return Plugin_Handled;
}

// The magic behind Undo Damage
// Cycles through the array, can also undo incapacitations
UndoDamage(client, bool:announce=false)
{
	if (IS_VALID_SURVIVOR(client))
	{
		new thisUndo = g_currentUndo[client];
		new undoPerm = g_lastHealth[client][thisUndo][UNDO_PERM];
		new undoTemp = g_lastHealth[client][thisUndo][UNDO_TEMP];
		if (g_DebugFlags & DEBUG_FLAG_UNDO)		Announce("Undo damage, perm %d + %d, temp %d + %d, incaps %d", GetClientHealth(client), undoPerm, L4D_GetPlayerTempHealth(client), undoTemp, g_lastReviveCount[client]);

		new newHealth, newTemp;
		if (L4D_IsPlayerIncapacitated(client))
		{
			// If player is incapped, restore their previous health and incap count
			newHealth = undoPerm;
			newTemp = undoTemp;
			
			CheatCommand(client, "give", "health");
			L4D_SetPlayerReviveCount(client, g_lastReviveCount[client]);
		}
		else
		{
			// add perm and temp health back to their existing health
			newHealth = GetClientHealth(client) + undoPerm;
			newTemp = undoTemp;
			if (undoPerm >= 0)
			{
				// undoing damage, so add current temp health do undoTemp
				newTemp += L4D_GetPlayerTempHealth(client);
			}
			else
			{
				// undoPerm is negative when undoing healing, so don't add current temp health
				// instead, give the health kit that was undone
				CheatCommand(client, "give", "weapon_first_aid_kit");
			}
		}
		if (newHealth > 100) newHealth = 100;						// prevent going over 100 health
		if (newHealth + newTemp > 100) newTemp = 100 - newHealth;
		SetEntityHealth(client, newHealth);
		L4D_SetPlayerTempHealth(client, newTemp);

		if (announce)
		{
			Announce("\x03Undid %d\x01 perm, \x03%d\x01 temp to \x04%N", undoPerm, undoTemp, client);
		}

		// clear out the undo so it can't happen again
		g_lastHealth[client][thisUndo][UNDO_PERM] = 0;
		g_lastHealth[client][thisUndo][UNDO_TEMP] = 0;
		
		// point to the previous undo
		if (thisUndo <= 0) thisUndo = UNDO_SIZE;
		thisUndo = thisUndo - 1;
		g_currentUndo[client] = thisUndo;
	}
}

// Gets the distance between two survivors
// Accounting for any difference in height
stock Float:GetClientsDistance(victim, attacker)
{
	decl Float:attackerPos[3], Float:victimPos[3];
	decl Float:mins[3], Float:maxs[3], Float:halfHeight;
	GetClientMins(victim, mins);
	GetClientMaxs(victim, maxs);
	
	halfHeight = maxs[2] - mins[2] + 10;
	
	GetClientAbsOrigin(victim,victimPos);
	GetClientAbsOrigin(attacker,attackerPos);
	
	new Float:posHeightDiff = attackerPos[2] - victimPos[2];
	
	if (posHeightDiff > halfHeight)
	{
		attackerPos[2] -= halfHeight;
	}
	else if (posHeightDiff < (-1.0 * halfHeight))
	{
		victimPos[2] -= halfHeight;
	}
	else
	{
		attackerPos[2] = victimPos[2];
	}
	
	if (g_DebugFlags & DEBUG_FLAG_DIST)
	{
		Announce("halfheight %f, heightdiff %f", halfHeight, posHeightDiff);
		Announce("victim %f %f %f", victimPos[0], victimPos[1], victimPos[2]);
		Announce("attacker %f %f %f", attackerPos[0], attackerPos[1], attackerPos[2]);
	}
	
	return GetVectorDistance(victimPos ,attackerPos, false);
}

// Gets per-weapon friendly fire undo distances
public Float:GetWeaponFFDist(String:weaponName[])
{
	// vary FF distance by weapon
	if (StrEqual(weaponName, "weapon_melee") || StrEqual(weaponName, "weapon_pistol") || StrEqual(weaponName, "weapon_chainsaw"))
	{
		return 25.0;
	}
	else if (StrEqual(weaponName, "weapon_smg") || StrEqual(weaponName, "weapon_smg_silenced") || StrEqual(weaponName, "weapon_smg_mp5") || StrEqual(weaponName, "weapon_pistol_magnum") || StrEqual(weaponName, "weapon_grenade_launcher"))
	{
		return 30.0;
	}
	else if	(StrEqual(weaponName, "weapon_pumpshotgun") || StrEqual(weaponName, "weapon_autoshotgun") || StrEqual(weaponName, "weapon_rifle") || StrEqual(weaponName, "weapon_hunting_rifle") || StrEqual(weaponName, "weapon_sniper_scout") || StrEqual(weaponName, "weapon_sniper_awp") || StrEqual(weaponName, "weapon_shotgun_spas") || StrEqual(weaponName, "weapon_shotgun_chrome") || StrEqual(weaponName, "weapon_rifle_sg552") || StrEqual(weaponName, "weapon_rifle_desert") || StrEqual(weaponName, "weapon_rifle_ak47"))
	{
		return 37.0;
	}
	else if (StrEqual(weaponName, "weapon_sniper_military"))
	{
		return 42.0;
	}
	else if (StrEqual(weaponName, "weapon_rifle_m60"))
	{
		return 47.0;
	}

	return 0.0;
}

stock GetSafeEntityName(entity, String:TheName[], TheNameSize)
{
	if (entity > 0 && IsValidEntity(entity))
	{
		GetEntityClassname(entity, TheName, TheNameSize);
	}
	else
	{
		strcopy(TheName, TheNameSize, "Invalid");
	}
}

// If an entity is a valid client, gets the client name (or "Disconnected"), otherwise gets the entity classname
stock GetClientOrEntityName(entity, String:TheName[], TheNameSize)
{
	if (IS_VALID_CLIENT(entity))
	{
		if (IsClientConnected(entity))
		{
			GetClientName(entity, TheName, TheNameSize);
		}
		else
		{
			strcopy(TheName, TheNameSize, "Disconnected");
		}
	}
	else
	{
		GetSafeEntityName(entity, TheName, TheNameSize);
	}
}

// I believe this is from Mr. Zero's stocks?
stock L4D_GetPlayerTempHealth(client)
{
	if (!IS_VALID_SURVIVOR(client)) return 0;
	
	static Handle:painPillsDecayCvar = INVALID_HANDLE;
	if (painPillsDecayCvar == INVALID_HANDLE)
	{
		painPillsDecayCvar = FindConVar("pain_pills_decay_rate");
		if (painPillsDecayCvar == INVALID_HANDLE)
		{
			return -1;
		}
	}

	new tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(painPillsDecayCvar))) - 1;
	return tempHealth < 0 ? 0 : tempHealth;
}

stock L4D_SetPlayerTempHealth(client, tempHealth)
{
    SetEntPropFloat(client, Prop_Send, "m_healthBuffer", float(tempHealth));
    SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}

stock L4D_GetPlayerReviveCount(client)
{
	return GetEntProp(client, Prop_Send, "m_currentReviveCount");
}

stock L4D_SetPlayerReviveCount(client, any:count)
{
	return SetEntProp(client, Prop_Send, "m_currentReviveCount", count);
}

stock bool:L4D_IsPlayerIncapacitated(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
}

stock L4D_SetPlayerIncapState(client, any:incap)
{
	SetEntProp(client, Prop_Send, "m_isIncapacitated", incap);
}

stock CheatCommand(client, const String:command[], const String:arguments[])
{
    new flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", command, arguments);
    SetCommandFlags(command, flags);
}
