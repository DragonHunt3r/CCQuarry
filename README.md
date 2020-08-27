# CCQuarry
A simple ComputerCraft quarry in LUA

## Startup
Download all modules and run `quarry` to start the application. Then enter length, width and depth.

## Features
* Application will automatically restart after server loads (requires application to be called "quarry")
* Quarry size is configurable
* Turtle fuels from inventory above start location
* Turtle drops items in inventory behind start location
* On failure to move, break block etc the application will retry multiple times. If it is still unsuccessful it will quit the program. A simple "quarry" command will restart the application.

## TODO
* More debugging messages
* Optimize new layer start (without going back to (0, y, 0))
* Create program to download all required modules for you
* General code cleanup
