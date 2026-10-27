[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$GameDirectory,
    [ValidateSet('Local', 'Dedicated')][string]$Hosting = 'Local'
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$game = (Resolve-Path -LiteralPath $GameDirectory).Path
if (!(Test-Path -LiteralPath (Join-Path $game 'gameinfo.txt'))) {
    throw 'Choose the inner left4dead2 folder containing gameinfo.txt.'
}
$required = @(
    'addons/metamod.vdf',
    'addons/sourcemod/plugins/left4dhooks.smx',
    'addons/sourcemod/plugins/l4d_CreateSurvivorBot.smx',
    'addons/sourcemod/plugins/l4dmultislots.smx'
)
foreach ($path in $required) {
    if (!(Test-Path -LiteralPath (Join-Path $game $path))) {
        throw "Install prerequisites first; missing $path. See README.md."
    }
}
$payload = Join-Path $repo 'left4dead2'
if (!(Test-Path -LiteralPath (Join-Path $payload 'addons/sourcemod/plugins/l4d2_eight_player.smx'))) {
    throw 'Compile the plugin with scripts/Build.ps1 first.'
}
$backup = Join-Path $game ("eight-player-backups/" + [guid]::NewGuid().ToString('N'))
foreach ($file in Get-ChildItem -LiteralPath $payload -File -Recurse) {
    $relative = $file.FullName.Substring($payload.Length + 1)
    $target = Join-Path $game $relative
    if ($PSCmdlet.ShouldProcess($target, 'Install eight-player file (back up existing file)')) {
        if (Test-Path -LiteralPath $target) {
            $saved = Join-Path $backup $relative
            New-Item -ItemType Directory -Force (Split-Path $saved) | Out-Null
            Copy-Item -LiteralPath $target -Destination $saved
        }
        New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force
    }
}
$configName = if ($Hosting -eq 'Local') { 'listenserver.cfg' } else { 'server.cfg' }
$config = Join-Path $game "cfg/$configName"
$line = "exec eight_players_$($Hosting.ToLowerInvariant()).cfg"
$content = if (Test-Path -LiteralPath $config) { Get-Content -LiteralPath $config -Raw } else { '' }
if ($content -notmatch "(?m)^\s*$([regex]::Escape($line))\s*$") {
    if ($PSCmdlet.ShouldProcess($config, 'Append profile activation (back up existing config)')) {
        if (Test-Path -LiteralPath $config) {
            New-Item -ItemType Directory -Force (Join-Path $backup 'cfg') | Out-Null
            Copy-Item -LiteralPath $config -Destination (Join-Path $backup "cfg/$configName")
        }
        Add-Content -LiteralPath $config -Value "`r`n$line" -Encoding ascii
    }
}
Write-Output 'Installation processed. Restart the host; run plugin_print, sm plugins list, and sm_eightplayers.'
Write-Output "Existing files, if replaced, were backed up under $backup"
