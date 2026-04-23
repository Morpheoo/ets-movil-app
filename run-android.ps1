param(
    [string]$AvdName = "",
    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

function Write-Step([string]$msg) {
    Write-Host "[run-android] $msg"
}

function Get-SdkPath {
    if ($env:ANDROID_HOME -and (Test-Path $env:ANDROID_HOME)) { return $env:ANDROID_HOME }
    if ($env:ANDROID_SDK_ROOT -and (Test-Path $env:ANDROID_SDK_ROOT)) { return $env:ANDROID_SDK_ROOT }

    $localProps = Join-Path $projectRoot "android\local.properties"
    if (Test-Path $localProps) {
        $line = Select-String -Path $localProps -Pattern '^sdk\.dir=' | Select-Object -First 1
        if ($line) {
            $value = $line.Line.Substring("sdk.dir=".Length).Trim()
            $value = $value -replace '\\\\', '\'
            if (Test-Path $value) { return $value }
        }
    }

    $fallback = Join-Path $env:LOCALAPPDATA "Android\Sdk"
    if (Test-Path $fallback) { return $fallback }
    throw "No se encontro Android SDK. Configura ANDROID_HOME o revisa android/local.properties"
}

function Get-RunningEmulatorId([string]$adbExe) {
    $lines = & $adbExe devices
    foreach ($line in $lines) {
        if ($line -match '^(emulator-\d+)\s+device$') {
            return $Matches[1]
        }
    }
    return $null
}

$sdkPath = Get-SdkPath
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath

$emulatorExe = Join-Path $sdkPath "emulator\emulator.exe"
$adbExe = Join-Path $sdkPath "platform-tools\adb.exe"

if (-not (Test-Path $emulatorExe)) { throw "No se encontro emulator.exe en $emulatorExe" }
if (-not (Test-Path $adbExe)) { throw "No se encontro adb.exe en $adbExe" }

$deviceId = Get-RunningEmulatorId $adbExe

if (-not $deviceId) {
    $avds = @(& $emulatorExe -list-avds | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    if (-not $avds -or $avds.Count -eq 0) {
        throw "No hay AVDs creados. Crea uno desde Android Studio > Device Manager."
    }

    if (-not $AvdName) {
        $AvdName = $avds[0]
        Write-Step "Usando AVD por defecto: $AvdName"
    } elseif (-not ($avds -contains $AvdName)) {
        throw "El AVD '$AvdName' no existe. Disponibles: $($avds -join ', ')"
    }

    Write-Step "Iniciando emulador: $AvdName"
    Start-Process -FilePath $emulatorExe -ArgumentList @("-avd", $AvdName)

    Write-Step "Esperando que el emulador aparezca en adb..."
    $timeoutSec = 180
    $sw = [Diagnostics.Stopwatch]::StartNew()
    do {
        Start-Sleep -Seconds 2
        $deviceId = Get-RunningEmulatorId $adbExe
    } while (-not $deviceId -and $sw.Elapsed.TotalSeconds -lt $timeoutSec)

    if (-not $deviceId) {
        throw "Timeout esperando el emulador en adb ($timeoutSec s)."
    }
}

Write-Step "Dispositivo detectado: $deviceId"
Write-Step "Esperando boot completo de Android..."

$bootTimeoutSec = 180
$bootSw = [Diagnostics.Stopwatch]::StartNew()
do {
    Start-Sleep -Seconds 2
    $boot = (& $adbExe -s $deviceId shell getprop sys.boot_completed 2>$null | Out-String).Trim()
} while ($boot -ne "1" -and $bootSw.Elapsed.TotalSeconds -lt $bootTimeoutSec)

if ($boot -ne "1") {
    throw "Timeout esperando boot completo de Android ($bootTimeoutSec s)."
}

if (-not $SkipPubGet) {
    Write-Step "Ejecutando flutter pub get..."
    flutter pub get
}

Write-Step "Corriendo app en $deviceId..."
flutter run -d $deviceId
