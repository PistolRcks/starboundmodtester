# starboundmodtester
## Intro
Starbound Mod Tester is a simple, portable and effective way for Starbound mod developers to make quick changes to mods and easily test them out.

## Usage
### Basic
Starbound Mod Tester (or SMT, as I will be calling it from now on) can be run with absolutely no arguments, as follows:
> ./sbmodtester.sh

This causes SMT to use the folder named `testing` in the directory SMT is in, builds a mod based on that, and runs Starbound.

Obviously, you may not want to be using the `testing` folder every time you want to test mods. In that case, define the names of the folders in your current directory and run SMT.
> ./sbmodtester.sh foo

This can also be run with multiple folders. SMT interprets and builds each folder from left to right.
> ./sbmodtester.sh foo1 foo2 foo3

Note that if a folder doesn't exist, SMT will stop the entire build operation and clean up all folders.

### Arguments
SMT takes optional arguments before build targets. All arguments are as follows:
#### -h or --help
Shows a simple help dialogue.
#### -l or --literal
Uses literal folder locations instead of folder names. Take, for example, this command.
> ./sbmodtester.sh fooA

This will look for the folder `fooA` in the current folder of SMT (`$PWD`). When using literal naming, folders can be used from anywhere, ignoring SMT's position. So the original command changes to:
> ./sbmodtester.sh --literal /home/example/path-to-folder/fooA

Both commands will output the same result, assuming that SMT is placed in `/home/example/path-to-folder/`. The advantage to using literal naming is flexibility. For example, you could use a pre-defined variable, or a folder outside of SMT's location, or multiple folders within one folder.



## Extra Remarks
This version is being built for the intent of being run on Linux with the bash shell. Anyone who wishes to make a Windows/macOS (It may work with minimal edits on macOS, seeing as it also uses the bash shell) branch may do so, as I have no knowledge or intention of doing so.

NOTE: The mod does NOT load Starbound through Steam, so all Workshop mods will not be loaded. However, this does allow for usage on platforms other than Steam, such as GOG.
