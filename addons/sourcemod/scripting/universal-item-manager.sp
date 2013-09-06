#pragma semicolon 1

#include <sourcemod>
#include <l4d2_direct>
#include <l4d2util>
#include <l4d2_saferoom_detect>
//#include <all that other shit>

/* Notes:
	spread is currently disabled
*/

#define DEBUG

#define SYNTAX_RULE_BAN        0 //keep as first
#define SYNTAX_RULE_SPREAD     1
#define SYNTAX_RULE_SPEC_CLASS 2 //keep as first spec
#define SYNTAX_RULE_SPEC_DATA  3
#define SYNTAX_RULE_SPEC_SEND  4
#define SYNTAX_RULE_SPEC_UNDEF 5 //keep as last spec
#define SYNTAX_RULE_KEY        6
#define SYNTAX_RULE_UNDEF      7 //keep as last

#define LIMIT_START 0
#define LIMIT_MAP   1
#define LIMIT_END   2
#define LIMIT_COUNT 3

#define SPEC_SEND   0
#define SPEC_DATA   1
#define SPEC_COUNT  2

#define BUF_SZ 64

#define TIME_POST_ROUNDSTART 10.0
#define TIME_POST_MAPSTART   10.0

public Plugin:myinfo = {
	name = "Universal Item Management",
	author = "Stabby",
	description = "Allows for some dynamic non-stripper control over entity spawns",
	version = "-1",
	url = "nourl"
}

new Handle:g_hCvarForceExistAll;

new Handle:g_hTrieItemSettings;       //stores an adt_array for every item
new Handle:g_hTrieItemNameByCvarName; //stores the item name for each created cvar
new Handle:g_hArrayItemSettings;      //for iterating through the eponymous trie
new Handle:g_hArrayItemsToSpawn;      //for spawning wanted items on both rounds

public OnPluginStart() {
	g_hCvarForceExistAll = CreateConVar("uim_force_exist_all", "1",
										"Forces all available weapon spawns to exist and lets the plugin sort them out all on its own.",
										FCVAR_PLUGIN, true, 0.0, true, 1.0);

	RegServerCmd("uim_limit",            Cmd_Limit,            "Sets limits for an entity.");
	RegServerCmd("uim_limit_createcvar", Cmd_Limit_CreateCvar, "Creates cvars for the different item limits that can be used to change limits instead of using uim_limit (still need to use uim_limit first though to register the entity).");
	RegServerCmd("uim_addrule",          Cmd_AddRule,          "Adds a rule to an entity.");
	RegServerCmd("uim_clearbanranges",   Cmd_ClearBans,        "Removes stored ban intervals.");

	g_hTrieItemSettings = CreateTrie();
	g_hTrieItemNameByCvarName = CreateTrie();
	g_hArrayItemsToSpawn = CreateArray(BUF_SZ/4);
	g_hArrayItemSettings = CreateArray(BUF_SZ/4);
}

public OnEntityCreated(entity, String:classname[]) {
	if (GetConVarBool(g_hCvarForceExistAll) && StrContains(classname, "_spawn") > 0) {
		SetEntityFlags(entity, GetEntityFlags(entity) | 2); 
	}
}

public OnMapStart() CreateTimer(TIME_POST_MAPSTART, Timed_PostMapStart);
public Action:Timed_PostMapStart(Handle:timer) {
	ClearArray(g_hArrayItemsToSpawn);
	SelectWantedItems();
	RemoveAllItems();
	SpawnWantedItems();
}
public OnRoundStart() CreateTimer(TIME_POST_ROUNDSTART, Timed_PostRoundStart);
public Action:Timed_PostRoundStart(Handle:timer) {
	if (InSecondHalfOfRound()) {
		RemoveAllItems();
		SpawnWantedItems();
	}
}

/* * * * * * * * * * * * * * * * * *
 *                                 *
 * LIMIT ENFORCEMENT               *
 *                                 *
 * * * * * * * * * * * * * * * * * */

stock GetSpawnCoords(Handle:spawnArray, Float:pos[3], Float:ang[3]) {
	new Handle:coordArray = GetArrayCell(spawnArray, 1);
	GetArrayArray(coordArray, 0, pos);
	GetArrayArray(coordArray, 1, ang);
}
stock Handle:GetItemName(Handle:spawnArray, String:item[]) {
	new Handle:itemNameArray = GetArrayCell(spawnArray, 0);
	GetArrayString(itemNameArray, 0, item, BUF_SZ);
}
stock GetMeleeScriptName(Handle:spawnArray, String:name[]) {
	new Handle:meleeScriptName = GetArrayCell(spawnArray, 2);
	GetArrayString(meleeScriptName, 0, name, BUF_SZ);
}

stock AddToWantedList(String:item[], entity, String:name[]="") {
	decl Float:pos[3], Float:ang[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
	
	new Handle:spawnArray = CreateArray();

	new Handle:itemNameArray = CreateArray(BUF_SZ/4);
	PushArrayString(itemNameArray, item);		
	PushArrayCell(spawnArray, itemNameArray);	//0 handle_item_name_array
	new Handle:coordArray = CreateArray(3);
	PushArrayArray(coordArray, pos);	//1:0 pos
	PushArrayArray(coordArray, ang);	//1:1 ang
	PushArrayCell(spawnArray, coordArray);		//1 handle_coords
	new Handle:meleeScriptName = CreateArray(BUF_SZ/4);
	PushArrayString(meleeScriptName, name);
	PushArrayCell(spawnArray, meleeScriptName);	//2 melee script name
	
	PushArrayCell(g_hArrayItemsToSpawn, spawnArray);
}

stock SelectWantedItems() {
//	decl spread, spread_ignore;
	decl j, entity, limit[LIMIT_COUNT];
	decl String:item[BUF_SZ], String:classname[BUF_SZ], String:buffer[BUF_SZ];
	for (new i = 0; i < GetArraySize(g_hArrayItemSettings); i++) {
		GetArrayString(g_hArrayItemSettings, i, item, BUF_SZ);
//		spread = UIM_GetSpread(item);
//		spread_ignore = UIM_GetIgnoreSpread(item);
		UIM_GetItemClassname(item, classname);
		for (j = 0; j < LIMIT_COUNT; j++) limit[j] = UIM_GetItemLimit(j, item);

		entity = -1;
		decl Handle:hEntityArray[LIMIT_COUNT];
		/* add all instances of entity to an array according to place */
		for (j = 0; j < LIMIT_COUNT; j++) hEntityArray[j] = CreateArray();
		while ((entity = FindEntityByClassname2(entity, classname)) != -1) {
			if (!IsInBanRange(item, entity) && DoSpecifiersApply(item, entity)) {
				if (SAFEDETECT_IsEntityInStartSaferoom(entity)) PushArrayCell(hEntityArray[LIMIT_START], entity);
				else if (SAFEDETECT_IsEntityInEndSaferoom(entity)) PushArrayCell(hEntityArray[LIMIT_END], entity);
				else PushArrayCell(hEntityArray[LIMIT_MAP], entity);
			}
		}
		/* select until happy */
		decl count;
		for (j = 0; j < LIMIT_COUNT; j++) {
			count = 0;
			while (GetArraySize(hEntityArray[j]) > 0 && count < limit[j]) {
				new randIdx = GetRandomInt(0, GetArraySize(hEntityArray[j]) - 1);
				
				/* special case: melee weapons */
				if (!GetMeleeWeaponNameFromEntity(randIdx, buffer, BUF_SZ)) buffer = "";
				
				AddToWantedList(item, GetArrayCell(hEntityArray[j], randIdx), buffer);
				RemoveFromArray(hEntityArray[j], randIdx);
				count++;
			}
		}
		/* clear mem */
		for (j = 0; j < LIMIT_COUNT; j++) {
			ClearArray(hEntityArray[j]);
			CloseHandle(hEntityArray[j]);
		}
	}
}

stock FindEntityByClassname2(entity, String:classname[]) {
	if (StrContains(classname, "weapon_") == 0) {
		new count = GetEntityCount();
		for (new i = entity + 1; i < count; i++) {
			if (WeaponNameToId(classname) == IdentifyWeapon(i))
				return i;
		}
		return -1;
	}
	else return FindEntityByClassname(entity, classname);
}

stock RemoveAllItems() {
	decl entity;
	decl String:item[BUF_SZ], String:classname[BUF_SZ];
	for (new i = 0; i < GetArraySize(g_hArrayItemSettings); i++) {
		GetArrayString(g_hArrayItemSettings, i, item, BUF_SZ);
		UIM_GetItemClassname(item, classname);
		
		entity = -1;
		while ((entity = FindEntityByClassname2(entity, classname)) != -1) {
			if (DoSpecifiersApply(item, entity)) {
				AcceptEntityInput(entity, "Kill");
			}
		}
	}
}

stock DispatchAllKeyValues(entity, String:item[]) {
	new Handle:hSpawnValues = UIM_GetSpawnValuesArray(item);
	decl Handle:pair;
	decl String:key[BUF_SZ], String:value[BUF_SZ];
	for (new i = 0; i < GetArraySize(hSpawnValues); i++) {
		pair = GetArrayCell(hSpawnValues, i);
		GetArrayString(pair, 0, key, BUF_SZ);
		GetArrayString(pair, 1, value, BUF_SZ);
		DispatchKeyValue(entity, key, value);
	}
}
stock SetAllDataProps(entity, String:item[]) {
	new Handle:hProps = UIM_GetDataSpecifierArray(item);
	decl Handle:pair;
	decl String:key[BUF_SZ], String:value[BUF_SZ];
	for (new i = 0; i < GetArraySize(hProps); i++) {
		pair = GetArrayCell(hProps, i);
		GetArrayString(pair, 0, key, BUF_SZ);
		GetArrayString(pair, 1, value, BUF_SZ);
		SetEntProp(entity, Prop_Data, key, value);
	}
}
stock SetAllSendProps(entity, String:item[]) {
	new Handle:hProps = UIM_GetSendSpecifierArray(item);
	decl Handle:pair;
	decl String:key[BUF_SZ], String:value[BUF_SZ];
	for (new i = 0; i < GetArraySize(hProps); i++) {
		pair = GetArrayCell(hProps, i);
		GetArrayString(pair, 0, key, BUF_SZ);
		GetArrayString(pair, 1, value, BUF_SZ);
		SetEntProp(entity, Prop_Send, key, value);
	}
}

static SpawnWantedItems() {
	decl Handle:spawnArray;
	decl String:classname[BUF_SZ], String:item[BUF_SZ], String:melee[BUF_SZ];
	decl Float:pos[3], Float:ang[3];
	decl entity;
	for (new i = 0; i < GetArraySize(g_hArrayItemsToSpawn); i++) {
		spawnArray = GetArrayCell(g_hArrayItemsToSpawn, i);
		GetSpawnCoords(spawnArray, pos, ang);
		GetItemName(spawnArray, item);
		UIM_GetItemClassname(item, classname);

		if ((entity = CreateEntityByName(classname)) < 0) {
			LogMessage("Tried to spawn %s but failed.", classname);
			continue;
		}
		
		GetMeleeScriptName(spawnArray, melee);
		if (!StrEqual(melee, "")) {
			DispatchKeyValue(entity, "melee_script_name", melee);
		}

		DispatchKeyValueVector(entity, "origin", pos);
		DispatchKeyValueVector(entity, "angles", ang);
 		DispatchAllKeyValues(entity, item);
//		SetAllDataProps(entity, item);
//		SetAllSendProps(entity, item);
		DispatchSpawn(entity);
	}
}

/* * * * * * * * * * * * * * * * * *
 *                                 *
 * LIMIT SETTING AFTER THIS POINT  *
 *                                 *
 * * * * * * * * * * * * * * * * * */

public Action:Cmd_ClearBans(args) {
	if (args) {
		decl String:item[BUF_SZ];
		GetCmdArg(1, item, BUF_SZ);
		UIM_ClearBanRangesArray(item);
	}
	else PrintToServer("Syntax: uim_clearbanranges <item>");
	return Plugin_Handled;
}

public Action:Cmd_Limit(args) {
	if (args < 4) {
		PrintToServer("Syntax: uim_limit <item name> <startsaferoom limit> <map limit> <endsaferoom limit>");
		return Plugin_Handled;
	}

	decl String:item[BUF_SZ];
	GetCmdArg(1, item, BUF_SZ);

	decl String:buffer[BUF_SZ];
	for (new i = 2; i <= 4; i++) {
		GetCmdArg(i, buffer, BUF_SZ);
		UIM_SetItemLimit(i - 2, item, StringToInt(buffer));
	}

	return Plugin_Handled;
}

public LimitConVarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
	decl String:cvarname[BUF_SZ], String:item[BUF_SZ];
	GetConVarName(cvar, cvarname, BUF_SZ);
	GetTrieString(g_hTrieItemNameByCvarName, cvarname, item, BUF_SZ);
	if (cvarname[0] == 's') {	//start saferoom
		UIM_SetItemLimit(LIMIT_START, item, StringToInt(newValue));
	} else
	if (cvarname[0] == 'm') {	//in map
		UIM_SetItemLimit(LIMIT_MAP, item, StringToInt(newValue));
	} else
	if (cvarname[0] == 'e') {	//end saferoom
		UIM_SetItemLimit(LIMIT_END, item, StringToInt(newValue));
	}
}

public Action:Cmd_Limit_CreateCvar(args) {
	if (args != 4) {
		PrintToServer("Syntax: uim_limit_createcvar <name for starting saferoom cvar> <name for map cvar> <name for end saferoom cvar> ; use @* if you don't want one or more of them to be cvar'd. Note that \" s_\", \"m_\" or \"e_\" will be automatically prefixed to the name, so you'll have to add that when you change the cvar.");
		return Plugin_Handled;
	}

	decl String:itemName[BUF_SZ], String:cvarName[BUF_SZ];
	GetCmdArg(1, itemName, BUF_SZ);

	for (new i = 2; i <= args; i++) {
		GetCmdArg(i, cvarName, BUF_SZ);
		if (cvarName[0] != '@') {
			new String:buffer[BUF_SZ];
			strcopy(buffer, BUF_SZ, cvarName);

			if (i == 2)	cvarName[0] = 's'; else
			if (i == 3)	cvarName[0] = 'm'; else
			if (i == 4)	cvarName[0] = 'e'; 
			cvarName[1] = '_';
			cvarName[2] = '\0';

			StrCat(cvarName, BUF_SZ, buffer);
			HookConVarChange(CreateConVar(cvarName, "", "", FCVAR_PLUGIN), LimitConVarChanged);
			if (!SetTrieString(g_hTrieItemNameByCvarName, itemName, cvarName, false))
				PrintToServer("Tried to create a limit's cvar when one already exists.");
		}
	}
	return Plugin_Handled;
}

public Action:Cmd_AddRule(args) {
	if (!args) return BadSyntax(SYNTAX_RULE_UNDEF);
	
	decl String:rule[BUF_SZ], String:item[BUF_SZ];
	GetCmdArg(1, rule, BUF_SZ);		//is used as buffer after rule type is checked
	GetCmdArg(2, item, BUF_SZ);

	if (rule[0] == 'b') {	//ban - ban <item> <minflow> <maxflow>
		if (args < 4) return BadSyntax(SYNTAX_RULE_BAN);

		decl Float:array[2];
		GetCmdArg(3, rule, BUF_SZ);
		array[0] = StringToFloat(rule);
		GetCmdArg(4, rule, BUF_SZ);
		array[1] = StringToFloat(rule);
		UIM_AddBanRange(item, array);
	}
/*	else if (rule[2] == 'r') {	//spread - spread <item> <mindist> <maxdist>
		if (args < 4) return BadSyntax(SYNTAX_RULE_SPREAD);

		GetCmdArg(3, rule, BUF_SZ);
		UIM_SetSpread(item, StringToInt(rule));
		GetCmdArg(4, rule, BUF_SZ);
		UIM_SetIgnoreSpread(item, StringToInt(rule));
	} */
	else if (rule[0] == 'k'){	//keyvalue - keyvalue <item> <key> <value>
		if (args != 4) return BadSyntax(SYNTAX_RULE_KEY);
		decl String:key[BUF_SZ], String:value[BUF_SZ];
		GetCmdArg(3, key, BUF_SZ);
		GetCmdArg(4, value, BUF_SZ);
		
		UIM_AddSpawnKeyValue(item, key, value);
	}
	else {	//specifier
		if (args < 3) return BadSyntax(SYNTAX_RULE_SPEC_UNDEF);

		decl String:specifier[BUF_SZ];
		GetCmdArg(3, specifier, BUF_SZ);
		if (specifier[0] == 'c') {	//classname - specifier <item> classname <classname>
			if (args != 4) return BadSyntax(SYNTAX_RULE_SPEC_CLASS);
			
			decl String:classname[BUF_SZ], Handle:hArrayItem;
			if (!GetTrieValue(g_hTrieItemSettings, item, hArrayItem))
				SetTrieValue(g_hTrieItemSettings, item, (hArrayItem = UIM_CreateItemArray()));
			
			GetCmdArg(4, classname, BUF_SZ);
			UIM_SetItemClassname(item, classname);
		}
		else if (specifier[5] == 'd') {	//prop_data - specifier <item> prop_data <key> <value>
			if (args < 5) return BadSyntax(SYNTAX_RULE_SPEC_DATA);
			
			decl String:key[BUF_SZ], String:value[BUF_SZ];
			GetCmdArg(4, key, BUF_SZ);
			GetCmdArg(5, value, BUF_SZ);
			UIM_AddDataSpecifier(item, key, value);
		}
		else {	//prop_send - specifier <item> prop_send <key> <value>
			if (args < 5) return BadSyntax(SYNTAX_RULE_SPEC_SEND);
			
			decl String:key[BUF_SZ], String:value[BUF_SZ];
			GetCmdArg(4, key, BUF_SZ);
			GetCmdArg(5, value, BUF_SZ);
			UIM_AddSendSpecifier(item, key, value);
		}
	}
	return Plugin_Handled;
}

stock Handle:UIM_CreateItemArray() {
	new Handle:itemArray = CreateArray();
	PushArrayCell(itemArray, -1);				//0	start_limit
	PushArrayCell(itemArray, -1);				//1	map_limit
	PushArrayCell(itemArray, -1);				//2	end_limit
	PushArrayCell(itemArray, CreateArray(2));	//3	handle_data_specifiers
	PushArrayCell(itemArray, CreateArray(2));	//4	handle_send_specifiers
	PushArrayCell(itemArray, -1);				//5	spread_dist
	PushArrayCell(itemArray, CreateArray(2));	//6	handle_ban_ranges

	new Handle:classnameArray = CreateArray(BUF_SZ/4);
	PushArrayString(classnameArray, "");			//
	PushArrayCell(itemArray, classnameArray);	//7	handle_classname

	PushArrayCell(itemArray, -1);				//8 spread_ignore_dist
	PushArrayCell(itemArray, CreateArray());	//9 key_values_dispatched

	return itemArray;
}
stock Handle:UIM_GetItemArray(String:item[]) {	//if it doesnt exist, the array is created
	decl Handle:itemArray;
	if (!GetTrieValue(g_hTrieItemSettings, item, itemArray)) {
		SetTrieValue(g_hTrieItemSettings, item, itemArray = UIM_CreateItemArray(), false);
		UIM_SetItemClassname(item, item);
		PushArrayString(g_hArrayItemSettings, item);
	}
	return itemArray;
}
stock Handle:UIM_GetBanRangesArray(String:item[]) return GetArrayCell(UIM_GetItemArray(item), 6);
stock Handle:UIM_GetDataSpecifierArray(String:item[]) return GetArrayCell(UIM_GetItemArray(item), 3);
stock Handle:UIM_GetSendSpecifierArray(String:item[]) return GetArrayCell(UIM_GetItemArray(item), 4);
stock Handle:UIM_GetSpawnValuesArray(String:item[]) return GetArrayCell(UIM_GetItemArray(item), 9);
stock UIM_ClearBanRangesArray(String:item[]) ClearArray(UIM_GetBanRangesArray(item));

stock UIM_GetSpread(String:item[]) return GetArrayCell(UIM_GetItemArray(item), 6);
stock UIM_SetSpread(String:item[], spread) SetArrayCell(UIM_GetItemArray(item), 6, spread);

stock UIM_GetIgnoreSpread(String:item[]) return GetArrayCell(UIM_GetItemArray(item), 8);
stock UIM_SetIgnoreSpread(String:item[], spread) SetArrayCell(UIM_GetItemArray(item), 8, spread);

stock UIM_AddBanRange(String:item[], Float:array[]) PushArrayArray(UIM_GetBanRangesArray(item), array);

stock UIM_GetItemLimit(place, String:item[]) return GetArrayCell(UIM_GetItemArray(item), place);
stock UIM_SetItemLimit(place, String:item[], limit) {
	SetArrayCell(UIM_GetItemArray(item), place, limit);
}

stock UIM_GetItemClassname(String:item[], String:classname[]) GetArrayString(GetArrayCell(UIM_GetItemArray(item), 7), 0, classname, BUF_SZ);
stock UIM_SetItemClassname(String:item[], String:classname[]) {
	SetArrayString(GetArrayCell(UIM_GetItemArray(item), 7), 0, classname);
}

stock UIM_AddDataSpecifier(String:item[], String:key[], String:value[]) {
	new Handle:entry = CreateArray(BUF_SZ/4);
	PushArrayString(entry, key);
	PushArrayString(entry, value);

	PushArrayCell(UIM_GetDataSpecifierArray(item), entry);
}
stock UIM_AddSendSpecifier(String:item[], String:key[], String:value[]) {
	new Handle:entry = CreateArray(BUF_SZ/4);
	PushArrayString(entry, key);
	PushArrayString(entry, value);

	PushArrayCell(UIM_GetSendSpecifierArray(item), entry);
}
stock UIM_AddSpawnKeyValue(String:item[], String:key[], String:value[]) {
	new Handle:entry = CreateArray(BUF_SZ/4);
	PushArrayString(entry, key);
	PushArrayString(entry, value);

	PushArrayCell(UIM_GetSpawnValuesArray(item), entry);
}
stock bool:IsInBanRange(String:item[], entity) {
	decl Float:pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	new Float:flowPercent = L4D2Direct_GetTerrorNavAreaFlow(L4D2Direct_GetTerrorNavArea(pos))/L4D2Direct_GetMapMaxFlowDistance();

	decl flowLimit[2];
	new Handle:banRanges = UIM_GetBanRangesArray(item);
	for (new i = 0; i < GetArraySize(banRanges); i++) {
		GetArrayArray(banRanges, i, flowLimit);
		if (flowPercent >= float(flowLimit[0]) && flowPercent <= float(flowLimit[1])) return true;
	}

	return false;
}
stock bool:DoSpecifiersApply(String:item[], entity) {
	new Handle:hSpecifierList = UIM_GetDataSpecifierArray(item);
	decl Handle:specifier;
	decl i, String:prop[BUF_SZ], String:value1[BUF_SZ], String:value2[BUF_SZ];
	for (i = 0; i < GetArraySize(hSpecifierList); i++) {
		specifier = GetArrayCell(hSpecifierList, i);
		GetArrayString(specifier, 0, prop, BUF_SZ);
		GetArrayString(specifier, 1, value1, BUF_SZ);
		GetEntPropString(entity, Prop_Data, prop, value2, BUF_SZ);
		if (!StrEqual(value1, value2)) return false;
	}
	hSpecifierList = UIM_GetSendSpecifierArray(item);
	for (i = 0; i < GetArraySize(hSpecifierList); i++) {
		specifier = GetArrayCell(hSpecifierList, i);
		GetArrayString(specifier, 0, prop, BUF_SZ);
		GetArrayString(specifier, 1, value1, BUF_SZ);
		GetEntPropString(entity, Prop_Send, prop, value2, BUF_SZ);
		if (!StrEqual(value1, value2)) return false;
	}
	return true;
}

stock DebugMsg(const String:format[], any:...) {
	#if defined DEBUG
		decl String:output[256];
		VFormat(output, sizeof(output), format, 2);
		PrintToServer(output);
		LogMessage(output);
	#endif
}

/* syntax reports */
stock Action:BadSyntax(type) {
	switch (type) {
		case SYNTAX_RULE_BAN: {
			PrintToServer("Syntax: uim_addrule ban <item> <minflow> <maxflow>");
		}
		case SYNTAX_RULE_SPREAD: {
			PrintToServer("Syntax: uim_addrule spread <item> <mindist> <maxdist>");
		}
		case SYNTAX_RULE_SPEC_CLASS: {
			PrintToServer("Syntax: uim_addrule specifier <item> classname <classname>");
		}
		case SYNTAX_RULE_SPEC_DATA: {
			PrintToServer("Syntax: uim_addrule specifier <item> prop_data <key> <value>");
		}
		case SYNTAX_RULE_SPEC_SEND: {
			PrintToServer("Syntax: uim_addrule specifier <item> prop_send <key> <value>");			
		}
		case SYNTAX_RULE_UNDEF: {
			PrintToServer("Possible syntaxes:");
			for (new i = SYNTAX_RULE_BAN; i < SYNTAX_RULE_UNDEF; i++) BadSyntax(i);
		}
		case SYNTAX_RULE_KEY: {
			PrintToServer("Syntax: uim_addrule keyvalue <item> <key> <value>");
		}
		case SYNTAX_RULE_SPEC_UNDEF: {
			PrintToServer("Possible specifier syntaxes:");
			for (new i = SYNTAX_RULE_SPEC_CLASS; i < SYNTAX_RULE_SPEC_UNDEF; i++) BadSyntax(i);
		}
	}
	return Plugin_Handled;
}
