# L4D2 Eight Player Co-op

A Windows setup pack for **you and seven friends on the survivor team** in Campaign, Realism, or Survival. It includes a compiled SourceMod configuration/diagnostic plugin, its source, hosting profiles, and a backup-aware installer. Four survivors remain the minimum; MultiSlots creates additional survivors as people join, up to eight.

**This is an integration pack, not a standalone Workshop mod.** Install the dependencies below on the host first. Valve official servers cannot run this pack. An eight-slot lobby UI and an eight-player server are separate requirements. In-game testing with eight clients is still required; compilation alone does not establish gameplay compatibility.

## 1. Install host dependencies

Close the game/server. Install each project's current Windows build into the host's inner `left4dead2` folder (the folder containing `gameinfo.txt`), following its own instructions:

1. [Metamod:Source](https://www.sourcemm.net/downloads.php) and [SourceMod](https://www.sourcemod.net/downloads.php).
2. [L4DToolZ by lakwsh](https://github.com/lakwsh/l4dtoolz/releases): extract into `left4dead2/addons` as its README specifies. This unlocks the human player cap. Do not install two different L4DToolZ builds.
3. [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696): install its plugin and supporting gamedata/extensions as supplied.
4. [CreateSurvivorBot](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_CreateSurvivorBot): install the plugin and all supporting files supplied by that project.
5. [MultiSlots by Harry](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): install its compiled plugin and translations, plus any supporting files supplied upstream. Multi Colors is a compile-time requirement if you build MultiSlots yourself.

Third-party binaries are not bundled or relicensed by this repository. Use the linked publishers' releases. Avoid combining MultiSlots with ABM, SuperVersus, or another survivor-count manager. The installer checks key plugin files; it cannot prove that extensions or gamedata load successfully.

## 2. Install this pack

From PowerShell in this repository, substitute your actual installation path:

```powershell
.\scripts\Install.ps1 -GameDirectory 'C:\Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2\left4dead2' -Hosting Local -WhatIf
.\scripts\Install.ps1 -GameDirectory 'C:\Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2\left4dead2' -Hosting Local
```

The installer copies this pack and appends one `exec` line to `cfg/listenserver.cfg` (Local) or `cfg/server.cfg` (Dedicated). Existing files are backed up under `left4dead2/eight-player-backups/<unique-id>`. It does not install third-party dependencies. Installing again does not duplicate the activation line.

## 3. Play together

### Same lobby, hosted from the game

The lobby creator needs [8 slots lobby fixed](https://steamcommunity.com/sharedfiles/filedetails/?id=2754956355) and the Workshop item's listed required addons. Follow the item's current availability/instructions in Steam; this pack does not include its files. Everyone else normally needs only the game and any custom campaign you choose.

1. Install with `-Hosting Local`.
2. Add `-insecure` to the host game's Steam launch options for local SourceMod hosting. Remove it when returning to normal secure online play.
3. Restart L4D2, create a Campaign lobby, and select **Local Server**. Confirm the lobby actually shows eight slots before inviting everyone.
4. Invite up to seven friends and start the campaign. If someone lands in spectators, they can type `!join` in chat.
5. Type `!eightplayers` to inspect the configured limits.

Local/listen-server SourceMod hosting is less reliable than a dedicated server and is not officially supported by SourceMod. If the Workshop lobby addon is unavailable or local hosting fails, use the dedicated route below; it gets eight players into the same game without requiring an eight-slot pregame lobby.

### Dedicated server, same game via direct connection

Install the dependencies into your L4D2 dedicated server and run the installer with `-Hosting Dedicated`. Start the server with, for example:

```text
srcds.exe -console -game left4dead2 +map c1m1_hotel +mp_gamemode coop
```

Each player opens the developer console and runs `connect SERVER_IP:27015`. For internet hosting, allow the server through the host firewall and forward the server's UDP port (default 27015) when behind a router. LAN players use the host's LAN IP.

The dedicated profile deliberately removes lobby reservation so players five through eight can join directly. It **does not accept pregame lobby matchmaking**. Do not use it for the local-lobby workflow. Neither profile increases tickrate or disables Steam authentication. Eight humans fit within the engine's default client allocation, so this pack does not set `sv_setmax` to eight (that variable has a different purpose).

## Verify and troubleshoot

In the host/server console:

```text
plugin_print
meta list
sm plugins list
sm_eightplayers
```

L4DToolZ must be loaded, and SourceMod must show Left4DHooks, CreateSurvivorBot, MultiSlots, and Eight Player Co-op Setup running without errors. `sm_eightplayers` should report `sv_maxplayers = 8`, `sv_visiblemaxplayers = 8`, minimum survivors 4, maximum survivors 8. Missing values mean a dependency did not load. Check `addons/sourcemod/logs/errors_*.log` for gamedata or extension failures.

If the fifth player is refused, check L4DToolZ and the selected profile. If players can connect but remain spectators, check MultiSlots and its dependencies, then try `!join`. A four-slot lobby means the client lobby addon is missing or conflicting; changing server cvars does not change that UI.

Before calling a session ready, test eight simultaneous humans, a ninth being refused, late join, disconnect/rejoin, idle/takeover, death/respawn, map transition, restart vote, and a finale. Some campaigns and game systems assume four survivors; extra-player HUD, rescue, defibrillator, and finale fixes may be needed. Consult the [maintainer's compatibility guide](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Game/L4D2/8%2B_Survivors_In_Coop) for those optional fixes. Eight unique survivor characters are not guaranteed by this pack.

## Build from source

The included plugin uses only SourceMod's standard includes:

```powershell
.\scripts\Build.ps1 -SourceModScripting 'C:\sourcemod\addons\sourcemod\scripting'
```

Validated with SourceMod 1.12.0-git7259. The output is `left4dead2/addons/sourcemod/plugins/l4d2_eight_player.smx`. Its settings apply after generated plugin configs load, and only in stock coop, realism, and survival modes. Other modes/mutations are outside this pack's scope; use a separate server installation for them because the hosting profiles still set the overall connection limit.

## Remove

Close the host. Remove `l4d2_eight_player.smx` and the `exec eight_players_*.cfg` line added to your hosting config, then restart. Restore any replaced files from the installer backup if necessary. Remove the two `eight_players_*.cfg` files and the source file if unwanted. Dependencies and the Workshop lobby addon are managed separately; disable/uninstall those separately to restore vanilla behavior.
