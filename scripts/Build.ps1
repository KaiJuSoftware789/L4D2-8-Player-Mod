param([Parameter(Mandatory)][string]$SourceModScripting)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$compiler = Join-Path $SourceModScripting 'spcomp.exe'
if (!(Test-Path -LiteralPath $compiler)) { throw "Missing compiler: $compiler" }
$source = Join-Path $repo 'left4dead2/addons/sourcemod/scripting/l4d2_eight_player.sp'
$output = Join-Path $repo 'left4dead2/addons/sourcemod/plugins/l4d2_eight_player.smx'
New-Item -ItemType Directory -Force (Split-Path $output) | Out-Null
& $compiler $source "-i$(Join-Path $SourceModScripting 'include')" "-o$output"
if ($LASTEXITCODE -ne 0) { throw "SourcePawn build failed: $LASTEXITCODE" }
