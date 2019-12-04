#!/usr/bin/env bash
#script to download and prepare for use a copy of the GSC 1.2 catalog from CDS
#Usage:
#./download_GSC.sh /directory/to/place/catalog


echo "This script wiill download the GSC 1.2 catalog from CDS (http://cdsarc.u-strasbg.fr/ftp/cats/bincats/GSC_1.2/) and prepare its files for use. As of January/2017, this adds to 8.5 GB"


if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi




baseurl="http://cdsarc.u-strasbg.fr/ftp/cats/bincats/GSC_1.2/"

#standard download (full, nonrecursive) directories

#location for timestamps files
mkdir -p ~/.ominas/timestamps/GSC

./pp_wget "${baseurl}/ --localdir=$1/${dir}/ --absolute --timestamps=~/.ominas/timestamps/ --recursive $@"

#process the files

echo "Downloads done, processing files..."

if [ -z ${idlbin+x} ]; then
  if [ "$IDL_DIR" = "" ]; then
        idl=`which idl`
        if [ "$idl" = "" ]; then
          read -rp "IDL not found. Please enter the location of your IDL installation (such as /usr/local/exelis/idl85): " idldir
          IDL_DIR="$idldir"
          export IDL_DIR
          printf "Using IDL from $IDL_DIR\n"
          idlbin=$IDL_DIR/bin/idl
        else
          printf "Using IDL at $idl\n"
          idlbin=$idl
        fi
  else
        printf "IDL_DIR found, $IDL_DIR, using it\n"
        idlbin=$IDL_DIR/bin/idl
  fi
fi
echo "Using IDL at ${idlbin}"



#$idlbin -e '!path+=":./util/downloader"& unpack_gsc' -args $@
