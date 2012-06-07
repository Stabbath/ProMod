#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
        name = "Weapon Precacher",
        author = "Jacob",
        description = "Precaches the mp5.",
        version = "1.0.0",
        url = "nope"
}
 
public OnPluginStart()
{

        //Precache hidden weapon models
        PrecacheWeaponModels()
}
 
PrecacheWeaponModels()
{
        //Precache weapon models if they're not loaded.
        if (!IsModelPrecached("models/w_models/weapons/w_smg_mp5.mdl")) PrecacheModel("models/w_models/weapons/w_smg_mp5.mdl")
        if (!IsModelPrecached("models/v_models/v_smg_mp5.mdl")) PrecacheModel("models/v_models/v_smg_mp5.mdl")

        //Spawn and delete the hidden weapons,
        new index = CreateEntityByName("weapon_smg_mp5")
        DispatchSpawn(index)
        RemoveEdict(index)
}
