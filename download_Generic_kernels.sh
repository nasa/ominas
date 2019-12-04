#!/usr/bin/env bash
#script to download a copy of the NAIF Generic kernels from PDS
#Usage:
#./download_GENERIC.sh /directory/to/place/kernels


echo "This script wiill download all kernels from the PDS Galileo archive ("\
"http://naif.jpl.nasa.gov/pub/naif/generic_kernels/. As of December/2016, this adds to 22GB."

if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi


baseurl="http://naif.jpl.nasa.gov/pub/naif/generic_kernels/"
#standard download (full, nonrecursive) directories
dirs=(fk lsk pck stars)

#location for timestamps files
mkdir -p ~/.ominas/timestamps/GENERIC
ts=`eval echo "~/.ominas/timestamps/"`


for dir in "${dirs[@]}"
do
 ./pp_wget "${baseurl}${dir}/ --localdir=${1}/$dir/ --absolute --timestamps=$ts --recursive $@ "
done

#special treatment directories (spk and ck, which are large)

#echo "Downloading pcks"
#./pp_wget "${baseurl}pck/ --localdir=${1}/pck/ --absolute --timestamps=$ts $@ "

echo "Downloading spks"

dirs=(asteroids comets lagrange_point planets satellites stations)

for dir in "${dirs[@]}"
do
  ./pp_wget "${baseurl}spk/${dir} --localdir=${1}/spk/${dir} $@ --absolute --timestamps=$ts " # --xpattern=(\.bsp$)|(\.bsp\.lbl$)"
done
