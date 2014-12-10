/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <sourcemod>

public Plugin:myinfo =
{
	name = "Mathack Block",
	author = "Sir, Visor",
	description = "Kicks out clients who are potentially attempting to enable mathack",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	CreateTimer(GetRandomFloat(2.5, 3.5), CheckClients, _, TIMER_REPEAT);
}

public Action:CheckClients(Handle:timer)
{
    for (new client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && !IsFakeClient(client))
        {
            if (GetClientTeam(client) > 1)	// Only query clients on survivor or infected team, ignore spectators.
            {
                QueryClientConVar(client, "mat_texture_list", ClientQueryCallback);
            }
        }
    }	
}

public ClientQueryCallback(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
    switch (result)
    {
        case 0:
        {
            new mathax = StringToInt(cvarValue);
            if (mathax > 0)
            {
                decl String:t_name[MAX_NAME_LENGTH], String:t_ip[32], String:t_steamid[32], String:path[256];
                //gets client name
                GetClientName(client,t_name,31);
                //gets steam id
                GetClientAuthString(client,t_steamid,31);
                //checks to see if client is conncted -  also checks to see if client is a bot
                if(IsFakeClient(client)) return;  
                //gets clients ip	
                GetClientIP(client,t_ip,31);
                
                BuildPath(Path_SM, path, 256, "logs/mathack_cheaters.txt");
                LogToFile(path,".:[Name: %s | STEAMID: %s | IP: %s]:.",t_name,t_steamid,t_ip);
                PrintToChatAll("\x04[\x01Mathack Detector\x04] \x03%s \x01has been kicked for using mathack!", t_name);
                KickClient(client, "You have been kicked for using hacks. No rest for the wicked.");
            }
        }
        case 1:
        {
            KickClient(client, "ConVarQuery_NotFound");
        }
        case 2:
        {
            KickClient(client, "ConVarQuery_NotValid");
        }
        case 3:
        {
            KickClient(client, "ConVarQuery_Protected");
        }
    }
}