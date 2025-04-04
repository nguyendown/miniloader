$ErrorActionPreference = "Stop"

$arch = $args[0]
$module = $args[1]
$dllLoad = $args[2]

if (-not $dllLoad) {
    throw "Usage: .\build.ps1 64 version your.dll"
}

if ($arch -in "32", "x86", "win32") {
    $platform = "Win32"
    $machine = "X86"
    $target = "x86"
} elseif ($arch -in "64", "x64", "amd64") {
    $platform = "x64"
    $machine = "X64"
    $target = "amd64"
} else {
    throw "Target $arch is not supported"
}

$modulePath = "C:\Windows\System32\$module.dll"

if (-not (Test-Path -Path "$modulePath")) {
    throw "$modulePath does not exist"
}

$vswhere = $(Join-Path "${Env:ProgramFiles(x86)}" "\Microsoft Visual Studio\Installer\vswhere.exe")
$installDir = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$devShell = $(Join-Path "$installDir" "\Common7\Tools\Launch-VsDevShell.ps1")
& $devShell -Arch $target

$dump = dumpbin /EXPORTS "$modulePath"

$outdef = "LIBRARY $module" + "`n"
$outdef += "EXPORTS`n"

$foundExports = $false

foreach ($line in $dump) {
    if (-not $line.Trim()) {
        continue
    }

    if ($foundExports -and -not $line.Contains("=")) {
        if ($line.EndsWith("Summary")) {
            break
        }

        if ($line.Contains("[NONAME]")) {
            continue
        }

        if ($line.Contains("(forwarded to ")) {
            $rep = $line -replace '.* (.+) \(forwarded to (.+)\)', '$1 = $2'
            $outdef += $rep
        } else {
            $functionName = $line -replace ".* ", ""
            $outdef += "$functionName = C:/Windows/System32/$module.$functionName"
        }

        $outdef += "`n"
    } elseif ($line.EndsWith("RVA      name")) {
        $foundExports = $true
    }
}

Write-Output $outdef
Set-Content -Path "$module.def" -Value $outdef

lib /DEF:$module.def /MACHINE:$machine

cmake -G "Visual Studio 17 2022" -A "$platform" -B ./build -DMODULE="$module" -DDLL_LOAD="$dllLoad"
cmake --build ./build --config Release
