#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo =
{
    name = "Eight Player Co-op Setup",
    author = "L4D2-8-Player-Mod contributors",
    description = "Configures and diagnoses an eight-player MultiSlots server",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart()
{
    if (GetEngineVersion() != Engine_Left4Dead2)
        SetFailState("This plugin requires Left 4 Dead 2.");
    RegConsoleCmd("sm_eightplayers", Command_Status, "Check eight-player prerequisites");
}

public void OnConfigsExecuted()
{
    char mode[32];
    FindConVar("mp_gamemode").GetString(mode, sizeof(mode));
    if (!StrEqual(mode, "coop") && !StrEqual(mode, "realism") && !StrEqual(mode, "survival"))
    {
        LogMessage("Eight-player settings skipped for mode: %s", mode);
        return;
    }

    // Apply after MultiSlots' generated config so its default cannot reset the cap.
    SetRequired("sv_maxplayers", 8);
    SetRequired("sv_visiblemaxplayers", 8);
    SetRequired("l4d_multislots_min_survivors", 4);
    SetRequired("l4d_multislots_max_survivors", 8);
    SetRequired("precache_all_survivors", 1);
}

void SetRequired(const char[] name, int value)
{
    ConVar cvar = FindConVar(name);
    if (cvar == null)
    {
        LogError("Missing %s. Install the dependencies listed in README.md.", name);
        return;
    }
    cvar.IntValue = value;
}

public Action Command_Status(int client, int args)
{
    ReplyToCommand(client, "[8 players] Server settings (these do not verify lobby UI or connectivity):");
    Report(client, "sv_maxplayers");
    Report(client, "sv_visiblemaxplayers");
    Report(client, "l4d_multislots_min_survivors");
    Report(client, "l4d_multislots_max_survivors");
    Report(client, "sv_force_unreserved");
    ReplyToCommand(client, "[8 players] Use !join to enter the survivor team through MultiSlots.");
    return Plugin_Handled;
}

void Report(int client, const char[] name)
{
    ConVar cvar = FindConVar(name);
    if (cvar == null)
        ReplyToCommand(client, "  %s: MISSING dependency", name);
    else
        ReplyToCommand(client, "  %s = %d", name, cvar.IntValue);
}
