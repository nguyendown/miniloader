#!/bin/bash

gendef=$(gendef - "C:/Windows/System32/${1}.dll")

awk -v module="${1}" '
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
' <<< "$gendef"
