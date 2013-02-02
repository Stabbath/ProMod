#include <sourcemod>
#include <sdktools>
#include <l4d2_direct>

new Handle:gConf = INVALID_HANDLE;
new Handle:fSetCampaignScores = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "SetScores",
	author = "vintik",
	description = "Changes teams' scores.",
	version = "1.0",
	url = "https://bitbucket.org/vintik/various-plugins"
}

public OnPluginStart()
{
	decl String:sGame[256];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "left4dead2", false))
	{
		SetFailState("Plugin 'SetScores' supports Left 4 Dead 2 only!");
	}
	
	gConf = LoadGameConfigFile("left4downtown.l4d2");
	if(gConf == INVALID_HANDLE)
	{
		LogError("Could not load gamedata/left4downtown.l4d2.txt");
	}
	
	
	StartPrepSDKCall(SDKCall_GameRules);
	if(PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "SetCampaignScores")) {
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		fSetCampaignScores = EndPrepSDKCall();
		if(fSetCampaignScores == INVALID_HANDLE) {
			LogError("Function 'SetCampaignScores' found, but something went wrong.");
		}
	} else {
		LogError("Function 'SetCampaignScores' not found.");
	}
	
	RegAdminCmd("sm_setscores", Command_SetScores, ADMFLAG_BAN, "sm_setscores <team A score> <team B score>");
}

public Action:Command_SetScores(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setscores <team A score> <team B score>");
		return Plugin_Handled;
	}
	
	new iAScore, iBScore, String:buffer[32];
	GetCmdArg(1, buffer, sizeof(buffer));
	iAScore = StringToInt(buffer);
	GetCmdArg(2, buffer, sizeof(buffer));
	iBScore = StringToInt(buffer);
	
	SDKCall(fSetCampaignScores, iAScore, iBScore); //visible scores
	L4D2Direct_SetVSCampaignScore(0, iAScore);//real scores
	L4D2Direct_SetVSCampaignScore(1, iBScore);
	return Plugin_Handled;
}
