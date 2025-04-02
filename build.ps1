$arch = $args[0]
$module = $args[1]
$dllLoad = $args[2]

$modulePath = "C:\Windows\System32\${module}.dll"
$gendef = gendef - "$modulePath"

$outdef = ""
$foundExports = $false

foreach ($line in $gendef) {
    if ($foundExports -and -not $line.Contains("=")) {
        $functionName = $line.Trim()
        $outdef += "$functionName = C:/Windows/System32/$module.$functionName" + "`n"
        continue
    } elseif ($line.StartsWith("EXPORTS")) {
        $foundExports = $true
    }

    $outdef += "$line" + "`n"
}

Write-Output $outdef
Set-Content -Path "$module.def" -Value $outdef

dlltool --input-def "$module.def" --output-lib "$module.lib"

cmake -G "Visual Studio 17 2022" -A "$arch" -B ./build
cmake --build ./build --config Release -DMODULE="$module" -DDLL_LOAD="$dllLoad"
