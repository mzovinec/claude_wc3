# RTS Ask Sound (Windows)
# Plays a "what do you need?" voice line when Claude asks for user input

$SoundsDir = Join-Path $PSScriptRoot "rtssounds"
$RaceFile = Join-Path $env:TEMP "rts_current_race.txt"
$ConfigFile = Join-Path $PSScriptRoot "rts_config.json"

# Read the race chosen by the accept hook, or pick one from config
if (Test-Path $RaceFile) {
    $Race = (Get-Content $RaceFile -Raw).Trim()
} else {
    # Two-level weighted selection: game first, then race
    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $gameTotal = 0
    foreach ($g in $config.games.PSObject.Properties) {
        if ($g.Value.weight -gt 0) { $gameTotal += $g.Value.weight }
    }
    if ($gameTotal -eq 0) { exit }

    $roll = Get-Random -Minimum 1 -Maximum ($gameTotal + 1)
    $cumulative = 0
    $game = $null
    foreach ($g in $config.games.PSObject.Properties) {
        if ($g.Value.weight -le 0) { continue }
        $cumulative += $g.Value.weight
        if ($roll -le $cumulative) { $game = $g.Value; break }
    }

    $raceTotal = 0
    foreach ($r in $game.races.PSObject.Properties) { $raceTotal += $r.Value }
    if ($raceTotal -eq 0) { exit }

    $roll = Get-Random -Minimum 1 -Maximum ($raceTotal + 1)
    $cumulative = 0
    $Race = ($game.races.PSObject.Properties | Select-Object -First 1).Name
    foreach ($r in $game.races.PSObject.Properties) {
        $cumulative += $r.Value
        if ($roll -le $cumulative) { $Race = $r.Name; break }
    }
}

# Play a random ask sound from that race
$Dir = Join-Path $SoundsDir "$Race\ask"
$Files = Get-ChildItem -Path "$Dir\*" -Include *.wav, *.mp3 -File -ErrorAction SilentlyContinue
if ($Files.Count -gt 0) {
    $Sound = ($Files | Get-Random).FullName
    & (Join-Path $PSScriptRoot "rts_play_win.ps1") $Sound
}
