#!/bin/csh -f
##############################################################################
# OMINAS default setup for csh
#
#  This script configures the environment for OMINAS.  If you do not use csh 
#  or tcsh, then you'll need to set these variables using syntax appropriate 
#  to your preferred shell.
#
#  This file will be overwritten when you upgrade your OMINAS installation 
#  so you should copy it to another location before customizing it for 
#  your system.  Then you can configure OMINAS using:
#
#  source ominas_env.csh
#
##############################################################################


#-----------------------------------------------------------------------#
# These variables define a minimal configuration .  Specific 
# configurations for various applications appear below. 
#-----------------------------------------------------------------------#
setenv NV_CONFIG		$OMINAS_DIR/config/

setenv NV_FTP_DETECT	$NV_CONFIG/tab/filetype_detectors.tab
setenv NV_IO			$NV_CONFIG/tab/io.tab
setenv NV_SPICE         $NV_CONFIG/spice/

setenv NV_TRANSLATORS	$NV_CONFIG/tab/translators.tab
setenv NV_TRANSFORMS	$NV_CONFIG/tab/transforms.tab
setenv NV_SPICE_KER     :
setenv NV_INS_DETECT	$NV_CONFIG/tab/instrument_detectors.tab



#=============================================================================#
#                                                                             #
#    The above setup should allow you to run the first example script, which  #
#    enters all geometric information explicitly instead of accessing an      #
#    external source, which will require additional configuration (see below).#
#    cd to $OMINAS_DIR/demo and type:                                         #
#                                                                             #
#    idl        saturn.example                                                #
#                                                                             #
#    You should see a Voyager image of saturn with the limb and rings         #
#    overlain.  If this example does not work, then your OMINAS_DIR variable  #
#    may not be set correctly.                                                #
#                                                                             #
#=============================================================================#


#=============================================================================#
#                                                                             #
#    Subsequent scripts utilize OMINAS' SPICE interface, which uses NAIF's    #
#    ICY libraries.  Before proceeding, you will need to download the         #
#    appropriate package from http://naif.jpl.nasa.gov/naif/toolkit_IDL.html  #
#    and install it according to their instructions.  Note that OMINAS's      #
#    SPICE interface has been tested back to toolkit version 0064.            #
#                                                                             #
#=============================================================================#


#------------------------------------------------------------------------#
# DEMO configuration: 
#  This is the default OMINAS configuration.  It is just enough to make
#  the demo scripts work.
#------------------------------------------------------------------------#
setenv OMINAS_DEMO      $OMINAS_DIR/demo/
setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_DEMO}/data/translators.tab
setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_DEMO}/data/transforms.tab
setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_DEMO}/data/
setenv NV_INS_DETECT	${NV_INS_DETECT}:${OMINAS_DEMO}/data/instrument_detectors.tab

 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# These variables point to the directories containing the SPICE kernels
# required for the demo scripts.  You'll probably want to install a more
# comprehensive set of kernels elsewhere, in which case you would replace
# these locations with yours, and comment out the above demo configuration
# (see below).
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
setenv DEMO_SPICE_PCK $OMINAS_DIR/demo/data/kernels/pck/
setenv DEMO_SPICE_FK  $OMINAS_DIR/demo/data/kernels/fk/
setenv DEMO_SPICE_IK  $OMINAS_DIR/demo/data/kernels/ik/
setenv DEMO_SPICE_SCK $OMINAS_DIR/demo/data/kernels/sck/
setenv DEMO_SPICE_LSK $OMINAS_DIR/demo/data/kernels/lsk/
setenv DEMO_SPICE_CK  $OMINAS_DIR/demo/data/kernels/ck/
setenv DEMO_SPICE_SPK $OMINAS_DIR/demo/data/kernels/spk/
setenv DEMO_SPICE_XK  $NV_SPICE/

#-----------------------------------------------------------------------------------#
# Generic Kernels:                                                                  #
#  The default OMINAS configuration also will set up the generic kernels. These     #
#  kernels can be used to supplement limited data sets, such as the Voyager SPICE   #
#  kernels.                                                                         #
#-----------------------------------------------------------------------------------#

if ! ( $1 == "" ) then
	set pool = $1
	if ! ( -d "${pool}/pck" ) (pool = "${pool}/kernels")
	setenv GEN_SPICE_PCK	${pool}/pck/
	setenv GEN_SPICE_FK		${pool}/fk/
	setenv GEN_SPICE_LSK	${pool}/lsk/
	setenv GEN_SPICE_SPK	${pool}/spk/
	setenv GEN_SPICE_DSK	${pool}/dsk/
endif

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# This variable points to the location of the ring catalogs, which are
# provided in the default OMINAS installation.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
setenv NV_RING_DATA     $OMINAS_DIR/config/rings/


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# This variable points to the location of the orbit catalogs, which are
# provided in the default OMINAS installation.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
setenv NV_ORBIT_DATA     $OMINAS_DIR/config/orb/

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# This variable points to the location of the station catalogs, which are
# provided in the default OMINAS installation.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
setenv NV_STATION_DATA     $OMINAS_DIR/config/stn/

setenv XIDL_DIR    '$OMINAS_DIR/util/xidl'
alias xidl         'csh $XIDL_DIR/xidl.csh'
alias grim         'xidl grim.bat +'
alias brim         'xidl brim.bat +'
alias rim          'xidl rim.bat +'