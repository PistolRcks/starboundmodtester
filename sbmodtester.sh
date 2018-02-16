#!/bin/bash
#---TODO---
#Graphical interface option
#Version checks and updating from Git
#Steam directory sanity check before loading workshop mods
#macOS support

#Change these variables (without removing quotes) to change the Steam and Starbound directories, respectively.
STEAM_DIR="$HOME/.local/share/Steam"
STARBOUND_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"

HELP=""
LITERAL=""
CLEANUP=""
NO_CLEANUP=""
SERVER_MODE=""
SELECT_DIR=()
TITLE="\033[0;92m[SBMT]\033[0m:"
ERR_HELP="${TITLE} Need help? Use --help or -h."
VER="0.4.3"

sbbuild () {
    #The real secret sauce -- the mod building script
    if [ "$LITERAL" == "literal" ]
        then
            local lit_select_dir=$(basename "$1")
            cd "$STARBOUND_DIR/linux"
            rm -rf "$STARBOUND_DIR/mods/$lit_select_dir.tmp.pak"
            ./asset_packer "$1" "$STARBOUND_DIR/mods/$lit_select_dir.tmp.pak"
            cd "$OLDPWD"
    else
        cd "$STARBOUND_DIR/linux"
        rm -rf "$STARBOUND_DIR/mods/$1.tmp.pak"
        ./asset_packer "$OLDPWD/$1" "$STARBOUND_DIR/mods/$1.tmp.pak"
        cd "$OLDPWD"
    fi
    if [ "${!#}" == "run" ]
        then
            printf "${TITLE} Last mod '$1' built. Launching Starbound"
            if [ "$SERVER_MODE" == "server_mode" ]
                then
                    printf " in dedicated server mode.\n"
                    "$STARBOUND_DIR/linux/run-server.sh"
            else
                printf ".\n"
                "$STARBOUND_DIR/linux/run-client.sh"
            fi
    else
        printf "${TITLE} Mod '$1' built. Continuing.\n"
    fi
}

cleanup () {
    if [ "$SERVER_MODE" == "server_mode" ]
        then
            printf "${TITLE} Dedicated server mode on. Not cleaning up."
    #Ok, so maybe I should deprecate the "NO_CLEANUP" variable...
    elif [ "$NO_CLEANUP" == "no_cleanup" ]
        then
            printf "${TITLE} 'No cleanup' mode on. Not cleaning up."
    else
        cd "$STARBOUND_DIR/mods"
        rm -rf *.tmp.pak
        cd "$OLDPWD"
        printf "${TITLE} All cleaned up! Removed all *.tmp.pak files from your mod folder.\n"
    fi
}

showhelp () {
    printf "Welcome to Starbound Mod Tester Version $VER!\r
Usage: ./sbmodtester.sh [ARGUMENTS] [TARGET FOLDER NAME(S)]\n
---ARGUMENTS---
    -c | --cleanup
        Forces a cleanup. This deletes all *.tmp.pak files from Starbound's mod folder and is run automatically after closing Starbound client-side.
    --force-starbound
        Forces the Starbound directory to whatever comes after it. If you use 'linux_default,' it will use the default Linux Steam Starbound installation directory.
    --force-steam
        Forces the Steam directory to whatever comes after it. Similarly, if you use 'linux_default,' it will use the default Linux Steam installation directory.
    -h | --help
        Displays this help message.
    -l | --literal
        Initiates literal mode. Literal mode changes the folder target from its name to its location (See EXTRA NOTES or the Github README.md).
    -nb | --no-build
        Skips all mod building and runs Starbound.
    -nc | --no-cleanup
        Turns off mod cleanup after Starbound is finished. This is automatically applied when using the argument '--server.'
    --server
        Runs Starbound's dedicated server instead of client-side. When server mode is on, SBMT does not autocleanup.
    -w | --enable-workshop-mods
        Copys over workshop mods to the Starbound mod folder. This only applies if you have the Steam version of Starbound installed.

---EXTRA NOTES---
Returning the command with no arguments will default to pack a mod in the current directory with the target directory 'testing' and run Starbound in Steam's directory.\n
Note that the argument specifies the NAME of the folder (i.e. foobar) instead of its location (i.e. /home/foo/starboundmodding/foobar). \n
This is cancelled if the argument '--literal' is called. \n
You can set a default Steam or Starbound directory by changing the STEAM_DIR and STARBOUND_DIR variables (respectively) at the beginning of this .sh file, without removing quotes.\n"
}

#--Argument Parsing--
while [[ $# -gt 0 ]]
    do
        case $1 in
            -c | --cleanup )
                CLEANUP="cleanup"
                NO_CLEANUP=""
                cleanup
                break
                ;;
            --force-starbound )
                shift
                if [ "$1" == "linux_default" ]
                    then
                        STARBOUND_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"
                else
                    STARBOUND_DIR="$1"
                fi
                shift
                ;;
            --force-steam )
                shift
                if [ "$1" == "linux_default" ]
                    then
                        STEAM_DIR="$HOME/.local/share/Steam"
                else
                    STEAM_DIR="$1"
                fi
                shift
                ;;
            -h | --help )
                HELP="help"
                showhelp
                break
                ;;
            -l | --literal )
                LITERAL="literal"
                shift
                ;;
            -nb | --no-build )
                NO_BUILD="no_build"
                shift
                ;;
            -nc | --no-cleanup )
                NO_CLEANUP="no_cleanup"
                CLEANUP=""
                shift
                ;;
            --server )
                SERVER_MODE="server_mode"
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

#--Workshop Mod Loading--
if [ "$WORKSHOP_MODS" == "workshop_mods" ]
    then
        working_folder=$PWD
        modfolders=()
        printf "${TITLE} Initiating workshop mod copying...\n"
        cd "$STEAM_DIR/steamapps/workshop/content/211820"
        mapfile -t modfolders < <( ls "$STEAM_DIR/steamapps/workshop/content/211820" )
        for (( i = 0; i < ${#modfolders[@]} ; i++ )); do
            #Check if a mod's folder is empty. If so, skip.
            if [ -z "$(ls -A ${modfolders[i]})" ] && [ -d "${modfolders[i]}" ]
                then
                    printf "${TITLE} [$(( i+1 ))/${#modfolders[@]}] Steam mod folder with ID '${modfolders[i]}' is empty. Skipping.\n"
            else
                cd "${modfolders[i]}"
                cp *.pak "$STARBOUND_DIR/mods/wsmod_${modfolders[i]}.tmp.pak"
                cd ..
                printf "${TITLE} [$(( i+1 ))/${#modfolders[@]}] Steam mod with ID '${modfolders[i]}' successfully copyed. Moving on.\n"
            fi
        done
        cd "$working_folder"
        printf "${TITLE} All mods successfully initialized. Moving on to build phase.\n"
fi

#Save the number of di#!/bin/bash
#---TODO---
#Graphical interface option
#Version checks and updating from Git
#Steam directory sanity check before loading workshop mods
#macOS support

#Change these variables (without removing quotes) to change the Steam and Starbound directories, respectively.
STEAM_DIR="$HOME/.local/share/Steam"
STARBOUND_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"

HELP=""
LITERAL=""
CLEANUP=""
NO_CLEANUP=""
SERVER_MODE=""
SELECT_DIR=()
TITLE="\033[0;92m[SBMT]\033[0m:"
ERR_HELP="${TITLE} Need help? Use --help or -h."
VER="0.4.3"

sbbuild () {
    #The real secret sauce -- the mod building script
    if [ "$LITERAL" == "literal" ]
        then
            local lit_select_dir=$(basename "$1")
            cd "$STARBOUND_DIR/linux"
            rm -rf "$STARBOUND_DIR/mods/$lit_select_dir.tmp.pak"
            ./asset_packer "$1" "$STARBOUND_DIR/mods/$lit_select_dir.tmp.pak"
            cd "$OLDPWD"
    else
        cd "$STARBOUND_DIR/linux"
        rm -rf "$STARBOUND_DIR/mods/$1.tmp.pak"
        ./asset_packer "$OLDPWD/$1" "$STARBOUND_DIR/mods/$1.tmp.pak"
        cd "$OLDPWD"
    fi
    if [ "${!#}" == "run" ]
        then
            printf "${TITLE} Last mod '$1' built. Launching Starbound"
            if [ "$SERVER_MODE" == "server_mode" ]
                then
                    printf " in dedicated server mode.\n"
                    "$STARBOUND_DIR/linux/run-server.sh"
            else
                printf ".\n"
                "$STARBOUND_DIR/linux/run-client.sh"
            fi
    else
        printf "${TITLE} Mod '$1' built. Continuing.\n"
    fi
}

cleanup () {
    if [ "$SERVER_MODE" == "server_mode" ]
        then
            printf "${TITLE} Dedicated server mode on. Not cleaning up."
    #Ok, so maybe I should deprecate the "NO_CLEANUP" variable...
    elif [ "$NO_CLEANUP" == "no_cleanup" ]
        then
            printf "${TITLE} 'No cleanup' mode on. Not cleaning up."
    else
        cd "$STARBOUND_DIR/mods"
        rm -rf *.tmp.pak
        cd "$OLDPWD"
        printf "${TITLE} All cleaned up! Removed all *.tmp.pak files from your mod folder.\n"
    fi
}

showhelp () {
    printf "Welcome to Starbound Mod Tester Version $VER!\r
Usage: ./sbmodtester.sh [ARGUMENTS] [TARGET FOLDER NAME(S)]\n
---ARGUMENTS---
    -c | --cleanup
        Forces a cleanup. This deletes all *.tmp.pak files from Starbound's mod folder and is run automatically after closing Starbound client-side.
    --force-starbound
        Forces the Starbound directory to whatever comes after it. If you use 'linux_default,' it will use the default Linux Steam Starbound installation directory.
    --force-steam
        Forces the Steam directory to whatever comes after it. Similarly, if you use 'linux_default,' it will use the default Linux Steam installation directory.
    -h | --help
        Displays this help message.
    -l | --literal
        Initiates literal mode. Literal mode changes the folder target from its name to its location (See EXTRA NOTES or the Github README.md).
    -nb | --no-build
        Skips all mod building and runs Starbound.
    -nc | --no-cleanup
        Turns off mod cleanup after Starbound is finished. This is automatically applied when using the argument '--server.'
    --server
        Runs Starbound's dedicated server instead of client-side. When server mode is on, SBMT does not autocleanup.
    -w | --enable-workshop-mods
        Copys over workshop mods to the Starbound mod folder. This only applies if you have the Steam version of Starbound installed.

---EXTRA NOTES---
Returning the command with no arguments will default to pack a mod in the current directory with the target directory 'testing' and run Starbound in Steam's directory.\n
Note that the argument specifies the NAME of the folder (i.e. foobar) instead of its location (i.e. /home/foo/starboundmodding/foobar). \n
This is cancelled if the argument '--literal' is called. \n
You can set a default Steam or Starbound directory by changing the STEAM_DIR and STARBOUND_DIR variables (respectively) at the beginning of this .sh file, without removing quotes.\n"
}

#--Argument Parsing--
while [[ $# -gt 0 ]]
    do
        case $1 in
            -c | --cleanup )
                CLEANUP="cleanup"
                NO_CLEANUP=""
                cleanup
                break
                ;;
            --force-starbound )
                shift
                if [ "$1" == "linux_default" ]
                    then
                        STARBOUND_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"
                else
                    STARBOUND_DIR="$1"
                fi
                shift
                ;;
            --force-steam )
                shift
                if [ "$1" == "linux_default" ]
                    then
                        STEAM_DIR="$HOME/.local/share/Steam"
                else
                    STEAM_DIR="$1"
                fi
                shift
                ;;
            -h | --help )
                HELP="help"
                showhelp
                break
                ;;
            -l | --literal )
                LITERAL="literal"
                shift
                ;;
            -nb | --no-build )
                NO_BUILD="no_build"
                shift
                ;;
            -nc | --no-cleanup )
                NO_CLEANUP="no_cleanup"
                CLEANUP=""
                shift
                ;;
            --server )
                SERVER_MODE="server_mode"
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

#--Workshop Mod Loading--
if [ "$WORKSHOP_MODS" == "workshop_mods" ]
    then
        working_folder=$PWD
        modfolders=()
        printf "${TITLE} Initiating workshop mod copying...\n"
        cd "$STEAM_DIR/steamapps/workshop/content/211820"
        mapfile -t modfolders < <( ls "$STEAM_DIR/steamapps/workshop/content/211820" )
        for (( i = 0; i < ${#modfolders[@]} ; i++ )); do
            #Check if a mod's folder is empty. If so, skip.
            if [ -z "$(ls -A ${modfolders[i]})" ] && [ -d "${modfolders[i]}" ]
                then
                    printf "${TITLE} [$(( i+1 ))/${#modfolders[@]}] Steam mod folder with ID '${modfolders[i]}' is empty. Skipping.\n"
            else
                cd "${modfolders[i]}"
                cp *.pak "$STARBOUND_DIR/mods/wsmod_${modfolders[i]}.tmp.pak"
                cd ..
                printf "${TITLE} [$(( i+1 ))/${#modfolders[@]}] Steam mod with ID '${modfolders[i]}' successfully copyed. Moving on.\n"
            fi
        done
        cd "$working_folder"
        printf "${TITLE} All mods successfully initialized. Moving on to build phase.\n"
fi

#Save the number of directories chosen
NUMDIR=${#SELECT_DIR[@]}

#--Build Phase--
#NOTE: Build skip goes first so that it takes priority.
if [ "$NO_BUILD" == "no_build" ]
    then
        printf "${TITLE} Skipping build phase. Launching Starbound"
        if [ "$SERVER_MODE" == "server_mode" ]
            then
                printf " in dedicated server mode.\n"
                "$STARBOUND_DIR/linux/run-server.sh"
        else
            printf ".\n"
            "$STARBOUND_DIR/linux/run-client.sh" ; cleanup
        fi
#Check if user passes nothing, and the "testing" directory exists. If so, run.
elif [ -d "$PWD/testing" ] && [ -z "$SELECT_DIR" ]
    then
        printf "${TITLE} Initiating build phase...\n"
        sbbuild "$PWD/testing" run ; cleanup
#Check if user passed something for a directory. If so, run all arguments in sequential order.
elif [ ! -z "$SELECT_DIR" ]
    then
        printf "${TITLE} Initiating build phase...\n"
        for (( i = 0; i < ${NUMDIR}; i++ )); do
            if [ $i == $(( NUMDIR-1 )) ] && [ -d "${SELECT_DIR[$i]}" ]
                then
                    printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
                    sbbuild "${SELECT_DIR[$i]}" run ; cleanup
            elif [ ! -d "${SELECT_DIR[$i]}" ]
                then
                    printf "${TITLE} ERROR: Folder '${SELECT_DIR[$i]}' in parent directory '${PWD}' doesn't exist. Stopping and cleaning up mods.\n${ERR_HELP} \n" ; cleanup
                    break
            else
                printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
                sbbuild "${SELECT_DIR[$i]}"
            fi
        done
elif [ ! -d "$PWD/testing" ] && [ "$HELP" != "help" ] && [ "$CLEANUP" != "cleanup" ]
    then
        printf "${TITLE} ERROR: Child folder 'testing' in parent directory '${PWD}' not found since folder argument not passed.\n${ERR_HELP} \n"
else
    if [ "$HELP" == "help" ] || [ "$CLEANUP" == "cleanup" ]
        then
            #Do nothing so that the error message doesn't pop up when doing these
            #TODO: Deprecate this in the future.
            printf ""
    else
        printf "${TITLE} ERROR: Something went very wrong with directory parsing. Check the command line.\r"
    fi
fi
rectories chosen
NUMDIR=${#SELECT_DIR[@]}

#--Build Phase--
#NOTE: Build skip goes first so that it takes priority.
if [ "$NO_BUILD" == "no_build" ]
    then
        printf "${TITLE} Skipping build phase. Launching Starbound"
        if [ "$SERVER_MODE" == "server_mode" ]
            then
                printf " in dedicated server mode.\n"
                "$STARBOUND_DIR/linux/run-server.sh"
        else
            printf ".\n"
            "$STARBOUND_DIR/linux/run-client.sh" ; cleanup
        fi
#Check if user passes nothing, and the "testing" directory exists. If so, run.
elif [ -d "$PWD/testing" ] && [ -z "$SELECT_DIR" ]
    then
        printf "${TITLE} Initiating build phase...\n"
        sbbuild "$PWD/testing" run ; cleanup
#Check if user passed something for a directory. If so, run all arguments in sequential order.
elif [ ! -z "$SELECT_DIR" ]
    then
        printf "${TITLE} Initiating build phase...\n"
        for (( i = 0; i < ${NUMDIR}; i++ )); do
            if [ $i == $(( NUMDIR-1 )) ] && [ -d "${SELECT_DIR[$i]}" ]
                then
                    printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
                    sbbuild "${SELECT_DIR[$i]}" run ; cleanup
            elif [ ! -d "${SELECT_DIR[$i]}" ]
                then
                    printf "${TITLE} ERROR: Folder '${SELECT_DIR[$i]}' in parent directory '${PWD}' doesn't exist. Stopping and cleaning up mods.\n${ERR_HELP} \n" ; cleanup
                    break
            else
                printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
                sbbuild "${SELECT_DIR[$i]}"
            fi
        done
elif [ ! -d "$PWD/testing" ] && [ "$HELP" != "help" ] && [ "$CLEANUP" != "cleanup" ]
    then
        printf "${TITLE} ERROR: Child folder 'testing' in parent directory '${PWD}' not found since folder argument not passed.\n${ERR_HELP} \n"
else
    if [ "$HELP" == "help" ] || [ "$CLEANUP" == "cleanup" ]
        then
            #Do nothing so that the error message doesn't pop up when doing these
            #TODO: Deprecate this in the future.
            printf ""
    else
        printf "${TITLE} ERROR: Something went very wrong with directory parsing. Check the command line.\r"
    fi
fi
