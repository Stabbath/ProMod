#include <sourcemod>
#include <sdktools>
#include <left4downtown>

#define FINALE_STAGE_TANK 8

public Plugin:myinfo =
{
	name = "Finale Even-Numbered Tank Blocker",
	author = "Stabby",
	description = "Blocks even-numbered non-flow finale tanks.",
	version = "1",
	url = "nourl"
};

new iTankCount[2];

public Action:L4D2_OnChangeFinaleStage(&finaleType, const String:arg[]) {
	if (finaleType == FINALE_STAGE_TANK) {
		if (++iTankCount[GameRules_GetProp("m_bInSecondHalfOfRound")] % 2 == 0) return Plugin_Handled;
	}
	return Plugin_Continue;
}

public OnMapEnd() {
	iTankCount[0] = 0;
	iTankCount[1] = 0;
}
