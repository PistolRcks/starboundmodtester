# starboundmodtester
## Intro
Starbound Mod Tester is a simple, portable and effective way for Starbound mod developers to make quick changes to mods and easily test them out, and also a utility with non-development uses.

## Usage
### Basic
Starbound Mod Tester (or SMT, as I will be calling it from now on) can be run with absolutely no arguments, as follows:

`./sbmodtester.sh`

This causes SMT to use the folder named `testing` in the directory SMT is in, builds a mod based on that, and runs Starbound.

Obviously, you may not want to be using the `testing` folder every time you want to test mods. In that case, define the names of the folders in your current directory and run SMT.

`./sbmodtester.sh foo`

This can also be run with multiple folders. SMT interprets and builds each folder from left to right.

`./sbmodtester.sh foo1 foo2 foo3`

Note that if a folder doesn't exist, SMT will stop the entire build operation and clean up the `mod` folder in the specified Starbound root directory

### Arguments
SMT takes optional arguments before build targets. All arguments are as follows:
#### -c or --cleanup
Forces a cleanup all of `*.tmp.pak` files created by SMT in the selected Starbound's mod folder.
#### --force-starbound [STARBOUND_ROOT_DIR]
Forces the Starbound directory to whatever comes after it. If you use `linux_default`, it will use the default Linux Steam Starbound installation directory.
#### --force-steam [STEAM_ROOT_DIR]
Forces the Steam directory to whatever comes after it. Similarly to `--force-starbound`, if you use `linux_default`, it will use the default Linux Steam installation directory.
#### -h or --help
Shows a simple help dialogue.
#### -l or --literal (Deprecated in 0.5. Literal naming is automatic now.)
Uses literal folder locations instead of folder names. Take, for example, this command.

`./sbmodtester.sh fooA`

This will look for the folder `fooA` in the current folder of SMT (`$PWD`). When using literal naming, folders can be used from anywhere, ignoring SMT's position. So the original command changes to:

`./sbmodtester.sh --literal /home/example/path-to-folder/fooA`

Both commands will output the same result, assuming that SMT is placed in `/home/example/path-to-folder/`. The advantage to using literal naming is flexibility. For example, you could use a pre-defined variable, or a folder outside of SMT's location, or multiple folders within one folder.
#### -nb or --no-build
Skips the build phase and goes straight to starting Starbound.
#### -nc or --no-cleanup
Turns off auto mod cleanup after Starbound is closed.
#### -nv or --no-version-check
As of update 0.5.1, SMT will automatically check for updates after every time it is run (provided the user is connected to the internet). This argument stops this from happening.
#### --server
Starts Starbound in a dedicated server. "--no-cleanup" is automatically applied when this is on.
#### -u or --update
Checks the version and/or updates SMT from Github.
#### -v or --version
Returns the version of SMT.
#### -w or --enable-workshop-mods
Copys over Steam Workshop mods to your Starbound mod folder. Note that this is only applicable if you have Starbound on Steam. However, if you are using a non-Steam Starbound and wish to use Workshop mods, this will also work.

## Extra Remarks
### Non-Linux Versions
This version is being built for the intent of being run on Linux with the bash shell. Anyone who wishes to make a Windows (macOS support is on indefinite hold) branch may do so, as I have no knowledge or intention of doing so.

### Changing Folder Defaults
If want to use a different Steam folder and/or Starbound folder by default, you can change the STEAM_DIR and STARBOUND_DIR variables at the beginning of the script to the root folder of each respective location. The location doesn't require slash escapes, and might actually break if you use them (e.g. `STEAM_DIR="/games/path to games/steam games"`, not `STEAM_DIR="/games/path\ to\ games/steam\ games"`). Oh yeah, and keep the quotes. They're needed so everything doesn't break (thanks bug #2).

### Final Note
The mod does NOT load Starbound through Steam, so all Workshop mods will only be loaded if you use `-w` or `--enable-workshop-mods`. However, this does allow for usage on platforms other than Steam, such as GOG.
