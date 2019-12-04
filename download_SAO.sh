#!/usr/bin/env bash
#script to download and prepare for use a copy of the SAO catalog from CDS
#Usage:
#./download_SAO.sh /directory/to/place/catalog


echo "This script wiill download the SAO catalog from CDS (ftp://cdsarc.u-strasbg.fr/pub/cats/I/131A) and prepare its files for use. As of January/2017, this adds to 19 MB of download, and 70 MB of disk space after unpacking."

if [ -z ${ominas_auto+x} ] || [ ${ominas_auto} == 0 ] ; then
  read -rp "Continue?[y] " ans
  case $ans in
    [Nn]*)
      exit 1
  esac
fi

baseurl="ftp://cdsarc.u-strasbg.fr/pub/cats/I/131A"
#standard download (full, nonrecursive) directories

#location for timestamps files
mkdir -p ~/.ominas/timestamps/SAO
ts=`eval echo "~/.ominas/timestamps/"`


./pp_wget "${baseurl}/ --localdir=${1}/ --absolute --timestamps=$ts $@"


echo "Downloads done, unpacking files..."
#unpack the catalog files

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



$idlbin -e "file_gunzip,'$1'+path_sep()+'sao.dat.gz',/verbose"
