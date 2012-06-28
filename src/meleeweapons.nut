//Still needs work

function OnRoundStart()
{
        
        
        // We do a roundstart removal of melee weapons, then re-add them.      
	// 0+: Limit to value
        // <0: Set Count only
        weaponsToRemove <- {
            weapon_melee_spawn = 4
        }
        ent <- Entities.First();
        entcnt<-1;
        classname <- ""
        while(ent != null)
        {
                classname = ent.GetClassname()
                //Msg(entcnt+". "+classname+"\n");
                if(classname == "func_playerinfected_clip")
                {
                    //Msg("Killing...\n");
                    DoEntFire("!activator", "kill", "", 0, ent, null);
                } else if (classname in weaponsToRemove)
                {
                    ent.__KeyValueFromInt("count", 1);
                    if(weaponsToRemove[classname] > 0)
                    {
                        //Msg("Found a "+classname+" to keep, "+(weaponsToRemove[classname]-1)+" remain.\n");
                        weaponsToRemove[classname]--
                        
                    }
                    else if(weaponsToRemove[classname] == 0)
                    {
                        //Msg("Removed "+classname+"\n")
                        DoEntFire("!activator", "kill", "", 0, ent, null);
                    }
                }
                ent=Entities.Next(ent);
                entcnt++;
        }
}

function AllowWeaponSpawn( classname )
    {
        new_round_start = 1
        round_start_time = Time()
        mapinfo.IdentifyMap(Entities)
    }

function Update()
{
    if(DirectorOptions.new_round_start == 1 && DirectorOptions.round_start_time < Time()-1)
    {
        DirectorOptions.new_round_start = 0
        OnRoundStart()        
    }

}