#!/bin/bash
#---TODO---
#Graphical interface option
#Steam directory sanity check before loading workshop mods
#macOS support
#Clean up whatever is in the end of the last if statement

#Change these variables (without removing quotes) to change the Steam and Starbound directories, respectively.
STEAM_DIR="$HOME/.local/share/Steam"
STARBOUND_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"

HELP=""
CLEANUP=""
SERVER_MODE=""
SELECT_DIR=()
TITLE="\033[0;92m[SBMT]\033[0m:"
ERR_HELP="${TITLE} Need help? Use --help or -h."
VER="0.5.0.1"

updatefromgit () {
    local git_ver=$( wget -q -O - https://raw.githubusercontent.com/PistolRcks/starboundmodtester/master/VERSION )
    local update_bool
    if [[ -z "$git_ver" ]]; then
        printf "${TITLE} \e[31mERROR\e[0m: No response received from Github! Is Github down, or are you connected to the internet?\n"
    else
        if [[ "$git_ver" != "$VER" ]]; then
            printf "${TITLE} Local version does not match Github version! Local version is \e[1m${VER}\e[0m, while Github version is \e[1m${git_ver}\e[0m.\n"
            printf "${TITLE} Would you like to update? (\e[1mY\e[0m/n): "
            read response
            case $response in
                y | Y | "" )
                    update_bool=true
                    ;;
                n | N | * )
                    update_bool=false
                    ;;
            esac
            if [[ $update_bool == true ]]; then
                printf "${TITLE} Initiating download...\n"
                wget -O "sbmodtester.tmp.sh" https://raw.githubusercontent.com/PistolRcks/starboundmodtester/master/sbmodtester.sh
                local download_exitstatus=$? #Catch wget's exit status if the file might not have been downloaded correctly
                if [[ $download_exitstatus == 0 ]]; then
                    printf "${TITLE} Download complete! Replacing old version with new.\n"
                    echo -e '#!/bin/bash\nrm $1\nmv sbmodtester.tmp.sh sbmodtester.sh\nchmod +x sbmodtester.sh\nrm handover.sh' >> handover.sh  #Create a handover to replace versions, then self-destruct
                    chmod +x handover.sh
                    ./handover.sh $(basename "$0") #Using basename $0 as the user might have changed the name of sbmodtester
                    printf "\033[0;92m[SBMT]\033[0m: Update complete!\n"
                else
                    printf "${TITLE} Download failed! Aborting update.\n"
                    break
                fi
            else
                printf "${TITLE} Not updating, then.\n"
                break
            fi
        else
            printf "${TITLE} Local version matches Github version. You are already up to date!\n"
        fi
    fi
}

sbbuild () {
    #The real secret sauce -- the mod building script
    local lit_select_dir=$(basename "$1")
    if [[ "$1" == /* ]]; then
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
    if [[ "${!#}" == "run" ]]; then
        printf "${TITLE} Last mod '$lit_select_dir' built. Launching Starbound"
        if [[ "$SERVER_MODE" == "server_mode" ]]; then
            printf " in dedicated server mode.\n"
            "$STARBOUND_DIR/linux/run-server.sh"
        else
            printf ".\n"
            "$STARBOUND_DIR/linux/run-client.sh"
        fi
    else
        printf "${TITLE} Mod '$lit_select_dir' built. Continuing.\n"
    fi
}

cleanup () {
    if [[ "$SERVER_MODE" == "server_mode" ]]; then
        printf "${TITLE} Dedicated server mode on. Not cleaning up."
    elif [[ "$CLEANUP" == "no_cleanup" ]]; then
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
    --force-starbound [STARBOUND ROOT FOLDER]
        Forces the Starbound directory to whatever comes after it. If you use 'linux_default,' it will use the default Linux Steam Starbound installation directory.
    --force-steam [STEAM ROOT FOLDER]
        Forces the Steam directory to whatever comes after it. Similarly, if you use 'linux_default,' it will use the default Linux Steam installation directory.
    -h | --help
        Displays this help message.
    -nb | --no-build
        Skips all mod building and runs Starbound.
    -nc | --no-cleanup
        Turns off mod cleanup after Starbound is finished. This is automatically applied when using the argument '--server.'
    --server
        Runs Starbound's dedicated server instead of client-side. When server mode is on, SMT does not autocleanup.
    -u | --update
        Checks for an update and/or updates SMT from Github.
    -v | --version
        Returns SMT's version.
    -w | --enable-workshop-mods
        Copys over workshop mods to the Starbound mod folder. This only applies if you have the Steam version of Starbound installed.

---EXTRA NOTES---
Returning the command with no arguments will default to pack a mod in the current directory with the target directory 'testing' and run Starbound in Steam's directory.\n
You can set a default Steam or Starbound directory by changing the STEAM_DIR and STARBOUND_DIR variables (respectively) at the beginning of this .sh file, without removing quotes.\n"
}

#--Argument Parsing--
while [[ $# -gt 0 ]]; do
    case $1 in
        -c | --cleanup )
            CLEANUP="cleanup"
            cleanup
            break
            ;;
        --force-starbound )
            shift
            if [[ "$1" == "linux_default" ]]; then
                STARBOUND_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"
            else
                STARBOUND_DIR="$1"
            fi
            shift
            ;;
        --force-steam )
            shift
            if [[ "$1" == "linux_default" ]]; then
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
        -nb | --no-build )
            NO_BUILD="no_build"
            shift
            ;;
        -nc | --no-cleanup )
            CLEANUP="no_cleanup"
            shift
            ;;
        --server )
            SERVER_MODE="server_mode"
            shift
            ;;
        -u | --update )
            updatefromgit
            break
            ;;
        -v | --version )
            printf "$VER\n"
            break
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
if [[ "$WORKSHOP_MODS" == "workshop_mods" ]]; then
    working_folder=$PWD
    modfolders=()
    printf "${TITLE} Initiating workshop mod copying...\n"
    cd "$STEAM_DIR/steamapps/workshop/content/211820"
    mapfile -t modfolders < <( ls "$STEAM_DIR/steamapps/workshop/content/211820" )
    for (( i = 0; i < ${#modfolders[@]} ; i++ )); do
        #Check if a mod's folder is empty. If so, skip.
        if [[ -z "$(ls -A ${modfolders[i]})" ]] && [[ -d "${modfolders[i]}" ]]; then
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
if [[ "$NO_BUILD" == "no_build" ]]; then
    printf "${TITLE} Skipping build phase. Launching Starbound"
    if [[ "$SERVER_MODE" == "server_mode" ]]; then
        printf " in dedicated server mode.\n"
        "$STARBOUND_DIR/linux/run-server.sh"
    else
        printf ".\n"
        "$STARBOUND_DIR/linux/run-client.sh" ; cleanup
    fi
#Check if user passes nothing, and the "testing" directory exists. If so, run.
elif [[ -d "$PWD/testing" ]] && [[ -z "$SELECT_DIR" ]]; then
    printf "${TITLE} Initiating build phase...\n"
    sbbuild "$PWD/testing" run ; cleanup
#Check if user passed something for a directory. If so, run all arguments in sequential order.
elif [[ ! -z "$SELECT_DIR" ]]; then
    printf "${TITLE} Initiating build phase...\n"
    for (( i = 0; i < ${NUMDIR}; i++ )); do
        if [[ $i == $(( NUMDIR-1 )) ]] && [[ -d "${SELECT_DIR[$i]}" ]]; then
            printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
            sbbuild "${SELECT_DIR[$i]}" run ; cleanup
        elif [[ ! -d "${SELECT_DIR[$i]}" ]]; then
            printf "${TITLE} \e[31mERROR\e[0m: Folder '${SELECT_DIR[$i]}' in parent directory '${PWD}' doesn't exist. Stopping and cleaning up mods.\n${ERR_HELP} \n" ; cleanup
            break
        else
            printf "${TITLE} Starting build number $(( i+1 )) out of ${NUMDIR}.\n"
            sbbuild "${SELECT_DIR[$i]}"
        fi
    done
elif [[ ! -d "$PWD/testing" ]] && [[ $# == 0 ]]; then
    printf "${TITLE} \e[31mERROR\e[0m: Child folder 'testing' in parent directory '${PWD}' not found since folder argument not passed.\n${ERR_HELP} \n"
else
    if [[ $# -gt 0 ]]; then
        #Do nothing so that the error message doesn't pop up when doing these
        #TODO: Deprecate this in the future.
        printf ""
    else
        printf "${TITLE} \e[31mERROR\e[0m: Something went very wrong with directory parsing. Check the command line.\r"
    fi
fi
