#!/usr/bin/env bash
#script to download a copy of the RADAR data used in demo/radar_example.pro from PDS
# (http://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/CORADR_0045/DATA/BIDR/BIFQI22N068_D045_T003S01_V02.ZIP)
#Usage:
#./download_RADAR.sh /directory/to/place/data


echo "This script will download a Cassini RADAR SAR observation from the PDS Cassini archive ("\
"http://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/CORADR_0045/DATA/BIDR/BIFQI22N068_D045_T003S01_V02.ZIP."
"This is a MB download, and will use MB when decompressed"

read -rp "Continue?[y] " ans
case $ans in
  [Nn]*)
    exit 1
esac

baseurl="http://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/CORADR_0045/DATA/BIDR/BIFQI22N068_D045_T003S01_V02.ZIP"

./pp_wget "${baseurl} --localdir=$1/ --absolute --timestamps=~/.ominas/timestamps/ $@"

#decompress the file

#set environment variable

