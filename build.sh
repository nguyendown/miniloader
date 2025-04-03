#!/bin/bash

set -o

module=$1
dll_load=$2

if [ -z "$dll_load" ]; then
    echo "Usage: ./build.sh version your.dll"
    exit 1
fi

gendef=$(gendef - "C:/Windows/System32/${module}.dll")

awk -v module="${module}" '
  /EXPORTS/ {
    print $0
    exports_section = 1
    next
  }

  exports_section {
    # Skip lines that are already forwarded
    if ($0 ~ /=/) {
      print $0
      next
    }
    printf "%s = C:/Windows/System32/%s.%s\n", $0, module, $0
    next
  }

  {
    print $0
  }
' <<< "$gendef" | tee "${module}.def"

dlltool --input-def "${module}.def" --output-lib "${module}.lib"

cmake -G "MinGW Makefiles" -B ./build -DMODULE="$module" -DDLL_LOAD="$dll_load"
cmake --build ./build --config Release
