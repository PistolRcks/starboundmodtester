#!/bin/bash
STARBOUND_DIR=$HOME/.local/share/Steam/steamapps/common/Starbound
SELECT_DIR=$1
if [ -d "$PWD/testing" ]
    then 
        cd $STARBOUND_DIR/linux
        rm -rf $STARBOUND_DIR/mods/testing.tmp.pak
        ./asset_packer $OLDPWD/testing $STARBOUND_DIR/mods/testing.tmp.pak
        exec $STARBOUND_DIR/linux/run-client.sh
elif [ -d "$SELECT_DIR" ] 
    then
        cd $STARBOUND_DIR/linux
        rm -rf $STARBOUND_DIR/mods/$SELECT_DIR.tmp.pak
        ./asset_packer $OLDPWD/$SELECT_DIR $STARBOUND_DIR/mods/$SELECT_DIR.tmp.pak
        exec $STARBOUND_DIR/linux/run-client.sh
elif [ "$1" == "--help" ] || [ "$1" == "-h" ] 
    then
        printf "Welcome to Starbound Mod Tester Version 0.2.1!\r
Usage: ./modtester-0.2.1.sh [TARGET FOLDER NAME or --help or -h]\n
Returning the command with no arguments or with an invalid target folder name will attempt to pack a mod in the current directory with the target directory 'testing' and run Starbound in Steam's directory.\n
Note that the argument specifies the NAME of the folder (i.e. foobar) instead of its location. (i.e. /home/foo/starboundmodding/foobar)\n
Using a directory other than Steam's installation folder? Just use 'export' to change the location of 'STARBOUND_DIR' to whatever suits you!\n"
else
    printf "ERROR: Neither child 'testing' directory nor child '$SELECT_DIR' directory found in parent directory '$PWD'.\r
Need help? Use --help or -h.\n"
fi
