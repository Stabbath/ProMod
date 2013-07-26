#include <sourcemod>
#include <sdktools>
#include <left4downtown>

#define FINALE_STAGE_TANK 8

public Plugin:myinfo =
{
	name = "Finale Tank Blocker",
	author = "Stabby",
	description = "Just blocks the second finale tank when there is one.",
	version = "1",
	url = "nourl"
};

new iTankCount[2];

public Action:L4D2_OnChangeFinaleStage(&finaleType, const String:arg[]) {
	if (finaleType == FINALE_STAGE_TANK) {
		if (++iTankCount[GameRules_GetProp("m_bInSecondHalfOfRound")] > 1) return Plugin_Handled;
	}
	return Plugin_Continue;
}

public OnMapEnd() {
	iTankCount[0] = 0;
	iTankCount[1] = 0;
}
