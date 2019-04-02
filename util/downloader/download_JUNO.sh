#!/usr/bin/env bash
#script to download a copy of the Juno kernels from PDS
#Usage:
#./download_JUNO.sh /directory/to/place/kernels

OWNDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
wget=${OWNDIR}/pp_wget
echo "This script will download a subset of kernels from the PDS Juno archive ("\
"http://naif.jpl.nasa.gov/pub/naif/CASSINI/kernels/. As of February/2018, this adds to 22GB."

if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi


baseurl="http://naif.jpl.nasa.gov/pub/naif/JUNO/kernels/"
#standard download (full, nonrecursive) directories
dirs=( fk ik lsk pck sclk )

#location for timestamps files
mkdir -p ~/.ominas/timestamps/CASSINI
ts=`eval echo "~/.ominas/timestamps/"`


for dir in "${dirs[@]}"
do
 ${wget} "${baseurl}${dir}/ --localdir=${1}/$dir/ --absolute --timestamps=$ts $@"
done

#special treatment directories (spk and ck, which are large)
echo "Downloading spks"
  ${wget} "${baseurl}spk/ --localdir=${1}/spk/ $@ --absolute --timestamps=$ts --xpattern=spk_((nob)|(merge)|(ref))_.+\.bsp"

echo "Downloading cks"

${wget} "${baseurl}ck/ --localdir=${1}/ck/ $@ --absolute --timestamps=$ts --pattern=juno_sc_.+\.bc --xpattern=(juno_([^_]+)_((nom)|(prl)|(prs)|(raw)|(tst))_.+\.bc)|(test)"


