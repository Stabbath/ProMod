#pragma semicolon 1
#include <sourcemod>
#include <survivors>

public Plugin:myinfo = 
{
	name = "L4D2 Double Get-Up Fix",
	author = "Blade, ProdigySim, DieTeetasse",
	description = "Double Get Up fix.",
	version = "1.4",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}

// frames: 64, fps: 30, length: 2.133
#define ANIM_HUNTER_LEN 2.2
// frames: 85, fps 30, length: 2.833
#define ANIM_CHARGER_LEN 2.9

new const getUpAnimations[SurvivorCharacter][2] = {
	// 0: Coach, 1: Nick, 2: Rochelle, 3: Ellis
	{621, 656}, {620, 667}, {629, 674}, {625, 671},
	// 4: Louis, 5: Zoey, 6: Bill, 7: Francis
	{528, 759}, {648, 693}, {528, 759}, {531, 760}
};

new PropOff_nSequence;
new PropOff_flCycle;


public OnPluginStart() {
	L4D2Survivors_Init();
	HookEvent("pounce_end", Event_PounceOrPummel);
	HookEvent("charger_pummel_end", Event_PounceOrPummel);
	
	PropOff_nSequence = FindSendPropInfo("CTerrorPlayer", "m_nSequence");
	PropOff_flCycle = FindSendPropInfo("CTerrorPlayer", "m_flCycle");
}

public Event_PounceOrPummel(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "victim"));
	if (client == 0) return;
	if (!IsClientInGame(client)) return;
	
	CreateTimer(0.1, Timer_ProcessClient, client);
}

public Action:Timer_ProcessClient(Handle:timer, any:client) {
	ProcessClient(client);
}

ProcessClient(client) {
	new SurvivorCharacter:charIndex = IdentifySurvivor(client);	
	if (charIndex == SC_NONE) return;
	
	new sequence = GetEntData(client, PropOff_nSequence);
	
	// charger or hunter get up animation?
	if (sequence != getUpAnimations[charIndex][0] && sequence != getUpAnimations[charIndex][1])
		return;
	
	// create stack with client and sequence
	new Handle:tempStack = CreateStack(3);
	PushStackCell(tempStack, client);
	PushStackCell(tempStack, sequence);
	
	if (sequence == getUpAnimations[charIndex][0]) {		
		CreateTimer(ANIM_HUNTER_LEN, Timer_CheckClient, tempStack);
	}
	else {
		CreateTimer(ANIM_CHARGER_LEN, Timer_CheckClient, tempStack);
	}
}

public Action:Timer_CheckClient(Handle:timer, any:tempStack) {
	decl client, oldSequence; 
	PopStackCell(tempStack, oldSequence);
	PopStackCell(tempStack, client);
	
	new SurvivorCharacter:charIndex = IdentifySurvivor(client);	
	if (charIndex == SC_NONE) return;
	
	new newSequence = GetEntData(client, PropOff_nSequence);
	
	// charger or hunter get up animation?
	if (newSequence != getUpAnimations[charIndex][0] && newSequence != getUpAnimations[charIndex][1])
		return;
		
	// not the same animation?
	if (newSequence == oldSequence) 
		return;
	
	// Apply!
	ApplyAnimationSkip(client);
}

ApplyAnimationSkip(client) {
	SetEntDataFloat(client, PropOff_flCycle, 2.0, true);
}