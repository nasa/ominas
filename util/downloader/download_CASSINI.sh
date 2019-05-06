#!/usr/bin/env bash
#script to download a copy of the Cassini kernels from PDS
#Usage:
#./download_CASSINI.sh /directory/to/place/kernels

OWNDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
wget=${OWNDIR}/pp_wget
echo "This script will download a subset of kernels from the PDS Cassini archive ("\
"http://naif.jpl.nasa.gov/pub/naif/CASSINI/kernels/. As of November/2016, this adds to 16GB."

if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi


baseurl="http://naif.jpl.nasa.gov/pub/naif/CASSINI/kernels/"
#standard download (full, nonrecursive) directories
dirs=( fk ik lsk pck sclk )

#location for timestamps files
mkdir -p ~/.ominas/timestamps/CASSINI
ts=`eval echo "~/.ominas/timestamps/"`


for dir in "${dirs[@]}"
do
 #echo ${wget} "${baseurl}${dir}/ --localdir=${1}/$dir/ --absolute --timestamps=$ts $@"
 ${wget} "${baseurl}${dir}/ --localdir=${1}/$dir/ --absolute --timestamps=$ts $@"
done

echo "Downloading PSFs"
echo ${wget} "https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/coiss_0011_v4.1/calib/xpsf/ --localdir=${1}/xpsf/ -absolute --timestamps=$ts $@"
${wget} "https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/coiss_0011_v4.1/calib/xpsf/ --localdir=${1}/xpsf/ --absolute --timestamps=$ts $@"

#special treatment directories (spk and ck, which are large)
echo "Downloading spks"
${wget} "${baseurl}spk/ --localdir=${1}/spk/ $@ --absolute --timestamps=$ts " # --xpattern=(\.bsp$)|(\.bsp\.lbl$)"

echo "Downloading cks"
#${wget} "${baseurl}ck/ --localdir=$1/ck/ $@ --absolute --timestamps=~/.ominas/timestamps/ --xpattern="\
#"(\.tar\.gz$)|([[:digit:]]{5}_[[:digit:]]{5}[[:alnum:]]{2}(_(S|C)[[:digit:]]{2})?\.((pdf)|(txt))$)|(_bc_err\.txt$)" #--xpattern=(\.bc$)|(bc\.lbl$)|"

${wget} "${baseurl}ck/ --localdir=${1}/ck/ $@ --absolute --timestamps=$ts --pattern="\
"(([[:digit:]]{5}_[[:digit:]]{5}(r[[:alnum:]])|([[:alnum:]]{2}_ISS))|(17[[:digit:]]{3}_[[:digit:]]{5}[[:alnum:]]{2}_[fp]siv)|([[:digit:]]{6}_[[:digit:]]{6}(r[[:alnum:]])))(\.bc$)|(bc\.lbl$)"


#"([[:digit:]]{5}_[[:digit:]]{5}(r[[:alnum:]])|([[:alnum:]]{2}_ISS))(\.bc$)|(bc\.lbl$)"
