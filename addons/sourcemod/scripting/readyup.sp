#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <l4d2_direct>

#define MAX_FOOTERS 10
#define MAX_FOOTER_LEN 65

#define SOUND "/level/gnomeftw.wav"

#define DEBUG 0

public Plugin:myinfo =
{
	name = "L4D2 Ready-Up",
	author = "CanadaRox",
	description = "New and improved ready-up plugin.",
	version = "6",
	url = ""
};

enum L4D2Team
{
	L4D2Team_None = 0,
	L4D2Team_Spectator,
	L4D2Team_Survivor,
	L4D2Team_Infected
}

// Plugin Cvars
new Handle:l4d_ready_disable_spawns;
new Handle:l4d_ready_cfg_name;
new Handle:l4d_ready_survivor_freeze;
new Handle:l4d_ready_max_players;

// Game Cvars
new Handle:director_no_specials;
new Handle:god;
new Handle:sb_stop;
new Handle:survivor_limit;
new Handle:z_max_player_zombies;

new Handle:casterTrie;
new Handle:liveForward;
new Handle:menuPanel;
new Handle:readyCountdownTimer;
new String:readyFooter[MAX_FOOTERS][MAX_FOOTER_LEN];
new bool:hiddenPanel[MAXPLAYERS + 1];
new bool:inLiveCountdown = false;
new bool:inReadyUp;
new bool:isPlayerReady[MAXPLAYERS + 1];
new footerCounter = 0;
new readyDelay;
new bool:blockSecretSpam[MAXPLAYERS + 1];

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("AddStringToReadyFooter", Native_AddStringToReadyFooter);
	CreateNative("IsInReady", Native_IsInReady);
	CreateNative("IsClientCaster", Native_IsClientCaster);
	CreateNative("IsIDCaster", Native_IsIDCaster);
	liveForward = CreateGlobalForward("OnRoundIsLive", ET_Event);
	RegPluginLibrary("readyup");
	return APLRes_Success;
}

public OnPluginStart()
{
	CreateConVar("l4d_ready_enabled", "1", "This cvar doesn't do anything, but if it is 0 the logger wont log this game.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	l4d_ready_cfg_name = CreateConVar("l4d_ready_cfg_name", "", "Configname to display on the ready-up panel", FCVAR_PLUGIN|FCVAR_PRINTABLEONLY);
	l4d_ready_disable_spawns = CreateConVar("l4d_ready_disable_spawns", "0", "Prevent SI from having spawns during ready-up", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	l4d_ready_survivor_freeze = CreateConVar("l4d_ready_survivor_freeze", "1", "Freeze the survivors during ready-up.  When unfrozen they are unable to leave the saferoom but can move freely inside", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	l4d_ready_max_players = CreateConVar("l4d_ready_max_players", "12", "Maximum number of players to show on the ready-up panel.", FCVAR_PLUGIN, true, 0.0, true, MAXPLAYERS+1.0);
	HookConVarChange(l4d_ready_survivor_freeze, SurvFreezeChange);

	HookEvent("round_start", RoundStart_Event);

	casterTrie = CreateTrie();

	director_no_specials = FindConVar("director_no_specials");
	god = FindConVar("god");
	sb_stop = FindConVar("sb_stop");
	survivor_limit = FindConVar("survivor_limit");
	z_max_player_zombies = FindConVar("z_max_player_zombies");

	RegAdminCmd("sm_caster", Caster_Cmd, ADMFLAG_BAN, "Registers a player as a caster so the round will not go live unless they are ready");
	RegAdminCmd("sm_forcestart", ForceStart_Cmd, ADMFLAG_BAN, "Forces the round to start regardless of player ready status.  Players can unready to stop a force");
	RegConsoleCmd("\x73\x6d\x5f\x62\x6f\x6e\x65\x73\x61\x77", Secret_Cmd, "Every player has a different secret number between 0-1023");
	RegConsoleCmd("sm_hide", Hide_Cmd, "Hides the ready-up panel so other menus can be seen");
	RegConsoleCmd("sm_show", Show_Cmd, "Shows a hidden ready-up panel");
	RegConsoleCmd("sm_notcasting", NotCasting_Cmd, "Deregister yourself as a caster or allow admins to deregister other players");
	RegConsoleCmd("sm_ready", Ready_Cmd, "Mark yourself as ready for the round to go live");
	RegConsoleCmd("sm_toggleready", ToggleReady_Cmd, "Toggle your ready status");
	RegConsoleCmd("sm_unready", Unready_Cmd, "Mark yourself as not ready if you have set yourself as ready");
	RegConsoleCmd("sm_return", Return_Cmd, "Return to a valid saferoom spawn if you get stuck during an unfrozen ready-up period");
	RegServerCmd("sm_resetcasters", ResetCaster_Cmd, "Used to reset casters between matches.  This should be in confogl_off.cfg or equivalent for your system");

#if DEBUG
	RegAdminCmd("sm_initready", InitReady_Cmd, ADMFLAG_ROOT);
	RegAdminCmd("sm_initlive", InitLive_Cmd, ADMFLAG_ROOT);
#endif

	LoadTranslations("common.phrases");
}

public OnPluginEnd()
{
	if (inReadyUp)
		InitiateLive();
}

public OnMapStart()
{
	/* OnMapEnd needs this to work */
	PrecacheSound(SOUND);
	for (new client = 1; client <= MAXPLAYERS; client++)
	{
		blockSecretSpam[client] = false;
	}
}

/* This ensures all cvars are reset if the map is changed during ready-up */
public OnMapEnd()
{
	if (inReadyUp)
		InitiateLive();
}

public OnClientDisconnect(client)
{
	hiddenPanel[client] = false;
	isPlayerReady[client] = false;
}

public Native_AddStringToReadyFooter(Handle:plugin, numParams)
{
	decl String:footer[MAX_FOOTER_LEN];
	GetNativeString(1, footer, sizeof(footer));
	if (footerCounter < MAX_FOOTERS)
	{
		if (strlen(footer) < MAX_FOOTER_LEN)
		{
			strcopy(readyFooter[footerCounter], MAX_FOOTER_LEN, footer);
			footerCounter++;
			return _:true;
		}
	}
	return _:false;
}

public Native_IsInReady(Handle:plugin, numParams)
{
	return _:inReadyUp;
}

public Native_IsClientCaster(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	return _:IsClientCaster(client);
}

public Native_IsIDCaster(Handle:plugin, numParams)
{
	decl String:buffer[64];
	GetNativeString(1, buffer, sizeof(buffer));
	return _:IsIDCaster(buffer);
}

stock bool:IsClientCaster(client)
{
	decl String:buffer[64];
	return GetClientAuthString(client, buffer, sizeof(buffer)) && IsIDCaster(buffer);
}

stock bool:IsIDCaster(const String:AuthID[])
{
	decl dummy;
	return GetTrieValue(casterTrie, AuthID, dummy);
}

public Action:Caster_Cmd(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_caster <player>");
		return Plugin_Handled;
	}
	
	decl String:buffer[64];
	GetCmdArg(1, buffer, sizeof(buffer));

	new target = FindTarget(client, buffer, true, false);
	if (target > 0) // If FindTarget fails we don't need to print anything as it prints it for us!
	{
		if (GetClientAuthString(target, buffer, sizeof(buffer)))
		{
			SetTrieValue(casterTrie, buffer, 1);
			ReplyToCommand(client, "Registered %N as a caster", target);
		}
		else
		{
			ReplyToCommand(client, "Couldn't find Steam ID.  Check for typos and let the player get fully connected.");
		}
	}
	return Plugin_Handled;
}

public Action:ResetCaster_Cmd(args)
{
	ClearTrie(casterTrie);
	return Plugin_Handled;
}

public Action:Hide_Cmd(client, args)
{
	hiddenPanel[client] = true;
	return Plugin_Handled;
}

public Action:Show_Cmd(client, args)
{
	hiddenPanel[client] = false;
	return Plugin_Handled;
}

public Action:NotCasting_Cmd(client, args)
{
	decl String:buffer[64];
	
	if(args < 1) // If no target is specified
	{
		GetClientAuthString(client, buffer, sizeof(buffer));
		RemoveFromTrie(casterTrie, buffer);
		return Plugin_Handled;
	}
	else // If a target is specified
	{
		new AdminId:id;
		id = GetUserAdmin(client);
		new bool:hasFlag = false;
		
		if(id != INVALID_ADMIN_ID)
		{
			hasFlag = GetAdminFlag(id, Admin_Ban); // Check for specific admin flag
		}
		
		if(!hasFlag) 
		{
			ReplyToCommand(client, "Only admins can remove other casters. Use sm_notcasting without arguments if you wish to remove yourself.");
			return Plugin_Handled;
		}
		
		GetCmdArg(1, buffer, sizeof(buffer));
		
		new target = FindTarget(client, buffer, true, false);
		if (target > 0) // If FindTarget fails we don't need to print anything as it prints it for us!
		{
			if (GetClientAuthString(target, buffer, sizeof(buffer)))
			{
				RemoveFromTrie(casterTrie, buffer);
				ReplyToCommand(client, "%N is no longer a caster", target);
			}
			else
			{
				ReplyToCommand(client, "Couldn't find Steam ID.  Check for typos and let the player get fully connected.");
			}
		}
		return Plugin_Handled;
	}
}

public Action:ForceStart_Cmd(client, args)
{
	InitiateLiveCountdown();
	return Plugin_Handled;
}

public Action:Secret_Cmd(client, args)
{
	if (inReadyUp)
	{
		decl String:steamid[64];
		decl String:argbuf[30];
		GetCmdArg(1, argbuf, sizeof(argbuf));
		new arg = StringToInt(argbuf);
		GetClientAuthString(client, steamid, sizeof(steamid));
		new id = StringToInt(steamid[10]);

		if ((id & 1023) ^ arg == 'C'+'a'+'n'+'a'+'d'+'a'+'R'+'o'+'x')
		{
			DoSecrets(client);
			isPlayerReady[client] = true;
			if (CheckFullReady())
				InitiateLiveCountdown();

			return Plugin_Handled;
		}
		
	}
	return Plugin_Continue;
}

public Action:Ready_Cmd(client, args)
{
	if (inReadyUp)
	{
		isPlayerReady[client] = true;
		if (CheckFullReady())
			InitiateLiveCountdown();
	}

	return Plugin_Handled;
}

public Action:Unready_Cmd(client, args)
{
	if (inReadyUp)
	{
		isPlayerReady[client] = false;
		CancelFullReady();
	}

	return Plugin_Handled;
}

public Action:ToggleReady_Cmd(client, args)
{
	if (inReadyUp)
	{
		isPlayerReady[client] = !isPlayerReady[client];
		if (isPlayerReady[client] && CheckFullReady())
		{
			InitiateLiveCountdown();
		}
		else
		{
			CancelFullReady();
		}
	}

	return Plugin_Handled;
}

/* No need to do any other checks since it seems like this is required no matter what since the intros unfreezes players after the animation completes */
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (inReadyUp)
	{
		if (IsClientInGame(client) && L4D2Team:GetClientTeam(client) == L4D2Team_Survivor)
		{
			if (GetConVarBool(l4d_ready_survivor_freeze))
			{
				if (!(GetEntityMoveType(client) == MOVETYPE_NONE || GetEntityMoveType(client) == MOVETYPE_NOCLIP))
				{
					SetFrozen(client, true);
				}
			}
			else
			{
				if (GetEntityFlags(client) & FL_INWATER)
				{
					ReturnPlayerToSaferoom(client, false);
				}
			}
		}
	}
}

public SurvFreezeChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ReturnTeamToSaferoom(GetConVarBool(convar));
}

public Action:L4D_OnFirstSurvivorLeftSafeArea(client)
{
	if (inReadyUp)
	{
		ReturnTeamToSaferoom(false);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Return_Cmd(client, args)
{
	ReturnPlayerToSaferoom(client, false);
	return Plugin_Handled;
}

public RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	InitiateReadyUp();
}

#if DEBUG
public Action:InitReady_Cmd(client, args)
{
	InitiateReadyUp();
	return Plugin_Handled;
}

public Action:InitLive_Cmd(client, args)
{
	InitiateLive();
	return Plugin_Handled;
}
#endif

public DummyHandler(Handle:menu, MenuAction:action, param1, param2) { }

public Action:MenuRefresh_Timer(Handle:timer)
{
	if (inReadyUp)
	{
		UpdatePanel();
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

UpdatePanel()
{
	if (menuPanel != INVALID_HANDLE)
	{
		CloseHandle(menuPanel);
		menuPanel = INVALID_HANDLE;
	}

	new String:readyBuffer[800] = "";
	new String:unreadyBuffer[800] = "";
	new String:specBuffer[800] = "";
	new readyCount = 0;
	new unreadyCount = 0;
	new playerCount = 0;
	new specCount = 0;

	menuPanel = CreatePanel();

	decl String:nameBuf[MAX_NAME_LENGTH*2];
	decl String:authBuffer[64];
	decl bool:caster;
	decl dummy;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			++playerCount;
			GetClientName(client, nameBuf, sizeof(nameBuf));
			GetClientAuthString(client, authBuffer, sizeof(authBuffer));
			caster = GetTrieValue(casterTrie, authBuffer, dummy);
			if (IsPlayer(client) || caster)
			{
				if (isPlayerReady[client])
				{
					if (!inLiveCountdown) PrintHintText(client, "You are ready.\nSay !unready to unready.");
					Format(nameBuf, sizeof(nameBuf), "->%d. %s%s\n", ++readyCount, nameBuf, caster ? " [Caster]" : "");
					StrCat(readyBuffer, sizeof(readyBuffer), nameBuf);
				}
				else
				{
					if (!inLiveCountdown) PrintHintText(client, "You are not ready.\nSay !ready to ready up.");
					Format(nameBuf, sizeof(nameBuf), "->%d. %s%s\n", ++unreadyCount, nameBuf, caster ? " [Caster]" : "");
					StrCat(unreadyBuffer, sizeof(unreadyBuffer), nameBuf);
				}
			}
			else
			{
				++specCount;
				if (playerCount <= GetConVarInt(l4d_ready_max_players))
				{
					Format(nameBuf, sizeof(nameBuf), "->%d. %s\n", specCount, nameBuf);
					StrCat(specBuffer, sizeof(specBuffer), nameBuf);
				}
			}
		}
	}

	new bufLen = strlen(readyBuffer);
	if (bufLen != 0)
	{
		readyBuffer[bufLen] = '\0';
		ReplaceString(readyBuffer, sizeof(readyBuffer), "#buy", "<- TROLL");
		ReplaceString(readyBuffer, sizeof(readyBuffer), "#", "_");
		DrawPanelText(menuPanel, "Ready");
		DrawPanelText(menuPanel, readyBuffer);
	}

	bufLen = strlen(unreadyBuffer);
	if (bufLen != 0)
	{
		unreadyBuffer[bufLen] = '\0';
		ReplaceString(unreadyBuffer, sizeof(readyBuffer), "#buy", "<- TROLL");
		ReplaceString(unreadyBuffer, sizeof(unreadyBuffer), "#", "_");
		DrawPanelText(menuPanel, "Unready");
		DrawPanelText(menuPanel, unreadyBuffer);
	}

	bufLen = strlen(specBuffer);
	if (bufLen != 0)
	{
		specBuffer[bufLen] = '\0';
		DrawPanelText(menuPanel, "Spectator");
		ReplaceString(specBuffer, sizeof(specBuffer), "#", "_");
		if (playerCount > GetConVarInt(l4d_ready_max_players))
			FormatEx(specBuffer, sizeof(specBuffer), "->1. Many (%d)", specCount);
		DrawPanelText(menuPanel, specBuffer);
	}

	decl String:cfgBuf[128];
	GetConVarString(l4d_ready_cfg_name, cfgBuf, sizeof(cfgBuf));
	DrawPanelText(menuPanel, cfgBuf);

	for (new i = 0; i < MAX_FOOTERS; i++)
	{
		DrawPanelText(menuPanel, readyFooter[i]);
	}

	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client) && !hiddenPanel[client])
		{
			SendPanelToClient(menuPanel, client, DummyHandler, 1);
		}
	}
}

InitiateReadyUp()
{
	for (new i = 0; i <= MAXPLAYERS; i++)
	{
		isPlayerReady[i] = false;
	}

	UpdatePanel();
	CreateTimer(1.0, MenuRefresh_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	inReadyUp = true;
	inLiveCountdown = false;
	readyCountdownTimer = INVALID_HANDLE;

	if (GetConVarBool(l4d_ready_disable_spawns))
	{
		SetConVarBool(director_no_specials, true);
	}

	SetConVarFlags(god, GetConVarFlags(god) & ~FCVAR_NOTIFY);
	SetConVarBool(god, true);
	SetConVarFlags(god, GetConVarFlags(god) | FCVAR_NOTIFY);
	SetConVarBool(sb_stop, true);

	L4D2_CTimerStart(L4D2CT_VersusStartTimer, 99999.9);
}

InitiateLive()
{
	inReadyUp = false;
	inLiveCountdown = false;

	ReturnTeamToSaferoom(false);

	SetConVarBool(director_no_specials, false);
	SetConVarFlags(god, GetConVarFlags(god) & ~FCVAR_NOTIFY);
	SetConVarBool(god, false);
	SetConVarFlags(god, GetConVarFlags(god) | FCVAR_NOTIFY);
	SetConVarBool(sb_stop, false);

	L4D2_CTimerStart(L4D2CT_VersusStartTimer, 60.0);

	for (new i = 0; i < MAX_FOOTERS; i++)
	{
		readyFooter[i] = "";
	}

	footerCounter = 0;
	Call_StartForward(liveForward);
	Call_Finish();
}

ReturnPlayerToSaferoom(client, bool:flagsSet = true)
{
	new flags;
	if (!flagsSet)
	{
		flags = GetCommandFlags("warp_to_start_area");
		SetCommandFlags("warp_to_start_area", flags & ~FCVAR_CHEAT);
	}

	if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge"))
	{
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
		SetEntProp(client, Prop_Send, "m_isHangingFromLedge", 0);
		SetEntProp(client, Prop_Send, "m_isFallingFromLedge", 0);
		SetEntProp(client, Prop_Send, "m_iHealth", L4D2Direct_GetPreIncapHealth(client));
		SetEntProp(client, Prop_Send, "m_reviveOwner", 0);
		SetEntProp(client, Prop_Send, "m_reviveTarget", 0);
		SetSurvivorTempHealth(client, Float:L4D2Direct_GetPreIncapHealthBuffer(client));
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangTwoHands");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangOneHand");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangFingers");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangAboutToFall");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangFalling");

		new Handle:event = CreateEvent("revive_success");
		SetEventInt(event, "userid", GetClientUserId(client));
		SetEventInt(event, "subject", GetClientUserId(client));
		SetEventBool(event, "lastlife", false);
		SetEventBool(event, "ledge_hang", true);
		FireEvent(event);
	}

	FakeClientCommand(client, "warp_to_start_area");

	if (!flagsSet)
	{
		SetCommandFlags("warp_to_start_area", flags);
	}
}

ReturnTeamToSaferoom(bool:freezeStatus)
{
	new flags = GetCommandFlags("warp_to_start_area");
	SetCommandFlags("warp_to_start_area", flags & ~FCVAR_CHEAT);

	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && L4D2Team:GetClientTeam(client) == L4D2Team_Survivor)
		{
			SetFrozen(client, freezeStatus);
			ReturnPlayerToSaferoom(client, true);
		}
	}

	SetCommandFlags("warp_to_start_area", flags);
}

bool:CheckFullReady()
{
	new readyCount = 0;
	new casterCount = 0;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			if (IsClientCaster(client))
			{
				casterCount++;
			}

			if((IsPlayer(client) || IsClientCaster(client)) && isPlayerReady[client])
			{
				readyCount++;
			}
		}
	}
	return readyCount >= GetConVarInt(survivor_limit) + GetConVarInt(z_max_player_zombies) + casterCount;
}

InitiateLiveCountdown()
{
	if (readyCountdownTimer == INVALID_HANDLE)
	{
		PrintHintTextToAll("Going live!\nSay !unready to cancel");
		inLiveCountdown = true;
		readyDelay = 5;
		readyCountdownTimer = CreateTimer(1.0, ReadyCountdownDelay_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:ReadyCountdownDelay_Timer(Handle:timer)
{
	if (readyDelay == 0)
	{
		PrintHintTextToAll("Round is live!");
		InitiateLive();
		return Plugin_Stop;
	}
	else
	{
		PrintHintTextToAll("Live in: %d\nSay !unready to cancel", readyDelay);
		readyDelay--;
	}
	return Plugin_Continue;
}

CancelFullReady()
{
	if (readyCountdownTimer != INVALID_HANDLE)
	{
		inLiveCountdown = false;
		CloseHandle(readyCountdownTimer);
		readyCountdownTimer = INVALID_HANDLE;
		PrintHintTextToAll("Countdown Cancelled!");
	}
}

stock SetFrozen(client, freeze)
{
	SetEntityMoveType(client, freeze ? MOVETYPE_NONE : MOVETYPE_WALK);
}

stock IsPlayer(client)
{
	new L4D2Team:team = L4D2Team:GetClientTeam(client);
	return (team == L4D2Team_Survivor || team == L4D2Team_Infected);
}

stock GetTeamHumanCount(L4D2Team:team)
{
	new humans = 0;
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && L4D2Team:GetClientTeam(client) == team)
		{
			humans++;
		}
	}
	
	return humans;
}

stock DoSecrets(client)
{
	PrintCenterTextAll("\x42\x4f\x4e\x45\x53\x41\x57\x20\x49\x53\x20\x52\x45\x41\x44\x59\x21");
	if (GetClientTeam(client) == 2 && !blockSecretSpam[client])
	{
		new particle = CreateEntityByName("info_particle_system");
		decl Float:pos[3];
		GetClientAbsOrigin(client, pos);
		pos[2] += 50;
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", "achieved");
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(10.0, killParticle, particle, TIMER_FLAG_NO_MAPCHANGE);
		EmitSoundToAll(SOUND, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);
		CreateTimer(2.0, SecretSpamDelay, client);
		blockSecretSpam[client] = true;
	}
}

public Action:SecretSpamDelay(Handle:timer, any:client)
{
	blockSecretSpam[client] = false;
}

public Action:killParticle(Handle:timer, any:entity)
{
	if(entity > 0 && IsValidEntity(entity) && IsValidEdict(entity))
	{
		AcceptEntityInput(entity, "Kill");
	}
}

stock SetSurvivorTempHealth(client, Float:newOverheal)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", newOverheal);
}
