#pragma semicolon 1
#include <sourcemod>
#include <weapons>

#define DEBUG 0

new g_GlobalWeaponRules[WeaponId]={-1, ...};

// state tracking for roundstart looping
new g_bRoundStartHit;
new g_bConfigsExecuted;

public OnPluginStart()
{
	RegServerCmd("l4d2_addweaponrule", AddWeaponRuleCb);
	RegServerCmd("l4d2_resetweaponrules", ResetWeaponRulesCb);
	HookEvent("round_start", RoundStartCb, EventHookMode_PostNoCopy);
	ResetWeaponRules();
}

public Action:ResetWeaponRulesCb(args)
{
	ResetWeaponRules();
	return Plugin_Handled;
}

ResetWeaponRules()
{
	for(new i=0; i < _:WeaponId; i++) g_GlobalWeaponRules[i]=-1;
}

public RoundStartCb(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(0.3, RoundStartDelay, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
}

public OnMapStart()
{
	g_bRoundStartHit=false;
	g_bConfigsExecuted=false;
}

public OnConfigsExecuted()
{
	g_bConfigsExecuted=true;
	if(g_bRoundStartHit)
	{
		WeaponSearchLoop();
	}
}
public Action:RoundStartDelay(Handle:timer)
{
	g_bRoundStartHit=true;
	if(g_bConfigsExecuted)
	{
		WeaponSearchLoop();
	}
}

public Action:AddWeaponRuleCb(args)
{
	if(args < 2)
	{
		PrintToServer("Usage: l4d2_addweaponrule <match> <replace>");
		return Plugin_Handled;
	}
	decl String:weaponbuf[64];

	GetCmdArg(1, weaponbuf, sizeof(weaponbuf));
	new WeaponId:match = WeaponNameToId2(weaponbuf);

	GetCmdArg(2, weaponbuf, sizeof(weaponbuf));
	new WeaponId:to = WeaponNameToId2(weaponbuf);

	AddWeaponRule(match, _:to);
	return Plugin_Handled;
}


AddWeaponRule(WeaponId:match, to)
{
	if(IsValidWeaponId(match) && (to == -1 || IsValidWeaponId(WeaponId:to)))
	{
		g_GlobalWeaponRules[match] = _:to;
#if DEBUG
		PrintToServer("Added weapon rule: %d to %d", match, to);
#endif

	}
}

WeaponSearchLoop()
{
	new entcnt = GetEntityCount();
	for(new ent=1; ent < entcnt; ent++)
	{
		new WeaponId:source=IdentifyWeapon(ent);
		if(source > WEPID_NONE && g_GlobalWeaponRules[source] != -1)
		{
			if(g_GlobalWeaponRules[source] == _:WEPID_NONE)
			{
				AcceptEntityInput(ent, "kill");
				#if DEBUG
				PrintToServer("Found Weapon %d, killing", source);
				#endif
			}
			else
			{
				#if DEBUG
				PrintToServer("Found Weapon %d, converting to %d", source, g_GlobalWeaponRules[source]);
				#endif
				ConvertWeaponSpawn(ent, WeaponId:g_GlobalWeaponRules[source]);
			}
		}
	}
}

// Tries the given weapon name directly, and upon failure,
// tries prepending "weapon_" to the given name
stock WeaponId:WeaponNameToId2(const String:name[])
{
	static String:namebuf[64]="weapon_";
	new WeaponId:wepid = WeaponNameToId(name);
	if(wepid == WEPID_NONE)
	{
		strcopy(namebuf[7], sizeof(namebuf)-7, name);
		wepid=WeaponNameToId(namebuf);
	}
	return wepid;
}
