# WC3 Worker Ask Sound (Windows)
# Plays a "what do you need?" voice line when Claude asks for user input

$SoundsDir = Join-Path $PSScriptRoot "wc3sounds"
$RaceFile = Join-Path $env:TEMP "wc3_current_race.txt"
$ConfigFile = Join-Path $PSScriptRoot "wc3_config.json"

# Read the race chosen by the accept hook, or pick one from config
if (Test-Path $RaceFile) {
    $Race = (Get-Content $RaceFile -Raw).Trim()
} else {
    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $total = 0
    foreach ($prop in $config.races.PSObject.Properties) { $total += $prop.Value }
    $Roll = Get-Random -Minimum 1 -Maximum ($total + 1)
    $cumulative = 0
    $Race = "orc"
    foreach ($prop in $config.races.PSObject.Properties) {
        $cumulative += $prop.Value
        if ($Roll -le $cumulative) { $Race = $prop.Name; break }
    }
}

# Play a random ask sound from that race
$Dir = Join-Path $SoundsDir "$Race\ask"
$Files = Get-ChildItem -Path "$Dir\*" -Include *.wav, *.mp3 -File -ErrorAction SilentlyContinue
if ($Files.Count -gt 0) {
    $Sound = ($Files | Get-Random).FullName
    & (Join-Path $PSScriptRoot "wc3_play_win.ps1") $Sound
}
