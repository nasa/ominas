#!/usr/bin/env bash
#script to download a copy of the Dawn kernels from PDS
#Usage:
#./download_DAWN.sh /directory/to/place/kernels


echo "This script wiill download a subset of kernels from the PDS Dawn archive ("\
"http://naif.jpl.nasa.gov/pub/naif/DAWN/kernels/. As of December/2016, this adds to 8 GB."

if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi


baseurl="http://naif.jpl.nasa.gov/pub/naif/DAWN/kernels/"
#standard download (full, nonrecursive) directories
dirs=( dsk ek fk ik lsk pck sclk )

#location for timestamps files
mkdir -p ~/.ominas/timestamps/DAWN
ts=`eval echo "~/.ominas/timestamps/"`


for dir in "${dirs[@]}"
do
 ./pp_wget "${baseurl}${dir}/ --localdir=${1}/$dir/ --absolute --timestamps=$ts $@"
done

#special treatment directories (spk and ck, which are large)
echo "Downloading spks"
./pp_wget "${baseurl}spk/ --localdir=${1}/spk/ $@ --absolute --timestamps=$ts --pattern="\
"dawn_rec_(1(1|2|5|6|7))[[:digit:]]{4}-[[:digit:]]{6}_[[:digit:]]{6}_.+((\.bsp$)|(bsp\.lbl$)) --xpattern="\
"dawn_rec_120913-[[:digit:]]{6}_[[:digit:]]{6}_.+((\.bsp$)|(bsp\.lbl$))"

echo "Downloading cks"
./pp_wget "${baseurl}ck/ --localdir=${1}/ck/ $@ --absolute --timestamps=$ts --pattern="\
"dawn_sc_(1(1|2|5|6|7))[[:digit:]]{4}_[[:digit:]]{6}((\.bc$)|(bc\.lbl$)) --xpattern="\
"dawn_sc_((110(1|2|3|4|5|6))[[:digit:]]{2})|(121[[:digit:]]{3})_[[:digit:]]{6}((\.bc$)|(bc\.lbl$))"
#./pp_wget "${baseurl}ck/ --localdir=$1/ck/ $@ --absolute --timestamps=~/.ominas/timestamps/ --xpattern="\
#"(\.tar\.gz$)|([[:digit:]]{5}_[[:digit:]]{5}[[:alnum:]]{2}(_(S|C)[[:digit:]]{2})?\.((pdf)|(txt))$)|(_bc_err\.txt$)" #--xpattern=(\.bc$)|(bc\.lbl$)|"

#./pp_wget "${baseurl}ck/ --localdir=$1/ck/ $@ --absolute --timestamps=~/.ominas/timestamps/CASSINI/ck.json --pattern="\
#"([[:digit:]]{5}_[[:digit:]]{5}(r[[:alnum:]])|([[:alnum:]]{2}_ISS))(\.bc$)|(bc\.lbl$)"
