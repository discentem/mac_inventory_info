# !/usr/bin/python

# Borrowed from https://github.com/erikberglund/Scripts/blob/master/snippets/macos_hardware.md # noqa

import subprocess
import Quartz
from math import sqrt

# Get online display data
(online_err, displays, num_displays) = Quartz.CGGetOnlineDisplayList(2, None, None)  # noqa

# Loop through all online displays
for display in displays:

    # Make sure we use the built in display
    if (Quartz.CGDisplayIsBuiltin(display)):

        # Get size of display in mm (returns an NSSize object)
        size = Quartz.CGDisplayScreenSize(display)

        # Divide size by 25.4 to get inches
        # Calculate diagonal inches using square root of height^2 + width^2
        inch = round(sqrt(pow((size.height / 25.4), 2.0) + pow((size.width / 25.4), 2.0)), 1)  # noqa
        inch = str(inch)
        print(inch)
