#include <sourcemod>
#include <left4downtown>

#define DEBUG		0
#define MAX_INDEX	3

//40 - uppercut, 43 - right hook, 45 - left hook
static const index_to_sequence[MAX_INDEX] = {40, 43, 45};

static allowed_sequences[MAX_INDEX];
static gNumAllowedSeqMinusOne;
static gAllowedTankPunches;
static Handle:cvarAllowedTankPunches = INVALID_HANDLE;


public Plugin:myinfo = 
{
	name = "Tank Punch Control",
	author = "vintik",
	description = "Disallows chosen punch animaton",
	version = "1.0",
	url = "https://bitbucket.org/vintik/various-plugins"
}

public OnPluginStart()
{
	decl String:sGame[256];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "left4dead2", false))
	{
		SetFailState("Plugin 'Tank Punch Control' supports Left 4 dead 2 only!");
	}
	
	cvarAllowedTankPunches = CreateConVar("sm_allowed_tank_punches", "3",
	"Which server-side punch animation for tank is allowed (bitmask: 1 - uppercut, 2 - right hook, 4 - left hook)",
	FCVAR_PLUGIN | FCVAR_SPONLY);
	
	gAllowedTankPunches = GetConVarInt(cvarAllowedTankPunches);
	if (!IsValidCvarValue(gAllowedTankPunches))
	{
		ResetConVar(cvarAllowedTankPunches);
		gAllowedTankPunches = GetConVarInt(cvarAllowedTankPunches);
	}
	MappingRecalc();
	HookConVarChange(cvarAllowedTankPunches, OnCvarChange);
}

public OnCvarChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new newValInt = StringToInt(newVal);
	if (newValInt == gAllowedTankPunches) return;
	if (IsValidCvarValue(newValInt))
	{
		gAllowedTankPunches = newValInt;
		MappingRecalc();
	}
	else
	{
		PrintToServer("Incorrect value of 'sm_allowed_tank_punches'! min: 1, max: %d", (1 << MAX_INDEX) - 1);
		SetConVarString(cvar, oldVal);
	}
}

stock bool:IsValidCvarValue(value)
{
	return ((value >= 1) && (value < (1 << MAX_INDEX)));
}

stock MappingRecalc()
{
	gNumAllowedSeqMinusOne = -1;
	for (new i = 0; i < MAX_INDEX; i++)
	{
		if (IsAllowedIndex(i))
		{
			allowed_sequences[++gNumAllowedSeqMinusOne] = index_to_sequence[i];
			#if DEBUG
				PrintToServer("[DEBUG] Sequence %d is allowed", index_to_sequence[i]);
			#endif
		}
	}
}

public Action:L4D2_OnSelectTankAttack(client, &sequence)
{
	new index = SequenceToIndex(sequence);
	#if DEBUG
		PrintToServer("[DEBUG] Selected sequence is %d, its index: %d", sequence, index);
	#endif
	if (index != -1)
	{
		if (!IsAllowedIndex(index))
		{
			sequence = allowed_sequences[GetRandomInt(0, gNumAllowedSeqMinusOne)];
			#if DEBUG
				PrintToServer("[DEBUG] Sequence isn't allowed. Overriding it with %d", sequence);
			#endif
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

stock SequenceToIndex(sequence)
{
	for (new i = 0; i < MAX_INDEX; i++)
	{
		if (index_to_sequence[i] == sequence)
			return i;
	}
	return -1;
}

stock bool:IsAllowedIndex(index)
{
	if ((1 << index) & gAllowedTankPunches)
		return true;
	else
		return false;
}