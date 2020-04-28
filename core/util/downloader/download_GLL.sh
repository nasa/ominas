#!/usr/bin/env bash
#script to download a copy of the Galileo kernels from PDS
#Usage:
#./download_GALILEO.sh /directory/to/place/kernels

OWNDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
wget=${OWNDIR}/pp_wget
echo "This script wiill download all kernels from the PDS Galileo archive ("\
"http://naif.jpl.nasa.gov/pub/naif/GLL/kernels/. As of December/2016, this adds to 833MB."


if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi


baseurl="http://naif.jpl.nasa.gov/pub/naif/GLL/kernels/"
#standard download (full, nonrecursive) directories
dirs=( ek ik lsk pck sclk )

#location for timestamps files
mkdir -p ~/.ominas/timestamps/GALILEO
ts=`eval echo "~/.ominas/timestamps/"`


for dir in "${dirs[@]}"
do
 ${wget} "${baseurl}${dir}/ --localdir=${1}/$dir/ --absolute --timestamps=$ts $@"
done

#special treatment directories (spk and ck, which are large)
echo "Downloading spks"
${wget} "${baseurl}spk/ --localdir=${1}/spk/ $@ --absolute --timestamps=$ts" # --xpattern=(\.bsp$)|(\.bsp\.lbl$)"

echo "Downloading cks"
${wget} "${baseurl}ck/ --localdir=${1}/ck/ $@ --absolute --timestamps=$ts"
#${wget} "${baseurl}ck/ --localdir=$1/ck/ $@ --absolute --timestamps=~/.ominas/timestamps/ --xpattern="\
#"(\.tar\.gz$)|([[:digit:]]{5}_[[:digit:]]{5}[[:alnum:]]{2}(_(S|C)[[:digit:]]{2})?\.((pdf)|(txt))$)|(_bc_err\.txt$)" #--xpattern=(\.bc$)|(bc\.lbl$)|"

#${wget} "${baseurl}ck/ --localdir=$1/ck/ $@ --absolute --timestamps=~/.ominas/timestamps/CASSINI/ck.json --pattern="\
#"([[:digit:]]{5}_[[:digit:]]{5}(r[[:alnum:]])|([[:alnum:]]{2}_ISS))(\.bc$)|(bc\.lbl$)"
