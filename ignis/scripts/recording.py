#!/usr/bin/env python3
# Obsoleto: la grabación se lanza con OBS desde el botón del centro de control.
# Mantenido por compatibilidad con atajos antiguos de HyprZepyx.

import sys
from ignis import utils

if len(sys.argv) < 2:
    sys.exit(1)

if sys.argv[1] in ("start", "pause", "continue"):
    utils.exec_sh_async("obs")
elif sys.argv[1] == "stop":
    utils.exec_sh_async("pkill -x obs")
