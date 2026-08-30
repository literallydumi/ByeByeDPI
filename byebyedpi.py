#!/usr/bin/env python3
"""Entry point wrapper so the project can be run as `python byebyedpi.py`.

All third-party dependencies (pydivert, and the WinDivert driver files
it needs) ship inside the local `libs` folder next to this file, so
nothing needs to be downloaded or pip-installed separately.
"""

import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_LIBS = os.path.join(_HERE, "libs")
if _LIBS not in sys.path:
    sys.path.insert(0, _LIBS)

from byebyedpi.cli import main

if __name__ == "__main__":
    main()
