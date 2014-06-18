##Description##

Assignment for third year class to create a simple chemical reaction simulator.

##Build instructions##

Program was compiled using GNUstep/GCC, running on Ubuntu 12.04. Compilation command was:
**gcc `gnustep-config --objc-flags` Reader.m Simulation.m -o main -lgnustep-base -lobjc -lbsd**

BSD library is linked in for use of arc4random.

Note that solitary warning may occur: **warning: no return statement in function returning nonvoid [-Wreturn-type]**
Upon examination, it appears that this is a bug in the GNUstep compiler itself, and should be ignored.

##Execution##

After compilation, run with **./main [input script filepath] [output script filepath]**
For example: **./main /home/bob/Documents/CSLP/doc/cascade.txt /home/bob/Documents/CSLP/doc/cascade.csv**
Note that file paths must be absolute.