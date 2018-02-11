#!/bin/bash
#---TODO---
#Graphical interface option

STARBOUND_DIR=$HOME/.local/share/Steam/steamapps/common/Starbound
HELP=""
LITERAL=""
CLEANUP=""
SELECT_DIR=()
TITLE="\033[0;92m[SBMT]\033[0m:"
ERR_HELP="${TITLE} Need help? Use --help or -h."
VER="0.4"

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
            /$STARBOUND_DIR/linux/run-client.sh
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
    -s | --skip-build
        Skips all mod building and runs Starbound.
    -w | --enable-workshop-mods
        Copys over workshop mods to the Starbound mod folder. This only applies if you have the Steam version of Starbound installed.

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
            -s | --skip-build )
                SKIP_BUILD="skip_build"
                shift
                ;;
            -w | --enable-workshop-mods )
                WORKSHOP_MODS="workshop_mods"
                shift
                ;;
            * )
                SELECT_DIR+=("$1")
                shift
                ;;
        esac
done

#Workshop mod loading
if [ "$WORKSHOP_MODS" == "workshop_mods" ]
    then
        working_folder=$PWD
        modfolders=()
        printf "${TITLE} Initiating workshop mod copying...\n"
        cd $HOME/.local/share/Steam/steamapps/workshop/content/211820
        mapfile -t modfolders < <( ls $HOME/.local/share/Steam/steamapps/workshop/content/211820 )
        for (( i = 0; i < ${#modfolders[@]} ; i++ )); do
            #Check if a mod's folder is empty. If so, skip.
            if [ -z "$(ls -A ${modfolders[i]})" ] && [ -d "${modfolders[i]}" ]
                then
                    printf "${TITLE} [$(( i+1 ))/${#modfolders[@]}] Steam mod folder with ID '${modfolders[i]}' is empty. Skipping.\n"
            else
                cd ${modfolders[i]}
                cp "contents.pak" "$STARBOUND_DIR/mods/wsmod_${modfolders[i]}.tmp.pak"
                cd ..
                printf "${TITLE} [$(( i+1 ))/${#modfolders[@]}] Steam mod with ID '${modfolders[i]}' successfully copyed. Moving on.\n"
            fi
        done
        cd $working_folder
        printf "${TITLE} All mods successfully initiated. Moving on to build phase.\n"
fi

#Save the number of directories chosen
NUMDIR=${#SELECT_DIR[@]}

#Check if user passes nothing, and the "testing" directory exists. If so, run.
if [ -d "$PWD/testing" ] && [ -z "$SELECT_DIR" ]
    then
        sbbuild $PWD/testing run ; cleanup
#Check if user passed something for a directory. If so, run all arguments in sequential order.
elif [ ! -z "$SELECT_DIR" ]
    then
        printf "${TITLE} Initiating build phase..."
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
elif [ "${SKIP_BUILD}" == "skip_build" ]
    then
        printf "${TITLE} Skipping build phase. Launching Starbound.\n"
        /$STARBOUND_DIR/linux/run-client.sh ; cleanup
elif [ ! -d "$PWD/testing" ] && [ "$HELP" != "help" ] && [ "$CLEANUP" != "cleanup" ]
    then
        printf "${TITLE} ERROR: Child folder 'testing' in parent directory '${PWD}' not found since folder argument not passed.\n${ERR_HELP} \n"
else
    if [ "$HELP" == "help" ] || [ "$CLEANUP" == "cleanup" ]
        then
            #Do nothing so that the error message doesn't pop up when doing these
            printf ""
    else
        printf "${TITLE} ERROR: Something went very wrong with directory parsing. Check the command line.\r"
    fi
fi
