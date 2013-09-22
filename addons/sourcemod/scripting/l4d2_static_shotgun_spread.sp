#pragma semicolon 1

#include <code_patcher>

new Handle:hRing1BulletsCvar;
new Handle:hRing1FactorCvar;

new g_BulletOffsets[] = { 0x11, 0x1c, 0x29, 0x3d };
new g_FactorOffset = 0x2e;

static HotPatchBullets(nBullets)
{
	if (IsPlatformWindows())
	{
		LogMessage("Static shotgun spread not supported on windows");
		return;
	}

	new Address:addr = GetPatchAddress("sgspread");

	StoreToAddress(addr + Address:g_BulletOffsets[0], nBullets + 1, NumberType_Int8);
	StoreToAddress(addr + Address:g_BulletOffsets[1], nBullets + 2, NumberType_Int8);
	StoreToAddress(addr + Address:g_BulletOffsets[2], nBullets + 2, NumberType_Int8);

	new Float:degree = 360.0 / (2.0*float(nBullets));

	StoreToAddress(addr + Address:g_BulletOffsets[3], _:degree, NumberType_Int32);
}

static HotPatchFactor(factor)
{
	if (IsPlatformWindows())
	{
		LogMessage("Static shotgun spread not supported on windows");
		return;
	}

	new Address:addr = GetPatchAddress("sgspread");

	StoreToAddress(addr + Address:g_FactorOffset, factor, NumberType_Int32);
}

public OnPluginStart()
{
	hRing1BulletsCvar = CreateConVar("sgspread_ring1_bullets", "3");
	hRing1FactorCvar = CreateConVar("sgspread_ring1_factor", "2");

	HookConVarChange(hRing1BulletsCvar, OnRing1BulletsChange);
	HookConVarChange(hRing1FactorCvar, OnRing1FactorChange);
}

public OnRing1BulletsChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new nBullets = StringToInt(newVal);

	if (IsPatchApplied("sgspread"))
		HotPatchBullets(nBullets);
}

public OnRing1FactorChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new factor = StringToInt(newVal);

	if (IsPatchApplied("sgspread"))
		HotPatchFactor(factor);
}

public OnPatchApplied(const String:name[])
{
	if (StrEqual("sgspread", name))
	{
		HotPatchBullets(GetConVarInt(hRing1BulletsCvar));
		HotPatchFactor(GetConVarInt(hRing1FactorCvar));
	}
}
