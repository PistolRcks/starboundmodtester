#!/bin/bash
#---TODO---
#Graphical interface option
#macOS support

#Change these variables (without removing quotes) to change the Steam and Starbound directories, respectively.
STEAM_DIR="$HOME/.steam/steam"
STARBOUND_DIR="$HOME/.steam/steam/steamapps/common/Starbound"

HELP=""
CLEANUP=""
SERVER_MODE=""
SELECT_DIR=()
WORKING_DIR="$PWD"
TITLE="\033[0;92m[SBMT]\033[0m:"
ERR_TITLE="\033[0;92m[SBMT]\033[0m: \e[31mERROR\e[0m:"
ERR_HELP="$TITLE Need help? Use --help or -h."
VER="0.5.2.4"

updatefromgit () {
  printf "$TITLE Checking for an update...\n"
  local git_ver=$(wget -q -O - -T 30 https://raw.githubusercontent.com/PistolRcks/starboundmodtester/master/VERSION)
  local update_bool
  if [[ -z "$git_ver" ]]; then
    printf "$ERR_TITLE No response received from Github! Is Github down, or are you connected to the internet?\n"
  else
    if [[ "$git_ver" != "$VER" ]]; then
      local headername="## $git_ver"
      printf "$TITLE Downloading changelog...\n"
      wget -q -O "changelog.tmp.md" -T 15 https://raw.githubusercontent.com/PistolRcks/starboundmodtester/master/CHANGELOG.md #It would be much too silly to put the entire changelog into a variable, so we won't
      local changelog_exitstatus=$? #Catch the exit status
      printf "$TITLE Local version does not match Github version! Local version is \e[1m$VER\e[0m, while Github version is \e[1m$git_ver\e[0m.\n"
      #Start reading the changelog
      if [[ $changelog_exitstatus == 0 ]]; then
        echo -e "\e[1mChangelog Notes for $git_ver:\e[0m"
        for (( i = 1; i <= $(wc -l "changelog.tmp.md" | awk '{print $1}'); i++ )); do #For some odd reason, if command output is to be used, it must be called within the `for` statement. This gets the line count, by the way.
          #Insert *arrays start at one* joke here
          currentline=$(sed -n "$i p" "changelog.tmp.md") #Get the current line
          if [[ "$currentline" == "$headername" ]]; then #If the current line is the line we're looking for, start printing
            startprinting=true
          elif [[ $startprinting ]] && [[ "$currentline" == "## "* ]]; then #If the current line is a different version header than the one we're looking for and we've already started printing, then stop.
            startprinting=false; break
          fi
          if [[ $startprinting ]]; then
            case $currentline in
              "## "* )
                #Adds escape codes to second headers
                echo -e "\e[44m$currentline\e[0m"
                ;;
              "### "* )
                #Adds escape codes to third headers
                echo -e "\e[34m$currentline\e[0m"
                ;;
              * )
                #Adds escape codes for everything else--read up on the sed command.
                echo -e "$(sed -e 's/+ /\\e[92m+ \\e[0m/1;s/- /\\e[91m- \\e[0m/1;s/[*] /\\e[93m* \\e[0m/1;s/`\([^`]*\)`/\\e[4m\1\\e[0m/g;s/ @/\\e[94m @\\e[0m/g;s/ #/\\e[94m #\\e[0m/g' <<< "$currentline")"
                ;;
            esac
          fi
        done
      else
        printf "$ERR_TITLE Changelog failed to download! Is Github down?\n"
      fi
      rm changelog.tmp.md #Get rid of the temporary changelog.
      printf "$TITLE Would you like to update? (\e[1mY\e[0m/n): "
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
        printf "$TITLE Initiating download...\n"
        wget -q -O sbmodtester.tmp.sh -T 60 --show-progress https://raw.githubusercontent.com/PistolRcks/starboundmodtester/master/sbmodtester.sh
        local download_exitstatus=$? #Catch wget's exit status since the file might not have been downloaded correctly
        if [[ $download_exitstatus == 0 ]]; then
          printf "$TITLE Download complete! Replacing old version with new.\n"
          echo -e '#!/bin/bash\nrm $1\nmv sbmodtester.tmp.sh $1\nchmod +x $1\nrm handover.sh' >> handover.sh  #Create a handover to replace versions, then self-destruct
          chmod +x handover.sh
          ./handover.sh "$(basename "$0")" #Using basename $0 as the user might have changed the name of sbmodtester
          printf "\033[0;92m[SBMT]\033[0m: Update complete!\n"
        else
          printf "$ERR_TITLE Download failed! Aborting update.\n"
        fi
      else
        printf "$TITLE Not updating, then.\n"
      fi
    else
        printf "$TITLE Local version matches Github version. You are already up to date!\n"
    fi
	fi
}

sbbuild () {
  #The real secret sauce -- the mod building script
  local dir_name="$(basename "$1")" #Using basename for both literal and relative naming because IT DOESN'T MATTER
  local real_pos="$WORKING_DIR/$1"
  if [[ "$1" == /* ]]; then
    local real_pos="$1"
  fi
  #Make sure all the necessary components are in order, specifically:
  #The folder is not empty and there are necessary mod components (also specifically pak.modinfo and _metadata)
  if [[ ! -z "$(ls "$real_pos")" ]] && [[ -e "$real_pos/pak.modinfo" ]] && [[ -e "$real_pos/_metadata" ]]; then
    cd "$STARBOUND_DIR/linux"
    rm -rf "$STARBOUND_DIR/mods/$dir_name.tmp.pak"
    ./asset_packer "$real_pos" "$STARBOUND_DIR/mods/$dir_name.tmp.pak"
    cd "$WORKING_DIR"
  else
    printf "$ERR_TITLE You are missing the following in '$real_pos':\n"
    #TODO: This is really dirty and should be optimized
    if [[ -z "$(ls "$real_pos")" ]]; then
      printf "$ERR_TITLE Any content in the target mod folder. Please add content to your mod before trying to build it!\n"
    elif [[ ! -e "$real_pos/pak.modinfo" ]]; then
      printf "$ERR_TITLE A 'pak.modinfo' file in the target mod folder.\n"
      if [[ ! -e "$real_pos/_metadata" ]]; then
        printf "$ERR_TITLE An '_metadata' file in the target mod folder.\n"
      fi
    elif [[ ! -e "$real_pos/_metadata" ]]; then
      printf "$ERR_TITLE A '_metadata' file in the target mod folder.\n"
      if [[ ! -e "$real_pos/pak.modinfo" ]]; then
        printf "$ERR_TITLE A 'pak.modinfo' file in the target mod folder.\n"
      fi
    fi
    printf "$ERR_TITLE Mod build phase failed! Stopping.\n"
    cleanup; exit 1
  fi
  if [[ "${!#}" == "run" ]]; then
    printf "$TITLE Last mod '$dir_name' built. Launching Starbound"
    if [[ "$SERVER_MODE" == "server_mode" ]]; then
      printf " in dedicated server mode.\n"
      "$STARBOUND_DIR/linux/run-server.sh"
    else
      printf ".\n"
      "$STARBOUND_DIR/linux/run-client.sh"
    fi
  else
    printf "$TITLE Mod '$dir_name' built. Continuing.\n"
  fi
}

cleanup () {
  if [[ "$SERVER_MODE" == "server_mode" ]]; then
    printf "$TITLE Dedicated server mode on. Not cleaning up.\n"
  elif [[ "$CLEANUP" == "no_cleanup" ]]; then
    printf "$TITLE 'No cleanup' mode on. Not cleaning up.\n"
  else
    cd "$STARBOUND_DIR/mods"
    rm -rf *.tmp.pak
    cd "$WORKING_DIR"
    printf "$TITLE All cleaned up! Removed all *.tmp.pak files from your mod folder.\n"
  fi
}

showhelp () {
  printf "Welcome to Starbound Mod Tester Version $VER!\r
Usage: $0 [ARGUMENTS] [TARGET FOLDER NAME(S)]\n
---ARGUMENTS---
    -c | --cleanup
        Forces a cleanup. This deletes all *.tmp.pak files from Starbound's mod
        folder and is run automatically after closing Starbound client-side.
    --force-starbound [STARBOUND ROOT FOLDER]
        Forces the Starbound directory to whatever comes after it. If you use
        'linux_default,' it will use the default Linux Steam Starbound
        installation directory. Using 'old_linux_default' sets SMT to use
        '/home/USER/.local/share/Steam/steamapps/common/Starbound'.
    --force-steam [STEAM ROOT FOLDER]
        Forces the Steam directory to whatever comes after it.
        The 'linux_default' and 'old_linux_default' options also work with this.
    -h | --help
        Displays this help message.
    -nb | --no-build
        Skips all mod building and runs Starbound.
    -nc | --no-cleanup
        Turns off mod cleanup after Starbound is finished. This is automatically
        applied when using the argument '--server.'
    -nv | --no-version-check
        Turns off automatic version checking after SMT finishes. Turn this off
        if you don't feel like checking for updates every time you run SMT.
    --server
        Runs Starbound's dedicated server instead of client-side. When server
        mode is on, SMT does not automatically cleanup.
    -u | --update
        Checks for an update and/or updates SMT from Github.
    -v | --version
        Returns SMT's version.
    -w | --enable-workshop-mods
        Copys over workshop mods to the Starbound mod folder. This only applies
        if you have the Steam version of Starbound installed.

---EXTRA NOTES---
Returning the command with no arguments will default to pack a mod in the
current directory with the target directory 'testing' and run Starbound in
Steam's directory.\n
You can set a default Steam or Starbound directory by changing the STEAM_DIR and
STARBOUND_DIR variables (respectively) at the beginning of this .sh file,
without removing quotes.\n"
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
      case $1 in
        linux_default )
          STARBOUND_DIR="$HOME/.steam/steam/steamapps/common/Starbound"
          ;;
        old_linux_default )
          STEAM_DIR="$HOME/.local/share/Steam/steamapps/common/Starbound"
          ;;
        * )
          STARBOUND_DIR="$1"
          ;;
      esac
      shift
      ;;
    --force-steam )
      shift
      case $1 in
        linux_default )
          STEAM_DIR="$HOME/.steam/steam"
          ;;
        old_linux_default )
          STEAM_DIR="$HOME/.local/share/Steam"
          ;;
        * )
          STEAM_DIR="$1"
          ;;
      esac
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
    -nv | --no-version-check )
      VERSIONCHECK="no_version_check"
      shift
      ;;
    --server )
      SERVER_MODE="server_mode"
      shift
      ;;
    -u | --update )
      updatefromgit
      VERSIONCHECK="no_version_check"
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
    -* | --* )
      printf "$ERR_TITLE Argument '$1' isn't an argument! Stopping.\n"
      break
      ;;
    * )
      SELECT_DIR+=("$1")
      shift
      ;;
  esac
done

#--Workshop Mod Loading--
if [[ "$WORKSHOP_MODS" == "workshop_mods" ]]; then
  modfolders=()
  printf "$TITLE Initiating workshop mod copying...\n"
  if [[ -s "$STEAM_DIR/steamapps/workshop/content/211820" ]]; then
    cd "$STEAM_DIR/steamapps/workshop/content/211820"
    mapfile -t modfolders < <( ls "$STEAM_DIR/steamapps/workshop/content/211820" )
    for (( i = 0; i < ${#modfolders[@]} ; i++ )); do
      #Check if a mod's folder is empty. If so, skip.
      if [[ -z "$(ls -A ${modfolders[i]})" ]] && [[ -d "${modfolders[i]}" ]]; then
        printf "$TITLE [$(( i+1 ))/${#modfolders[@]}] Steam mod folder with ID '${modfolders[i]}' is empty. Skipping.\n"
      else
        cd "${modfolders[i]}"
        cp *.pak "$STARBOUND_DIR/mods/wsmod_${modfolders[i]}.tmp.pak"
        cd ..
        printf "$TITLE [$(( i+1 ))/${#modfolders[@]}] Steam mod with ID '${modfolders[i]}' successfully copied. Moving on.\n"
      fi
    done
      cd "$WORKING_DIR"
      printf "$TITLE All mods successfully initialized. Moving on to build phase.\n"
  else
    cd "$WORKING_DIR"
    printf "$ERR_TITLE Either the Steam Workshop folder for Starbound doesn't exist, or it's empty! Are you sure you're pointing to the correct directory?\n"
    printf "$ERR_TITLE Mods not successfully initialized! Stopping.\n"
    cleanup; exit 2
  fi
fi

#Save the number of directories chosen
NUMDIR=${#SELECT_DIR[@]}

#--Build Phase--
#NOTE: Build skip goes first so that it takes priority.
if [[ "$NO_BUILD" == "no_build" ]]; then
  printf "$TITLE Skipping build phase. Launching Starbound"
  if [[ "$SERVER_MODE" == "server_mode" ]]; then
    printf " in dedicated server mode.\n"
    "$STARBOUND_DIR/linux/run-server.sh"
  else
    printf ".\n"
    "$STARBOUND_DIR/linux/run-client.sh" ; cleanup
  fi
#Check if user passes nothing, and the "testing" directory exists. If so, run.
elif [[ -d "$PWD/testing" ]] && [[ -z "$SELECT_DIR" ]] && [[ $# == 0 ]]; then
  printf "$TITLE Initiating build phase...\n"
  sbbuild "$PWD/testing" run ; cleanup
#Check if user passed something for a directory. If so, run all arguments in sequential order.
elif [[ ! -z "$SELECT_DIR" ]]; then
  printf "$TITLE Initiating build phase...\n"
  for (( i = 0; i < ${NUMDIR}; i++ )); do
    if [[ $i == $(( NUMDIR-1 )) ]] && [[ -d "${SELECT_DIR[$i]}" ]]; then
      printf "$TITLE Starting build number $(( i+1 )) out of $NUMDIR.\n"
      sbbuild "${SELECT_DIR[$i]}" run ; cleanup
    elif [[ ! -d "${SELECT_DIR[$i]}" ]]; then
      printf "$ERR_TITLE Folder '${SELECT_DIR[$i]}' in parent directory '$PWD' doesn't exist. Stopping and cleaning up mods.\n$ERR_HELP \n" ; cleanup
      break
    else
      printf "$TITLE Starting build number $(( i+1 )) out of $NUMDIR.\n"
      sbbuild "${SELECT_DIR[$i]}"
    fi
  done
elif [[ ! -d "$PWD/testing" ]] && [[ $# == 0 ]]; then
  printf "$ERR_TITLE Child folder 'testing' in parent directory '$PWD' not found since folder argument not passed.\n$ERR_HELP \n"
else
  if [[ ! $# -gt 0 ]]; then #Worst case scenario where everything goes wrong
    printf "$ERR_TITLE Something went very wrong with directory parsing. Check the command line.\n"
  fi
fi

#Check for updates every time SMT is used
if [[ "$VERSIONCHECK" != "no_version_check" ]]; then
  ping -q -c 1 -W 1 8.8.8.8 >/dev/null #Ping a Google server. This probably won't work if you live in a country where Google is blocked (but I'd assume that you wouldn't be playing Starbound, either)
  ping_exitstatus=$? #This is probably unnecessary, but I'm doing it anyway
  if [[ $ping_exitstatus == 0 ]]; then #We're not going to attempt an update if the internet's not on.
    git_ver=$(wget -q -O - -T 30 https://raw.githubusercontent.com/PistolRcks/starboundmodtester/master/VERSION)
    if [[ "$git_ver" != "$VER" ]]; then
      printf "$TITLE There is a new update available! Use the '--update' variable to run it!\n"
    fi
  fi
fi
