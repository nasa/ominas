#!/bin/echo Should be run as: source
#!/usr/bin/env bash
# configure.sh: OMINAS auto-configuration script

# USAGE -----------------------------------------------------------------#
# This script sets the environment needed to run OMINAS. To use this     #
# installer, enter the following command at the terminal:                #
#      source configure.sh                                               #
#                                                                        #
# This command should be run from the "ominas" directory, if that is     #
# not the current working directory, the script can be run with:         #
#      source relative/path/to/configure.sh                              #
#                                                                        #
# OPTIONS:                                                               #
#                                                                        #
#      -c   CUSTOM   If a custom mission package is to be installed,     #
#                    name the script ominas_env_<mission name>.sh and    #
#                    place it in the ominas directory.                   #
#                                                                        #
# ADDITIONAL NOTES:                                                      #
# WILL INSTALL:                                                          #
#      -> OMINAS core package                                            #
#      -> Mission packages (Optional)                                    #
#      -> NAIF Icy Toolkit (Optional) (Internet Connection Required)     #
#      -> Star Catalogs                                                  #
#      -> Voyager SEDR data                                              #
#                                                                        #
# A local copy of the following must be present to be configured for     #
# OMINAS:                                                                #
#      -> Star Catalogs (Download from CDS)                              #
#      -> Mission Kernel Pools (Download from NAIF or PDS)               #
#      -> Voyager SEDR data                                              #
#                                                                        #
# FAQ:                                                                   #
# Q: What should I do if I have data installed in a custom directory     #
#    and I misspell the path name?                                       #
# A: If you make a typo entering a path name, you can re-run the         #
#    installer (Recall: source configure.sh).                            #
#                                                                        #
# Q: Something is wrong, but I don't know what...                        #
# A: If there is an unknown error with the configuration, run the        #
#    uninstaller with the command:                                       #
#                 source uninstall.sh                                    #
#    Then re-run the the installer (Recall: source configure.sh)         #
#                                                                        #
#------------------------------------------------------------------------#


# COMPATIBILITY ---------------------------------------------------------#
# This configuration script is not POSIX compliant. There are several    #
# features which may fail on certain shells. The script must be run as   #
# a source and MAY work with other shells (certainly not the C shell)    #
# if the 'setting' variable is adjusted to the startup file for your     #
# shell in the section titled SETTINGS FILE DETECTION (e.g., ksh must    #
# change these lines to '.profile' and '.kshrc')                         #
#                                                                        #
# If nothing else works, you can attempt to install manually by enter-   #
# ing the following commands into your shell settings file:              #
#                                                                        #
# OMINAS_DIR=path/to/OMINAS; export OMINAS_DIR                           #
#                                                                        #
# #First, select whether you would like the demo functionality enabled   #
# #by setting the DFLAG variable to true if yes, false if no.            #
# DFLAG=<true/false>                                                     #
# source ${OMINAS_DIR}/config/ominas_env_def.sh path/to/GENERIC_KERNELS  #
#                                                                        #
# #Similarly, enter a line for each additional package you would like    #
# #to install. For Cassini:                                              #
# source ${OMINAS_DIR}/config/ominas_env_cas.sh path/to/CAS_KERNELS      #
#                                                                        #
# #Note that Cassini->cas Voyager->vgr, Galileo->gll, Dawn->dawn         #
#------------------------------------------------------------------------#

shtype="sh"
ins_ominas_env_def='' # `grep "ominas_env_def\.sh" ${setting}`
ins_c_0=''
inst_SAO=''
yes="CONFIGURED"
no="NOT CONFIGURED"
st="CONFIGURED"
ns="NOT CONFIGURED"
cwd=$PWD

#------------------------------------------------------------------------#
# Configure will attempt to detect whether it is being run from its      #
# own directory. The directory is automatically changed if the test      #
# fails, and changed back at the end of execution.                       #
#------------------------------------------------------------------------#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
test $DIR != $PWD && 
	(printf "Warning: configuration should  be run from the OMINAS directory\n"; 
	cd $DIR;
	cdflag=true)

trap `test $cdflag && (cd $cwd)` \
    EXIT

# SETTINGS FILE DETECTION -----------------------------------------------#
# The type of bash settings file is detected. Configure requires use     #
# either '.bash_profile' or '.bashrc'. In general, bash_profile is       #
# used for login shells and bashrc is used for non-interactive shell     #
# sessions. If neither settings file is detected, bash_profile is used   #
# by default (this causes a new file to be made).                        #
#------------------------------------------------------------------------#
echo "Detecting .bash_profile..."
if [ -f ~/.bash_profile ]; then 
        echo ".bash_profile detected!"
        psetting="$HOME/.bash_profile"
else    
        echo "Not present! Making a new .bash_profile..."
        touch "$HOME/.bash_profile"
        psetting="$HOME/.bash_profile"
fi
echo "Detecting .bashrc..."
if [ -f ~/.bashrc ]; then
	echo ".bashrc detected!"
	setting="$HOME/.bashrc"
else
	echo "Not present! Making a new .bashrc..."
	touch "$HOME/.bashrc"
	setting="$HOME/.bashrc"
fi
#fi
if [ ! -z ${IDL_PATH}+x ]; then
  if [ -f ~/.bashrc ]; then
    if grep --quiet IDL_PATH ~/.bashrc; then
      idlpathfile="$HOME/.bashrc"
    fi
  fi
  if [ ! ! -z ${IDL_PATH}+x ]; then
    if [ -f ~/.bash_profile ]; then
      if grep --quiet IDL_PATH ~/.bash_profile; then
        idlpathfile="$HOME/.bash_profile"
      else
        idlpathfile="$HOME/.profile"
      fi
    fi
  fi
fi


if [ "$IDL_DIR" = "" ]; then
        ivers=( "idl87" "idl86" "idl85" "idl84" "idl83" "idl82" "idl" )
        for idlbinv in "${ivers[@]}"; do
          idl=`which ${idlbinv} | tail -1`
          echo ${idlbinv}
          idlbin=$idl
          if [ "$idl" != "" ]; then break; fi
        done
        if [ "$idl" = "" ]; then
          read -rp "IDL not found. Please enter the location of your IDL installation (such as /usr/local/exelis/idl85): " idldir
          IDL_DIR="$idldir"
          export IDL_DIR
          printf "Using IDL from $IDL_DIR\n"
          idlbin=$IDL_DIR/bin/idl
        else
          printf "Using IDL at $idl\n"
          IDL_DIR=`${idl} -e 'print,filepath("")' | tail -1`
          printf "Setting IDL_DIR to ${IDL_DIR}\n"
          export IDL_DIR
          idlbin=$IDL_DIR/bin/idl
        fi
else
        printf "IDL_DIR found, $IDL_DIR, using it\n"
        idlbin=$IDL_DIR/bin/idl
fi
bintest=`echo ${idlbin} | grep -c "/bin/bin\."`
if [ ${bintest} != 0 ]; then
  idlbin=`dirname ${idlbin}`
  idlbin=`dirname ${idlbin}`
  idlbin="${idlbin}/idl"
fi 
export idlbin
idlversion=`$idlbin -e 'print,!version.os+strjoin((strsplit(!version.release,".",/extract))[0:1])'`
export idlversion

ominassh="$HOME/.ominas/ominas_setup.sh"
usersh=$setting
setting=$ominassh
osetting="$HOME/.ominas/ominas_setup_old.sh"
if [ ! -d "$HOME/.ominas" ]; then
  printf "Creating ~/.ominas directory\n"
  mkdir $HOME/.ominas
else
  printf "~/.ominas directory already exists\n"
fi
if [ ! -d "$HOME/.ominas/config" ]; then
  printf "Creating ~/.ominas/config directory\n"
  mkdir $HOME/.ominas/config
else
  printf "~/.ominas/config directory already exists\n"
fi
ans=u
if [ ! -e "$HOME/.ominas/config/ominas_env_def.sh" ]; then
  cp -avf config/ominas_env_def.sh $HOME/.ominas/config/
else
  printf "$HOME/.ominas/config/ominas_env_def.sh already exists\n"
  #read -rp "Would you like to overwrite the files in ${HOME}/.ominas/config with the default ominas_env_def.sh? A copy will be made of the old files. (y/n)[n]" ans
  ans='Y'
  case $ans in
   [Yy]*) 
     mv -vf $HOME/.ominas/config/ominas_env_def.sh $HOME/.ominas/config/ominas_env_def.sh.old
     cp -avf config/ominas_env_def.sh $HOME/.ominas/config/ ;;
   *) ans=n ;;
  esac
fi
if [ ! -e "$HOME/.ominas/config/ominas_env_strcat.sh" ]; then
  cp -avf config/strcat/ominas_env_strcat.sh $HOME/.ominas/config/
else
  printf "$HOME/.ominas/config/ominas_env_strcat.sh already exists\n"
  if [ $ans == u ]; then
    read -rp "Would you like to overwrite the files in ${HOME}/.ominas/config with the default ominas_env_def.sh? A copy will be made of the old files. (y/n)[n]" ans
  fi
    case $ans in
     [Yy]*) 
       mv -vf $HOME/.ominas/config/ominas_env_strcat.sh $HOME/.ominas/config/ominas_env_strcat.sh.old
       cp -avf config/strcat/ominas_env_strcat.sh $HOME/.ominas/config/ ;;
     *) ans=n ;;
    esac
fi
for mis in  cas dawn gll vgr juno
do
  if [ ! -e "$HOME/.ominas/config/ominas_env_$mis.sh" ]; then
    cp -avf config/$mis/ominas_env_$mis.sh $HOME/.ominas/config/
  else
    printf "$HOME/.ominas/config/ominas_env_$mis.sh already exists\n"
    if [ $ans == u ]; then
      read -rp "Would you like to overwrite the files in ${HOME}/.ominas/config with the default ominas_env_def.sh? A copy will be made of the old files. (y/n)[n]" ans
    fi
      case $ans in
       [Yy]*)
         mv -vf $HOME/.ominas/config/ominas_env_$mis.sh $HOME/.ominas/config/ominas_env_$mis.sh.old
         cp -avf config/$mis/ominas_env_$mis.sh $HOME/.ominas/config/ ;;
       *) ans=n ;;
      esac
    fi
done


export OMINAS_RC=${HOME}/.ominas
if [ ! -d "${HOME}/ominas_data" ]; then
  printf "Creating ~/ominas_data directory\n"
  mkdir ${HOME}/ominas_data
else
  printf "~/ominas_data directory already exists\n"
fi

for f in grimrc Xdefaults-grim 
do
  if [ ! -e ${OMINAS_RC}/${f} ]; then
    echo "Copying default ${f} to ${OMINAS_RC}"
    cp -avf config/${f} ${OMINAS_RC}/
  else
    echo "${f} already exists in ${OMINAS_RC}, not changing it"
  fi
done

if [ ! -e ${OMINAS_RC}/ominas_postsetup.sh ]; then
  touch ${OMINAS_RC}/ominas_postsetup.sh
fi

export OMINAS_DATA=${HOME}/ominas_data
if [ ! -e ${setting} ]; then
  echo "#!/usr/bin/env bash" > ${setting} 
fi
if [ -e "${setting}" ]; then
  rm -f ${osetting}
  cp -avf ${setting} ${osetting}
  ins_ominas_env_def=`grep "ominas_env_def\.sh" ${setting}` 
else
  touch $osetting
fi
if [ ! -e ${OMINAS_RC}/idlpath.sh ]; then
  touch ${OMINAS_RC}/idlpath.sh
fi

#echo "#!/usr/bin/env bash" > $setting

function ext()
{
	# EXTRACT -----------------------------------------------------------#
	#    Extracts files of (almost) any archive file type.               #
	#    Arg 1 -> File to be extracted                                   #
	#    Issues: Files such as icy.tar.Z, the archive for the NAIF       #
	#    Icy toolkit will not break this function, but will require      #
	#    two passes.                                                     #
	#    Note: No longer used. OMINAS is generally packaged as a git     #
	#    repository, which extracts itself. Also, this script is con-    #
	#    tained within the ominas directory...                           #
	#--------------------------------------------------------------------#
	if [ -f $1 ]; then
		case $1 in
			*.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress -f $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >ext<" 1>&2 ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

function pkst()
{
	# PACKAGE STATUS ----------------------------------------------------#
	#    Determines whether or not a mission package is installed.       #
	#    Arg 1 -> Name of the package to be checked                      #
	#    Checks the NV_TRANSLATORS environment variable, and deter-      #
	#    mines if the named package is contained in the list of          #
	#    directories. Returns an "INSTALLED" or "NOT INSTALLED" status.  #
	#--------------------------------------------------------------------#
        #echo $1
        #echo $NV_TRANSLATORS
	if [ -z ${NV_TRANSLATORS+x} ]; then
		echo "$no"
	else
                #echo "$1"
		if [[ $NV_TRANSLATORS == *"$1"* ]]; then
			echo "$yes"
		else
			echo "$no"
		fi
	fi
}

function ppkg()
{
	# PARSE PACKAGE -----------------------------------------------------#
	#    Parses a numerical argument specifying the mission package.     #
	#    Arg 1 -> Numerical value to be parsed                           #
	#--------------------------------------------------------------------#
	script="ominas_env_${mis[$1]}.$shtype"
	case ${mis[$1]} in 
		"cas")
			kername="CASSINI"
                        longname="Cassini"	;;
		"gll")
			kername="GLL"
                        longname="Galileo"	;;
		"vgr")
			kername="VOYAGER"
                        longname="Voyager"	;;
		"dawn")
			kername="DAWN"
                        longname="Dawn"	;;
                "juno")
                        kername="JUNO"
                        longname="Juno" ;;

		*)
	esac
	pkins $script $kername $longname $1
}

function dins()
{
	# INSTALL DATA ------------------------------------------------------#
	#    Set a data package to the path.                                 #
	#    Arg 1 -> Name of the data package to be added to the path.      #
	#    Checks if the data package has already been written to the      #
	#    bash settings file, if it has, it will check if you would       #
	#    like to overwrite before prompting you for the directory.       #
	#    if you don't know, it will attempt to find it for you.          #
	#--------------------------------------------------------------------#
	mnum=$1
	dat=${Data[$mnum]}
	if grep -q "export NV_${dat}_DATA" ${setting}; then
                if [ ${ominas_auto} == 1 ] ; then
                  return 1
                fi
                if [ ${2} == "NOASK" ]; then
                 unset inst[${1}]
                 return 1
                fi
		printf "Warning: $dat data files appear to already be set at this location:\n"
                eval echo \$NV_${dat}_DATA
                tmp=`grep "export NV_${dat}_DATA" $setting`
                IFS='=' read -ra tmpa <<< "$tmp"
		#read -rp "Would you like to overwrite this location (y/n)? " ans
                if [ ${ominas_auto_u} != 1 ] ; then
                  read -rp "Would you like to unconfigure $dat from this location (y/n)[n]? " ans
                else
                  ans=y
                fi
		case $ans in 
		[Yy]*)
                        #echo "!path+=':./util/downloader'& delete_ominas_files,'${tmpa[1]}' & exit"
                        $idlbin -e "!path+=':'+file_expand_path('./util/downloader')+':'+file_expand_path('./util/')& delete_ominas_files,'${tmpa[1]}',conf=${ominas_auto_u}+${ominas_nodel} & exit"
                        
                        unset inst[${1}]
                        return 1;;
			#grep -v "NV_${dat}_DATA.*" $setting >$HOME/temp
			#mv $HOME/temp $setting	;;
		*)
			#return 1
                        echo ''
                        return 1;;
		esac
        else
         if [ ${ominas_auto_u} == 1 ] ; then
           return 1
         fi
	fi
        if [ ${2} == "NOASK" ]; then
          datapath=~/ominas_data/${dat}
          datapath=`eval echo ${datapath}`
          inst[${1}]=${datapath}
          dins=${datapath}
          ./util/downloader/download_$dat.sh ${datapath} -lm --quiet=${OMINAS_INST_QUIET}
          if [ ${3} == "NODEMO" ]; then
           DFLAG="false"
           demost="NOT CONFIGURED"
          fi         
          return 1
        fi
        if [ ${ominas_auto} == 1 ] ; then
          echo "Auto option selected in the main menu; will download and place the $dat data at ~/ominas_data/${dat}"
          datapath=~/ominas_data/${dat}
          datapath=`eval echo ${datapath}`
          if ! ./util/downloader/download_$dat.sh ${datapath} -lm --quiet=${OMINAS_INST_QUIET} ; then
            unset inst[${1}]
            return 1
          fi
        else
          read -rp "Do you need to download the $dat data? [y]" ansk
          if [[ -z "${ansk// }" ]]; then
            ansk=y
          fi
          case $ansk in
           [Yy]*)
             read -rp "Please enter the location where the downloaded ${dat} data will be placed: [~/ominas_data/${dat}]" datapath
             if [ -z ${datapath} ] ; then
               datapath=~/ominas_data/${dat}
             fi
             datapath=`eval echo ${datapath}`
             if ! ./util/downloader/download_$dat.sh ${datapath} -lm --quiet=${OMINAS_INST_QUIET} ; then
               unset inst[${1}]
               return 1
             fi ;;
           *)
	     read -rp "Please enter the path to $dat [~/ominas_data/${dat}]: " datapath
             if [ -z ${datapath} ] ; then
               datapath=~/ominas_data/${dat}
             fi
             datapath=`eval echo ${datapath}`
          esac 
        fi
        datapath=`eval echo ${datapath}`
	if ! [[ -d $datapath ]]; then
		#setdir $dat
                echo ""
	fi
        #echo "args: ${1}"
        inst[${1}]=${datapath}
        dins=${datapath}
        if [ ${3} == "NODEMO" ]; then
          DFLAG="false"
          demost="NOT CONFIGURED"
        fi
	#echo "NV_${dat}_DATA=$datapath; export NV_${dat}_DATA" >>$setting
}

function pkins()
{
	# INSTALL PACKAGE ---------------------------------------------------#
	#    Install the name mission package to bash_profile.               #
	#    Arg 1 -> Name of package to be installed                        #
	#    Arg 2 -> Name of the kernel package name                        #
	#    Checks if the named package is already written to the bash      #
	#    sett  ings file before writing a new line.                        #
	#--------------------------------------------------------------------#
	#if [[ $1 == "ominas_env_def.$shtype" ]] && [[ $2 == $no ]]; then
		#read -rp "Would you like to install the demo package? " ans
		#case $ans in
		#	[Yy]*)
		#		# DFLAG sets the condition for the demo package environment
		#		# variables to be set in ominas_env_def.sh
		#		dstr="DFLAG=true; "		;;
		#	*)
		#		dstr="DFLAG=false; "
		#		printf "Demo package will not be installed...\n"
		#esac
        if [[ $1 == "ominas_env_def.$shtype" ]]; then
                if [[ "$2" == "$no" ]]; then
                  printf "Settiing OMINAS Core...\n"
                fi
                pstr=". ${OMINAS_RC}/config/$1"
                if [[ "$3" == "coreu" ]] ; then
                  if [ ${ominas_auto} == 1 ] ; then
                    return 1
                  fi
#                pstr=". ${OMINAS_RC}/config/$1"
                  if grep -q $1 ${setting}; then
                    if [ ${ominas_auto_u} != 1 ] ; then
                      read -rp "Would you like to unconfigure the OMINAS core (y/n)[n]? " ans
                    else
                      ans="y"
                    fi
                    case $ans in
                    [Yy]*)
                          $idlbin -e "!path+=':'+file_expand_path('./util/downloader')+':'+file_expand_path('./util/')& ominas_paths_remove,orc='${OMINAS_RC}'"
                          . "${OMINAS_RC}/idlpath.sh"
                          pstr="unset NV_TRANSLATORS"
                          unset NV_TRANSLATORS;;
                          #corest=${no};;
                    *)
                      return 1 ;;
                    esac
                  fi
                fi
                ins_ominas_env_def=${pstr}
                #corest=${yes}
	fi
        if [[ ! $1 == "ominas_env_def.$shtype" ]]; then
          if grep -q ${1} ${setting}; then
            if [ ${ominas_auto} == 1 ] ; then
              return 1
            fi
            loc=(`grep ${1} ${setting}`)
            echo "${3} seems to be already installed at ${loc[2]}"
            if [ ${ominas_auto_u} != 1 ] ; then
              read -rp "Would you like to unconfigure ${3} (y/n)[n]? " ans
            else
              ans="y"
            fi
            #echo "1 ${1} 2 ${2} 3 ${3} 4 ${4}"
            case $ans in
                [Yy]*)
                     #echo "!path+=':./util/downloader'& delete_ominas_files,'${loc[2]}' & exit"
                     #$idlbin -e "!path+=':./util/downloader'& delete_ominas_files,'${loc[2]}',conf=${ominas_auto_u} & exit"
                     $idlbin -e "!path+=':'+file_expand_path('./util/downloader')+':'+file_expand_path('./util/')& delete_ominas_files,'${loc[2]}',conf=${ominas_auto_u}+${ominas_nodel} & exit"

                     #unset insp[${3}]
                     #unset ins[${3}]
                     insp[${4}]=' '
                     ins[${4}]=' '
                     #echo "${insp}"
                     #export insp
                     #export ins
                     #DFLAG="false"
                     #demost="NOT CONFIGURED"
                     return 1 ;;

                    *)
                     ins[${4}]=`grep ${1} ${setting}`
                     insp[${4}]=${loc[2]}
                     return 1;;
            esac
            echo "${insp[${4}]}"
          else
            if [ ${ominas_auto_u} == 1 ] ; then
              return 1
            fi
          fi
          printf "Installing package $1...\n"
          dstr=""
	  #read -rp "Would you like to add the $3 kernels to the environment? " ans
	  #case $ans in
	#	[Yy]*)

                      if [ ${ominas_auto} == 1 ] ; then
                        echo "Auto option selected in the main menu; will download and place the $3 kernels at ~/ominas_data/${3}"
                        datapath=~/ominas_data/${3}
                        datapath=`eval echo ${datapath}`
                        if ! ./util/downloader/download_$2.sh ${datapath} -lm --quiet=${OMINAS_INST_QUIET} ; then
                          unset insp[${4}]
                          unset ins[${4}]
                          return 1
                        fi
                        pstr="${dstr}. ${OMINAS_RC}/config/$1 ${datapath}"
                      else
                        read -rp "Do you need to download the $3 kernels from PDS? [y]" ansk
                        if [[ -z "${ansk// }" ]]; then
                          ansk=y
                        fi
                        case $ansk in
                          [Yy]*)
                            read -rp "Please enter the location where the downloaded $3 kernel pool will be placed: [~/ominas_data/${3}]" datapath
                            if [ -z ${datapath} ] ; then
                              datapath=~/ominas_data/${3}
                            fi
                            datapath=`eval echo ${datapath}`
                            if ! ./util/downloader/download_$2.sh ${datapath} -lm --quiet=${OMINAS_INST_QUIET} ; then
                              unset insp[${4}]
                              unset ins[${4}]
                              return 1
                            fi
                            pstr="${dstr}. ${OMINAS_RC}/config/$1 ${datapath}";;
                          *)
			    read -rp "Please enter the location of your existing $3 kernel pool: [~/ominas_data/${3}]" datapath
                            if [ -z ${datapath} ] ; then
                              datapath=~/ominas_data/${3}
                            fi
                            datapath=`eval echo ${datapath}`
			    if ! [[ -d $datapath ]]; then
			    	#setdir $2
                                echo ""
			    fi
			    pstr="${dstr}. ${OMINAS_RC}/config/$1 ${datapath}";;
                        esac
                      fi
#		*)
#			pstr="${dstr}. ${OMINAS_RC}/config/$1"
#	  esac
          ins[${4}]=${pstr}
          insp[${4}]=${datapath}
          DFLAG="false"
          demost="NOT CONFIGURED"
        fi
	dstr=""
	#grep -v ".*$1.*" $setting >$HOME/temp
	#mv $HOME/temp $setting
	#echo $pstr >> $setting
        ins_DEMO=${DFLAG}
}

function setdir() {
	# SET DIRECTORY -----------------------------------------------------#
	#    Set the location of a data set, in particular a kernel pool.    #
	#    Arg 1 -> Name of data pool to detect                            #
	#    Data pool location must have name of data type to be detected,  #
	#    for example the tycho catalog must be in a folder called        #
	#    tychox (x is based on the version number), but is not case      #
	#    sensitive.                                                      #
	#--------------------------------------------------------------------#
	searchdir=$HOME
	if ! [ -z ${2+x} ]; then searchdir=$2; fi
	printf "Attempting to automatically find data location from $searchdir...\n"
    dirlist=()
    while IFS= read -rd $'\0'; do
        dirlist+=("$REPLY")
    done < <(find $HOME -type d -iname $1 -print0 2>/dev/null)
    if [ -z ${dirlist[0]} ]; then
        printf "Warning: directory not found\n" 1>&2
        read -rp "Would you like to expand the search? (may take time) " ans
		case $ans in
		[Yy]*)
			setdir $1 "/" 	;;
		*)
			datapath=""
			return 2
		esac
    fi
    printf '%s\n' "${dirlist[@]}" | nl
    read -rp "Please type the number of the matching directory:  " match
	n=$(($match - 1))
	datapath=${dirlist[$n]}
}

function writesetting() {

echo "#!/usr/bin/env bash" > ~/.ominas/ominasrc

cat ${OMINAS_DIR}/config/bashcomments.txt >> ~/.ominas/ominasrc

echo "alias ominas=~/.ominas/ominas" >> ~/.ominas/ominasrc
echo "alias ominasde=~/.ominas/ominasde" >> ~/.ominas/ominasrc
echo ". ~/.ominas/idlpath.sh" >> ~/.ominas/ominasrc
echo 'alias brim="ominas brim.bat -args "' >> ~/.ominas/ominasrc
echo 'alias grim="ominas grim.bat -args "' >> ~/.ominas/ominasrc
echo 'alias rim="ominas rim.bat -args "' >> ~/.ominas/ominasrc


echo "writing "$setting
if [ -e "$setting" ]; then
  rm -f ${osetting}
  cp -avf $setting $osetting
else
  touch $osetting
fi
chmod a+rx $setting

echo "#!/usr/bin/env bash" > ${setting}

cat ${OMINAS_DIR}/config/bashcomments.txt >> ${setting}

cat ${OMINAS_RC}/idlpath.sh >> ${setting}
echo "#The following line, to load the new Xdefaults definition, is commented to avoid problems in systems where xrdb is not available." >> ${setting}
echo "#If you would like to enable it, copy this line to you ~/.bashrc  /  ~/.bash_profile" >> ${setting}
echo "#Uncommenting that line here n ominas_setup.sh is not recommended, as this file will be overwritten the next time you use configure.sh" >> ${setting}
echo "#xrdb -merge ${OMINAS_RC}/Xdefaults-grim" >> ${setting}
#echo "alias ominas=~/.ominas/ominas" >> ${setting}
#echo "alias ominasde=~/.ominas/ominasde" >> ${setting}
#echo 'alias brim="ominas brim.bat -args "' >> ${setting}
#echo 'alias grim="ominas grim.bat -args "' >> ${setting}
#echo 'alias rim="ominas rim.bat -args "' >> ${setting}

#if [[ -n "$ins_ominas_env_def" ]]; then
#if [[ ${corest} == ${yes} ]]; then
  echo "export OMINAS_DIR=${OMINAS_DIR}" >> ${setting}
  echo "export OMINAS_DATA=${OMINAS_DATA}" >> ${setting}
  echo "export OMINAS_RC=${OMINAS_RC}" >> ${setting}
  echo "export OMINAS_TMP=${OMINAS_TMP}" >> ${setting}
  echo "if [ ! -w ${OMINAS_TMP} ]; then mkdir -p ${OMINAS_TMP}; fi" >> ${setting}
#fi

#Generic Kernels must come first

        d=0
        dat=${Data[$d]}
        if [ -z ${inst[$d]+x} ]  ;then
          echo "unset NV_${dat}_DATA" >>${setting}
        else
          echo "export NV_${dat}_DATA=${inst[$d]}" >>${setting}
          if [ ! -z ${insts[$d]+x} ]  ;then
            echo ${insts[$d]} >>${setting}
          fi
        fi



echo "export DFLAG=${DFLAG}" >> $setting
echo $ins_ominas_env_def >> $setting
#echo "export CAM_NFILTERS=256" >> $setting

for ((d=1; d<${#Data[@]}; d++));
do
        dat=${Data[$d]}
        #echo "$d: ${inst[$d]}"
        #if grep -q NV_${Data[$d]}_DATA $setting; then
        if [ -z ${inst[$d]+x} ]  ;then
          #echo "${d}:0 ${inst[$d]}"
          #echo "unset NV_${dat}_DATA" >>${setting}
          cat <<VARCMD >> ${setting}
if [ \`echo "\$NV_${dat}_DATA" | grep -Eco "\${OMINAS_DIR}/demo/data(/?)\$"\` == 0 ]; then unset NV_${dat}_DATA; fi
VARCMD
        else 
          #echo "$d: ${inst[$d]}"
          #echo "${d}:i ${inst[$d]}"
          
          echo "export NV_${dat}_DATA=${inst[$d]}" >>${setting}
          if [ ! -z ${insts[$d]+x} ]  ;then
            echo ${insts[$d]} >>${setting}
          fi
        fi
done
#echo $ins_ominas_env_def >> $setting

for ((d=0; d<6; d++));
do
        #echo "$d: ${insp[$d]}"
        #if grep -q NV_${Data[$d]}_DATA $setting; then
        if [ -z ${insp[$d]+x} ]  ;then
          echo "" #"${d}:0 ${ins[$d]}"
        else
          #echo "$d: ${ins[$d]}"
          #echo "${d}:i ${ins[$d]}"
          echo "${ins[$d]}" >>${setting}
        fi
done
echo "export PG_MAPS=\${NV_MAPS_DATA}" >> ${setting}
echo ". ~/.ominas/ominas_postsetup.sh" >> ${setting}

#make ominas script
echo "#!/usr/bin/env bash" > ~/.ominas/ominas

cat ${OMINAS_DIR}/config/bashcomments.txt >> ~/.ominas/ominas

#head -1 ${idlbin} > ~/.ominas/ominas
asetting=`eval echo ${setting}`
echo ". ${asetting}" >> ~/.ominas/ominas

#echo "if [ "\$#" -eq 0 ]; then args=\"\${OMINAS_DIR}/util/printver.pro\"; else args=("\$@"); fi" >> ~/.ominas/ominas
echo "if [ \$# -eq 0 ]; then args=\"\${OMINAS_DIR}/util/printver.pro\"" >> ~/.ominas/ominas
echo "else" >> ~/.ominas/ominas
echo " for arg in \$@; do" >> ~/.ominas/ominas
echo "  if [[ \$arg == --* ]] ; then _args+=(\$arg)" >> ~/.ominas/ominas
echo "  elif [[ \$arg == *==* ]] ; then _args+=(\$arg)" >> ~/.ominas/ominas
echo "  elif [[ \$arg == +* ]] ; then export \${arg:1:127}" >> ~/.ominas/ominas
echo "  else args+=(\$arg)" >> ~/.ominas/ominas
echo "  fi" >> ~/.ominas/ominas
echo " done" >> ~/.ominas/ominas
echo "fi" >> ~/.ominas/ominas
echo "args+=(\\-args)" >> ~/.ominas/ominas
echo "args+=(\${_args[*]})" >> ~/.ominas/ominas


if [ -e "/opt/X11/lib/flat_namespace/" ]; then
  cat <<LDCMD >> ~/.ominas/ominas
    if [ "\${DYLD_LIBRARY_PATH}" = "" ]; then
        DYLD_LIBRARY_PATH="/opt/X11/lib/flat_namespace/"
    else
        DYLD_LIBRARY_PATH="/opt/X11/lib/flat_namespace/:\${DYLD_LIBRARY_PATH}"
    fi
LDCMD
fi
tail -n +2 ${idlbin} | sed -e "s/APPLICATION=\`basename \$0\`/APPLICATION=idl/g" >> ~/.ominas/ominas
cat ~/.ominas/ominas | sed -e "s|\"\$@\" \$APP_ARGS|-IDL_PROMPT \"'OMINAS\> '\" \"\${args[@]/#/}\" \$APP_ARGS |g" > ~/.ominas/ominas_tmp
mv -f ~/.ominas/ominas_tmp ~/.ominas/ominas
if [ "${idlversion}" \< "linux84" ] && [ "${idlversion}" \> "linux" ]; then
  ldp="LD_PRELOAD=${OMINAS_DIR}/util/downloader/libcurl.so.4"
  cat ~/.ominas/ominas | sed -e "s|exec |${ldp} exec |g" > ~/.ominas/ominas_tmp
  mv -f ~/.ominas/ominas_tmp ~/.ominas/ominas
fi
chmod a+rx ~/.ominas/ominas

#make ominasde script

echo "#!/usr/bin/env bash" > ~/.ominas/ominasde

cat ${OMINAS_DIR}/config/bashcomments.txt >> ~/.ominas/ominasde

#head -1 ${idlbin} > ~/.ominas/ominasde
asetting=`eval echo ${setting}`
echo ". ${asetting}" >> ~/.ominas/ominasde
echo "args=("\$@")" >> ~/.ominas/ominasde
if [ -e "/opt/X11/lib/flat_namespace/" ]; then
  cat <<LDCMD >> ~/.ominas/ominasde
    if [ "\${DYLD_LIBRARY_PATH}" = "" ]; then
        DYLD_LIBRARY_PATH="/opt/X11/lib/flat_namespace/"
    else
        DYLD_LIBRARY_PATH="/opt/X11/lib/flat_namespace/:\${DYLD_LIBRARY_PATH}"
    fi
LDCMD
fi
tail -n +2 ${idlbin} | sed -e "s/APPLICATION=\`basename \$0\`/APPLICATION=idlde/g" >> ~/.ominas/ominasde
cat ~/.ominas/ominasde | sed -e "s|\"\$@\" \$APP_ARGS|-IDL_PROMPT \"'OMINAS\> '\" \"\${args[@]/#/}\" \$APP_ARGS |g" > ~/.ominas/ominasde_tmp
mv -f ~/.ominas/ominasde_tmp ~/.ominas/ominasde
if [ "${idlversion}" \< "linux84" ] && [ "${idlversion}" \> "linux" ]; then
  ldp="LD_PRELOAD=${OMINAS_DIR}/util/downloader/libcurl.so.4"
  cat ~/.ominas/ominasde | sed -e "s|exec |${ldp} exec |g" > ~/.ominas/ominasde_tmp
  mv -f ~/.ominas/ominasde_tmp ~/.ominas/ominasde
fi
chmod a+rx ~/.ominas/ominasde

echo "done with writing ${setting}"



}

function icy() {

# ICY INSTALL -----------------------------------------------------------#
# Icy can be installed from the internet, or configured from a local     #
# copy. If NAIF kernels will not be used, then no action is taken.       #
# Icy is installed based on auto-detection of the OS.                    #
#------------------------------------------------------------------------#
if [ ${ominas_icyst} == 1 ] && [ ${ominas_auto} == 0 ]; then
  echo "Icy appears to be already configured:"
  echo ${ominas_icytest}
  if [ ${ominas_auto_u} != 1 ] ; then
    read -rp "Do you wish to uninstall Icy (y/n)[n]?"  ans
  else
    ans="y"
  fi
  case ${ans} in
    [Yy]*)
           if [ ${ominas_auto_u} != 1 ] ; then
             read -rp "Do you wish to remove every Icy occurence in your path - not just the one installed by OMINAS - (y/n)[n]?"  ansa
           else
             ansa="n"
           fi
           case ${ansa} in
             [Yy]*)
               removeall=1;;
             *)
              removeall=0;;
           esac
           $idlbin -e "!path+=':'+file_expand_path('./util/downloader')+':'+file_expand_path('./util/') & ominas_icy_remove,all=${removeall},orc='${OMINAS_RC}' & exit"
           . "${OMINAS_TMP}/idlpathr.sh"
           rm -f "${OMINAS_TMP}/idlpathr.sh"
           . "${OMINAS_RC}/idlpath.sh"
#           if [ -e idlpathr.sh ]; then 
#             source idlpathr.sh
#           fi
           ominas_icyst=0
           icypath=''
           return 1;; 
        *) return 1;;
  esac
else
  if [ ${ominas_auto_u} == 1 ] && [ ${change_demo} == 0 ] ; then
    return 1
  fi
fi


printf "OMINAS requires the NAIF Icy toolkit to process SPICE kernels.\n"
#read -rp "Would you like to configure Icy for OMINAS? [y]" ans
ans=y
if [[ -z "${ans// }" ]]; then
 ans=y
fi
case $ans in
	[Yy]*)
		icyflag=true
                if [ ${ominas_auto} == 1 ] ; then
                  echo "Auto option selected in the main menu; will download and configure Icy at ~/ominas_data/icy"
                  ans=y
                else
		  read -rp "Would you like to install Icy from the internet now? [y]" ans
                fi
                if [[ -z "${ans// }" ]]; then
                  ans=y
                fi
		case $ans in
			[Yy]*)
				bits=$(uname -m); if [[ $bits == "x86_64" ]]; then bstr="64bit"; else bstr="32bit"; fi
				os=$(uname -s); if [[ $os == "Darwin" ]]; then ostr="MacIntel_OSX_AppleC"; else ostr="PC_Linux_GCC"; fi
				#curl -L "http://naif.jpl.nasa.gov/pub/naif/toolkit//IDL/${ostr}_IDL8.x_${bstr}/packages/icy.tar.Z" >"../icy.tar.Z"
                                echo "http://naif.jpl.nasa.gov/pub/naif/toolkit//IDL/${ostr}_IDL8.x_${bstr}/packages/icy.tar.Z" ${OMINAS_TMP} #"~/ominas_data/icy.tar.Z"
                                #curl -L "http://naif.jpl.nasa.gov/pub/naif/toolkit//IDL/${ostr}_IDL8.x_${bstr}/packages/icy.tar.Z" > ~/ominas_data/icy.tar.Z
                                ldir=`eval echo ~/ominas_data/`
                                ./util/downloader/pp_wget "http://naif.jpl.nasa.gov/pub/naif/toolkit//IDL/${ostr}_IDL8.x_${bstr}/packages/icy.tar.Z" --localdir=${OMINAS_TMP}
                                owd=$PWD
				#cd ..
                                cd ~/ominas_data/
				cdflag=true
				#ext "icy.tar.Z"
				#ext "icy.tar"
                                echo "Extracting Icy source files..."
                                tar -xzf "${OMINAS_TMP}/icy.tar.Z" >& /dev/null
                                #rm -vf "${OMINAS_TMP}/icy.tar.Z"
				cd icy
				icypath=${PWD}
                                echo "Trying to use precompiled binaries..."
                                if [ -e ./lib/._icy.dlm ]; then rm -vf ./lib/._icy.dlm; fi
                                if [ -e ./lib/._icy.so ]; then rm -vf ./lib/._icy.so; fi
                                binary_icytest=`$idlbin -IDL_DLM_PATH "<IDL_DEFAULT>:${icypath}/lib/" -e "!path+=':'+file_expand_path('${OMINAS_DIR}/util/downloader')+':${icypath}/lib/' & ominas_icy_test"  2> /dev/null`
                                if [ $? == 0 ] ; then
                                  echo "Success: ${binary_icytest}"
                                else
                                  echo "Precompiled binary failed: ${binary_icytest}"
                                  echo "Trying to build Icy..."
				  /bin/csh makeall.csh >& ~/.ominas/icy_make.log
                                  echo "Icy compiled. Log is at ~/.ominas/icy_make.log"
                                fi
				cd $OMINAS_DIR	;;
			*)
				read -rp "Please enter the location of the Icy install directory [~/ominas_data/icy/]: " datapath
                                if [ -z ${datapath} ] ; then
                                  datapath=~/ominas_data/icy
                                fi
                                datapath=`eval echo ${datapath}`
				if ! [[ -d $datapath ]]; then
					#setdir "icy"
                                        echo ""
				fi
				icypath=$datapath
		esac	;;
	*)
		icyflag=false
		printf "Icy not configured for OMINAS.\n"
esac 

}

printf "The setup will guide you through the installation of OMINAS\n"
printf "More help is in the Install Guide, at https://nasa.github.io/ominas/guides/userguide.html\n"

#if ! grep -q "OMINAS_DIR=.*; export OMINAS_DIR" ${setting}; then
# NOTE: OMINAS is available in repository form. Extraction is no longer needed
#	printf "Unpacking OMINAS tar archive...\n"
#	ext ominas_ringsdb_*.tar.gz
# DIR is set on line 82 and is the absolute path to the configure.sh script
	OMINAS_DIR=$DIR
#	echo "OMINAS_DIR=$OMINAS_DIR; export OMINAS_DIR" >> $setting
#fi



printf "OMINAS files located in $OMINAS_DIR\n"

function main() {

if [ -z ${OMINAS_INST_QUIET+x} ]; then
  OMINAS_INST_QUIET=1
fi

if [ -e "$setting" ]; then
  . $setting
fi

export OMINAS_DIR=${DIR}


export OMINAS_CF="${OMINAS_DIR}/util/downloader/ca-bundle.crt"
if [ -z ${idlversion+x} ]; then
  idlversion="z"
fi
if [ "${idlversion}" == "" ]; then
  idlversion="z"
fi
ldp=""
if [ "${idlversion}" \< "linux84" ] && [ "${idlversion}" \> "linux" ]; then
  ldp="${OMINAS_DIR}/util/downloader/libcurl.so.4"
fi
export OMINAS_LDP=${ldp}

# Ascertain the status of each package (INSTALLED/NOT INSTALLED) or (SET/NOT SET)
corest=`pkst ${OMINAS_DIR}/config/tab/`
grep -q ". ${OMINAS_RC}/config/ominas_env_def.sh" ${setting}
corest=$?
if [ ${corest} == 0 ] ; then
  corest=${yes}
else
  corest=${no}
fi
demost=$no
DFLAG="false"
#if [ ! -z $OMINAS_DEMO ]; then
if grep -q "export DFLAG=true" $setting; then
 demost="CONFIGURED"
 DFLAG="true"
fi

declare -a mis=("cas" "gll" "vgr" "juno")
#declare -a Data=("Generic_kernels" "SEDR" "TYCHO2" "SAO" "GSC" "UCAC4")
#declare -a Data=("Generic_kernels" "TYCHO2" "UCAC4" "SAO" "GSC" )
declare -a Data=("Generic_kernels" "TYCHO2" "SAO" "MAPS" "UCAC4" "GSC" )
declare -a insts=("" "" "" "" "")
insts[1]=". ${OMINAS_RC}/config/ominas_env_strcat.sh tycho2"
insts[2]=". ${OMINAS_RC}/config/ominas_env_strcat.sh sao"
insts[4]=". ${OMINAS_RC}/config/ominas_env_strcat.sh ucac4"
insts[5]=". ${OMINAS_RC}/config/ominas_env_strcat.sh gsc"
for ((d=0; d<${#mis[@]}; d++));
do
	#mstatus[$d]=`pkst ${OMINAS_DIR}/config/${mis[$d]}/`
        if grep -q "${OMINAS_RC}/config/ominas_env_${mis[$d]}" $setting; then
          mstatus[$d]=$yes
          tmp=`grep "${OMINAS_RC}/config/ominas_env_${mis[$d]}" $setting`
          read -r -a tmps <<< ${tmp}
          insp[$d]=${tmps[2]}
          ins[$d]=${tmp}
        else
          mstatus[$d]=$no
        fi
done
#export insp
#export ins
for ((d=0; d<${#Data[@]}; d++));
do
	if grep -q "export NV_${Data[$d]}_DATA" $setting; then
        #if [  -z {NV_${Data[$d]}_DATA+x} ]; then
		dstatus[$d]=$st
                tmp=`grep "export NV_${Data[$d]}_DATA" $setting`
                IFS='=' read -ra tmpa <<< "$tmp"
                inst[$d]=${tmpa[1]}
	else
                #echo "{NV_${Data[$d]}_DATA}"
		dstatus[$d]=$ns
	fi
done
#export inst
#$idlbin -e 'exit,status=strmatch(pref_get("IDL_DLM_PATH"),"*icy/lib*")'
ominas_icytest=`$idlbin -e "!path+=':'+file_expand_path('./util/downloader') & ominas_icy_test"  2> /dev/null`
if [ $? == 0 ] ; then
  icyst='CONFIGURED'
  icypath=${ominas_icytest}
  ominas_icyst=1
else
  icyst='NOT CONFIGURED'
  ominas_icyst=0
  icypath=''
fi
echo "Icy: ${ominas_icytest}"
export ominas_icyst
echo $idlbin
OMINAS_TMP=`$idlbin -e "print,filepath('_${USER}_ominas',/tmp)" | tail -1  2> /dev/null`
echo $OMINAS_TMP
#OMINAS_TMP="${OMINAS_RC}/tmp"
if [ ! -w "${OMINAS_TMP}" ]; then
  mkdir -p ${OMINAS_TMP}
fi
echo "OMINAS_TMP=${OMINAS_TMP}"
export OMINAS_TMP
if [ ${OMINAS_INST_QUIET} == "1" ]; then

echo "IDL_PATH: ${IDL_PATH}"
# Print the configuration list with all statuses to stdout
cat <<PKGS
=============================================================================
	Current OMINAS configuration settings
Required:
	1) OMINAS Core  . . . . . . . . . . . . .  $corest
           Contains the OMINAS code. If you select only one 
           of the other packages, this will be included.
Optional packages:
        2) Demo package . . . . . . . . . . . . .  $demost
           Contains the demo scripts and the data required 
           to run then.
           These files are always present (in ominas/demo), 
           this option is to set up the environment so that
           the demos can be run.
        3) SPICE Icy  . . . . . . . . . . . . . .  $icyst
           Library maintained by JPL's NAIF (Navigation and Ancillary
           Information Facility, https://naif.jpl.nasa.gov/naif/toolkit.html,
           required to use spacecraft / planetary kernel files.

Mission Packages:
           Kernels used for each mission's position and 
           pointing data. If you do not already have them,
           an option to download them from PDS will be provided.
           If you already have them, you will need to provide
           the path to your kernel files.
           Note: the NAIF Generic Kernels (one of the optional 
           data packages) are not required for the missions, they
           already contain a copy the subset of the generic kernel
           files they need.
	4) Cassini . . . . . . . . . . . . . . . . ${mstatus[0]}
           Subsetted, about 16 GB as of Dec/2016
	5) Galileo (GLL) . . . . . . . . . . . . . ${mstatus[1]}
           About 833 MB as of Dec/2016
	6) Voyager . . . . . . . . . . . . . . . . ${mstatus[2]}
           About 163 MB as of Dec/2016
        7) Juno  . . . . . . . . . . . . . . . . . ${mstatus[3]}
           Subsetted, about 22 GB as of Feb/2018
Data:
        8) NAIF Generic Kernels  . . . . . . . . . ${dstatus[0]}
           About 22 GB as of Dec/2016
        9) Tycho2 star catalog . . . . . . . . . . ${dstatus[1]}
           About 161 MB download, 665 MB unpacked
       10) SAO star catalog  . . . . . . . . . . . ${dstatus[2]}
           Already provided with OMINAS, no download needed
       11) Maps
           Map library created for use with OMINAS ${dstatus[3]}
           About 813 MB as of August/2017
       12) UCAC4 star catalog  . . . . . . . . . . ${dstatus[4]}
           About 8.5 GB download
       13) GSC star catalog  . . . . . . . . . . . ${dstatus[5]}

For more information, see
https://nasa.github.io/ominas/guides/userguide.html
PKGS

else

# Print the configuration list with all statuses to stdout
cat <<PKGS
=============================================================================
        Current OMINAS configuration settings
Required:
        1) OMINAS Core  . . . . . . . . . . . . .  $corest
           Contains the OMINAS code. If you select only one 
           of the other packages, this will be included.
Optional packages:
        2) Demo package . . . . . . . . . . . . .  $demost
           Contains the demo scripts and the data required 
           to run then.
           These files are always present (in ominas/demo), 
           this option is to set up the environment so that
           the demos can be run.
        3) SPICE Icy  . . . . . . . . . . . . . .  $icyst
           Library maintained by JPL's NAIF (Navigation and Ancillary
           Information Facility, https://naif.jpl.nasa.gov/naif/toolkit.html,
           required to use spacecraft / planetary kernel files.

Mission Packages:
           Kernels used for each mission's position and 
           pointing data. If you do not already have them,
           an option to download them from PDS will be provided.
           If you already have them, you will need to provide
           the path to your kernel files.
           Note: the NAIF Generic Kernels (one of the optional 
           data packages) are not required for the missions, they
           already contain a copy the subset of the generic kernel
           files they need.
        4) Cassini . . . . . . . . . . . . . . . . ${mstatus[0]}
           Subsetted, about 16 GB as of Dec/2016
        5) Galileo (GLL) . . . . . . . . . . . . . ${mstatus[1]}
           About 833 MB as of Dec/2016
        6) Voyager . . . . . . . . . . . . . . . . ${mstatus[2]}
           About 163 MB as of Dec/2016
        7) Juno  . . . . . . . . . . . . . . . . . ${mstatus[3]}
           Subsetted, about 9 GB as of Feb/2018
Data:
        8) NAIF Generic Kernels  . . . . . . . . . ${dstatus[0]}
           About 22 GB as of Dec/2016
        9) Tycho2 star catalog . . . . . . . . . . ${dstatus[1]}
           About 161 MB download, 665 MB unpacked
       10) SAO star catalog  . . . . . . . . . . . ${dstatus[2]}
           Already provided with OMINAS, no download needed
       11) Maps
           Map library created for use with OMINAS ${dstatus[3]}
           About 813 MB as of August/2017
       12) UCAC4 star catalog  . . . . . . . . . . ${dstatus[4]}
           About 8.5 GB download
       13) GSC star catalog  . . . . . . . . . . . ${dstatus[5]}

For more information, see
https://nasa.github.io/ominas/guides/userguide.html
PKGS



fi

pr=1
while [ $pr == 1 ]; do
read -rp "Modify Current OMINAS configuration (Exit/Auto/Uninstall 1 2 ...)?  " ans
aans=($ans)
if [ "${aans[0]}" == "" ]; then
  aans[0]="null"
fi
ominas_auto=0
if [ ${aans[0]} == "auto" ] || [ ${aans[0]} == "a" ] || [ ${aans[0]} == "A" ] || [ ${aans[0]} == "Auto" ] || [ ${aans[0]} == "AUTO" ]; then

  cat <<AUTOP

  You have selected the auto option for OMINAS setup.

  This option will download and configure every package, to their
default locations, without prompting for confirmation or install
directories. If data packages are not already present in the default
directories, they will be downloaded, which may take a long time and
several GB of disk space. If any files to be downloaded are already
present in their default location, their download will be skipped.


AUTOP

  read -rp "Proceed? [y]" ansy
  if [[ -z "${ansy// }" ]]; then
    ansy=y
  fi
  if [ ${ansy} == "y" ] || [ ${ansy} == "Y" ]; then
    ominas_auto=1
    ans="1 2 3 4 5 6 7 8 9 10 11 12"
  else
    ans="all"
  fi
fi
export ominas_auto

ominas_auto_u=0
ominas_nodel=0
if [ ${aans[0]} == "uninstall" ] || [ ${aans[0]} == "u" ] || [ ${aans[0]} == "U" ] || [ ${aans[0]} == "Uninstall" ] || [ ${aans[0]} == "UNINSTALL" ]; then

  cat <<AUTOP

  You have selected the auto option for uninstalling OMINAS.

  This option will uninstall every package from their current locations, 
without prompting for confirmation.


AUTOP

  read -rp "Proceed? [y]" ansy
  if [[ -z "${ansy// }" ]]; then
    ansy=y
  fi
  if [ ${ansy} == "y" ] || [ ${ansy} == "Y" ]; then
    ominas_auto_u=1
    ans="3 4 5 6 7 8 9 10 11 12 13 2 1"
  else
    ans="uall"
  fi
fi
export ominas_auto_u


pr=0
for num in $ans
do
  if [ $num == "2" ]; then
    if [ $DFLAG  == "true" ] && [ "${ominas_auto}" == "0" ]  ; then
      DFLAG="false"
      demost="NOT CONFIGURED"
    else
      DFLAG="true"
      demost="CONFIGURED"
      ominas_auto_u=1
      ominas_nodel=2
      #ans="3 4 5 6 8 9 10"
    fi
    if [ "${ominas_auto_u}" == "1" ] && [ "${ominas_nodel}" != "2" ] ; then
      DFLAG="false"
      demost="NOT CONFIGURED"
    fi
  fi
done
change_demo=0
if [ "${ominas_nodel}" == "2" ]; then
  for num in $ans
  do
    if [ $num == "3" ]; then
      change_demo=1
    fi
  done
  if [ $change_demo == "1" ]; then
    ans="3 4 5 6 7 8 9 10 11 12 13"
  else
    ans="4 5 6 7 8 9 10 11 12 13"
  fi
fi
for num in $ans
do
	case $num in
		[eE]|exit|Exit|EXIT)
                                pr=0
				return	3;;
		[1])            
                                pr=0
				pkins ominas_env_def.sh "${corest}" coreu
                                #corest=${yes}
							;;
                [2])
                                pr=0
                                #pkins ominas_env_def.sh "${corest}" demo
                                #corest=${yes}
                                                        ;;
                [3])
                                pr=0
                                icy
                                                        ;;

		#[Nn]*)
		#		break 		;;
		[4567])
                                pr=0
				pkins ominas_env_def.sh "${corest}" $(($num-4))
                                #corest=${yes}
                                #DFLAG="false"
                                #demost="NOT CONFIGURED"
				ppkg $(($num-4)) 	;;
                8)
                                pr=0
                                pkins ominas_env_def.sh "${corest}" $(($num-8))
                                #corest=${yes}
                                dins $(($num-8)) ASK NODEMO;;
		[9]|11|12|13)
                                pr=0
                                pkins ominas_env_def.sh "${corest}" $(($num-8))
                                #corest=${yes}
				dins $(($num-8)) ASK NODEMO;;
                10)
                                pr=0
                                pkins ominas_env_def.sh "${corest}" $(($num-8))
                                #corest=${yes}
                                dins $(($num-8)) NOASK NODEMO;;
                all)            pr=0;;
                uall)           pr=0;;
		*)
				printf "Error: Invalid package or catalog specified\n" 1>&2
                                pr=1;;
    esac
done


done


test "$1" == ".*c.*" &&
for f in ./ominas_env_*.sh
do
	printf "Installing custom package $f...\n"
	pkins $f
done


#------------------------------------------------------------------------#
# Writes an IDL script to check if the IDL path has been written. If     #
# it has not, the path to the OMINAS directory will be written in the    #
# IDL_PATH, inside of IDL.                                               #
#------------------------------------------------------------------------#
#if [ $ominas_icyst == 1 ]; then
#  icyflag=true
   
#else
#  icyflag=false
#fi
#cat <<IDLCMD >paths.pro
#flag='$icyflag'
#path=getenv('IDL_PATH') ? getenv('IDL_PATH') : PREF_GET('IDL_PATH')
#;IF STRPOS(path, '$icypath') EQ -1 AND flag EQ 'true' THEN path=path+':+$icypath/lib/'
#IF STRPOS(path, '/home/spitale/ominas') EQ -1 THEN begin &$
# path=path+':+/home/spitale/ominas' &$
# if getenv('IDL_PATH') then begin &$ 
#   openw,lun,'idlpath.sh',/get_lun &$ 
#   printf,lun,'export IDL_PATH="'+path+'"' &$ 
#   free_lun,lun &$ 
# endif else PREF_SET, 'IDL_PATH', path, /COMMIT &$
#endif else file_delete, 'idlpath.sh'
#dlm_path=getenv('IDL_DLM_PATH') ? getenv('IDL_DLM_PATH') : PREF_GET('IDL_DLM_PATH')
#;IF STRPOS(dlm_path, '$icypath') EQ -1 AND flag EQ 'true' THEN dlm_path=dlm_path+':+$icypath/lib/'
#;if getenv('IDL_DLM_PATH') then begin &\$
#;  openw,lun,'idlpath.sh',/get_lun,/append &\$ 
#;  printf,lun,'export IDL_DLM_PATH="'+dlm_path+'"' &\$ 
#;  free_lun,lun &\$ 
#;endif else PREF_SET, 'IDL_DLM_PATH', dlm_path, /COMMIT
#PRINT, '$OMINAS_DIR added to IDL_PATH'
#!path+=':$OMINAS_DIR/util/:$OMINAS_DIR/util/downloader/'
#idlastro_download,/auto
#EXIT
#IDLCMD

#if [ "$IDL_DIR" = "" ]; then
#        idl=`which idl`
#        idlbin=$idl
#        if [ "$idl" = "" ]; then
#          read -rp "IDL not found. Please enter the location of your IDL installation (such as /usr/local/exelis/idl85): " idldir
#          IDL_DIR="$idldir"
#          export IDL_DIR
#          printf "Using IDL from $IDL_DIR\n"
#          idlbin=$IDL_DIR/bin/idl
##          $IDL_DIR/bin/idl paths.pro
#        else
#          printf "Using IDL at $idl\n"
##          $idl paths.pro
#        fi
#else
#        printf "IDL_DIR found, $IDL_DIR, using it\n"
#        idlbin=$IDL_DIR/bin/idl
##        $IDL_DIR/bin/idl paths.pro
#fi



writesetting
if [ -e "${setting}" ]; then
  . ${setting}
fi


grep -q ". ${OMINAS_RC}/config/ominas_env_def.sh" ${setting}
corest=$?
if [ ${corest} == 0 ] ; then
  corest=${yes}
else
  corest=${no}
fi

if [ "${corest}" == "${yes}" ]; then
  #$idlbin paths.pro
  LD_PRELOAD=${OMINAS_LDP} $idlbin -e "!path+=':'+file_expand_path('./util/downloader')+':'+file_expand_path('./util/')& ominas_paths_add,'${icypath}',orc='${OMINAS_RC}'"
  . "${OMINAS_RC}/idlpath.sh"
#  if [ -e idlpath.sh ]; then
#    cat idlpath.sh >> $idlpathfile
#    rm -f idlpath.sh
#  fi
else
  #export OMINAS_DIR=''
  LD_PRELOAD=${OMINAS_LDP} $idlbin -e "!path+=':'+file_expand_path('./util/downloader')+':'+file_expand_path('./util/')& ominas_paths_add,'${icypath}','',orc='${OMINAS_RC}'"
  . "${OMINAS_RC}/idlpath.sh"
fi

writesetting
if [ -e "${setting}" ]; then
  . ${setting}
fi
#rm -f paths.pro
#if [ -e idlpathr.sh ]; then
#  #cat idlpathr.sh >> $idlpathfile
#  rm -f idlpathr.sh
#fi

#if [ ! -z ${IDL_PATH+x} ]; then
#  . $idlpathfile
#  printf "IDL PATH/IDL_DLM_PATH were written to $idlpathfile.\n"
#fi
#writesetting



if grep -q "[^#]*\. ~/.ominas/ominasrc" ${usersh} ; then
  echo "${usersh} already sets ominas alias"
else
  echo "if [ -s ~/.ominas/ominasrc ]; then . ~/.ominas/ominasrc; fi" >> ${usersh}
fi


if grep -q "[^#]*\. ~/.ominas/ominasrc" ${psetting} ; then
  echo "${psetting} already sets ominas alias"
else
  echo "if [ -s ~/.ominas/ominasrc ]; then . ~/.ominas/ominasrc; fi" >> ${psetting}
fi

#if grep -q "alias ominas=~/.ominas/ominas" ${usersh} ; then
#  echo "${usersh} already sets ominas alias"
#else
#  echo "alias ominas=~/.ominas/ominas" >> ${usersh}
#fi
#if grep -q "alias ominasde=~/.ominas/ominasde" ${usersh} ; then
#  echo "${usersh} already sets ominasde alias"
#else
#  echo "alias ominasde=~/.ominas/ominasde" >> ${usersh}
#fi
#printf "OMINAS aliases set in ${usersh}.\n"

#if grep -q "alias ominas=~/.ominas/ominas" ${psetting} ; then
#  echo "${psetting} already sets ominas alias"
#else
#  echo "alias ominas=~/.ominas/ominas" >> ${psetting}
#fi
#if grep -q "alias ominasde=~/.ominas/ominasde" ${psetting} ; then
#  echo "${psetting} already sets ominasde alias"
#else
#  echo "alias ominasde=~/.ominas/ominasde" >> ${psetting}
#fi
#printf "OMINAS aliases set in ${psetting}.\n"

return 0
}
echo " "
while [ 1 ]; do
  main
  if  [ $? == 3 ] ; then
    break
  fi
  
done
. ~/.ominas/ominasrc
printf "Setup has completed. It is recommended to restart your terminal session before using OMINAS.\n"
printf "You may want to try some of the tutorials at https://nasa.github.io/ominas/demo/\n"
printf "For documentation on how OMINAS works, see the User Guide at https://nasa.github.io/ominas/user_guide\n"
