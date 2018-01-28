#!/bin/bash
#---TODO---
#Figure out how to get the mods to clean up when done with Starbound
#Graphical interface option

STARBOUND_DIR=$HOME/.local/share/Steam/steamapps/common/Starbound
HELP=""
LITERAL=""
CLEANUP=""
SELECT_DIR=()
TITLE="\033[0;92m[SBMT]\033[0m:"
ERR_HELP="${TITLE} Need help? Use --help or -h."
VER="0.3"

sbbuild () {
    #The real secret sauce -- the mod building script
    if [ "$LITERAL" == "literal" ]
        then
            local LIT_SELECT_DIR=$(basename "$1")
            cd $STARBOUND_DIR/linux
            rm -rf $STARBOUND_DIR/mods/$LIT_SELECT_DIR.tmp.pak
            ./asset_packer $1 $STARBOUND_DIR/mods/$LIT_SELECT_DIR.tmp.pak
            cd $OLDPWD
    else
        cd $STARBOUND_DIR/linux
        rm -rf $STARBOUND_DIR/mods/$1.tmp.pak
        ./asset_packer $OLDPWD/$1 $STARBOUND_DIR/mods/$1.tmp.pak
        cd $OLDPWD
    fi
    if [ "${!#}" == "run" ]
        then
            printf "${TITLE} Last mod '$1' built. Launching Starbound.\n"
            exec $STARBOUND_DIR/linux/run-client.sh
    else
        printf "${TITLE} Mod '$1' built. Continuing.\n"
    fi
}

cleanup () {
    cd $STARBOUND_DIR/mods
    rm -rf *.tmp.pak
    cd $OLDPWD
    printf "${TITLE} All cleaned up! Removed all *.tmp.pak files from your mod folder.\n"
}

showhelp () {
    printf "Welcome to Starbound Mod Tester Version $VER!\r
Usage: ./sbmodtester.sh [ARGUMENTS] [TARGET FOLDER NAME(S)]\n
---ARGUMENTS---
    -c | --cleanup
        Forces a cleanup. This deletes all *.tmp.pak files from Starbound's mod folder.
    -h | --help
        Displays this help message.
    -l | --literal
        Initiates literal mode. Literal mode changes the folder target from its name to its location (See EXTRA NOTES).

---EXTRA NOTES---
Returning the command with no arguments will default to pack a mod in the current directory with the target directory 'testing' and run Starbound in Steam's directory.\n
Note that the argument specifies the NAME of the folder (i.e. foobar) instead of its location (i.e. /home/foo/starboundmodding/foobar). \n
This is cancelled if the argument '--literal' is called. \n
Using a directory other than Steam's installation folder? Just use 'export' to change the location of 'STARBOUND_DIR' to whatever suits you!\n"
}

#Argument parsing
while [[ $# -gt 0 ]]
    do
        case $1 in
            -c | --cleanup )
                cleanup
                CLEANUP="cleanup"
                break
                ;;
            -h | --help )
                showhelp
                HELP="help"
                break
                ;;
            -l | --literal )
                LITERAL="literal"
                shift
                ;;
            * )
                SELECT_DIR+=("$1")
                shift
                ;;
        esac
done

#Save the number of directories chosen
NUMDIR=${#SELECT_DIR[@]}

#Check if user passes nothing, and the "testing" directory exists. If so, run.
if [ -d "$PWD/testing" ] && [ -z "$SELECT_DIR" ]
    then
        sbbuild $PWD/testing run ; cleanup
#Check if user passed something for a directory. If so, run all arguments in sequential order.
elif [ ! -z "$SELECT_DIR" ]
    then
        for (( i = 0; i < ${NUMDIR}; i++ )); do
            if [ $i == $(( NUMDIR-1 )) ] && [ -d "${SELECT_DIR[$i]}" ]
                then
                    printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
                    sbbuild ${SELECT_DIR[$i]} run ; cleanup
            elif [ ! -d "${SELECT_DIR[$i]}" ]
                then
                    printf "${TITLE} ERROR: Folder '${SELECT_DIR[$i]}' in parent directory '${PWD}' doesn't exist. Stopping and cleaning up mods.\n${ERR_HELP} \n" ; cleanup
                    break
            else
                printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
                sbbuild ${SELECT_DIR[$i]}
            fi
        done
elif [ ! -d "$PWD/testing" ] && [ "$HELP" != "help" ] && [ "$CLEANUP" != "cleanup" ]
    then
        printf "${TITLE} ERROR: Child folder 'testing' in parent directory '${PWD}' not found since folder argument not passed.\n${ERR_HELP} \n"
else
    if [ "$HELP" == "help" ] || [ "$CLEANUP" == "cleanup" ]
        then
            #Do nothing so that the error message doesn't pop up when doing these
            printf ""
    else
        printf "${TITLE} ERROR: Something went very wrong. Check the command line.\r"
    fi
fi
