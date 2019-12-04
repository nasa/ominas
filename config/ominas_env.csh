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


#-----------------------------------------------------------------------------#
# Edit this variable to point to the top directory of your OMINAS installation:
#-----------------------------------------------------------------------------#
setenv OMINAS_DIR   	<your OMINAS directory>


#------------------------------------------------------------------------#
# This adds your OMINAS installation to your idl path.
#------------------------------------------------------------------------#
setenv IDL_PATH ${IDL_PATH}:+${OMINAS_DIR}


#-----------------------------------------------------------------------#
# These variables define a minimal configuration .  Specific 
# configurations for various applications appear below. 
#-----------------------------------------------------------------------#
setenv NV_CONFIG	$OMINAS_DIR/config/

setenv NV_FTP_DETECT	$NV_CONFIG/tab/filetype_detectors.tab
setenv NV_IO		$NV_CONFIG/tab/io.tab
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
#    cd to $OMINAS_DIR/demo and type:                                         #                       #
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
setenv NV_SPICE_PCK $OMINAS_DIR/demo/data/kernels/pck/
setenv NV_SPICE_FK  $OMINAS_DIR/demo/data/kernels/fk/
setenv NV_SPICE_IK  $OMINAS_DIR/demo/data/kernels/ik/
setenv NV_SPICE_SCK $OMINAS_DIR/demo/data/kernels/sck/
setenv NV_SPICE_LSK $OMINAS_DIR/demo/data/kernels/lsk/
setenv NV_SPICE_CK  $OMINAS_DIR/demo/data/kernels/ck/
setenv NV_SPICE_SPK $OMINAS_DIR/demo/data/kernels/spk/
setenv NV_SPICE_XK  $NV_SPICE/




#=============================================================================#
#                                                                             #
#    The above setup should allow you to run the second and third example     #
#    scripts.  cd to $OMINAS_DIR/demo and type:                               #                       #
#                                                                             #
#    idl jupiter.exmample                                                     #
#                                                                             #
#    You should see an image of jupiter and some satellites with limbs and    #
#    rings overlain, but not aligned correctly.  If this does not work, then  #
#    you may have a problem with your installation of NAIF's ICY library.     #
#                                                                             #
#    If jupiter.example was successful, then try:                             #
#                                                                             #
#    idl grim.exmample                                                        #
#                                                                             #
#    The result should be similar to jupiter.example, except that the output  #
#    is displayed using OMINAS' graphical interface GRIM.                     #
#                                                                             #
#=============================================================================#



#------------------------------------------------------------------------#
# Custom configurations: 
#  To use the following configurations, comment out the DEMO configuration
#  above, and uncomment any of these following configurations that you
#  want to use.  Note, the demo scripts will work with the CASSINI
#  configuration as long as you have the appropriate kernels. 
#------------------------------------------------------------------------#

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# CASSINI
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#setenv OMINAS_CAS       ${OMINAS_DIR}/config/cas/
#setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_CAS}/tab/translators.tab
#setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_CAS}/tab/transforms.tab
#setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_CAS}
#setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_CAS}/tab/instrument_detectors.tab

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# GALILEO
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#setenv OMINAS_GLL       ${OMINAS_DIR}/config/gll/
#setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_GLL}/tab/translators.tab
#setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_GLL}/tab/transforms.tab
#setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_GLL}
#setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_GLL}/tab/instrument_detectors.tab

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# VOYAGER
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#setenv OMINAS_VGR       ${OMINAS_DIR}/config/vgr/
#setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_VGR}/tab/translators.tab
#setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_VGR}/tab/transforms.tab
#setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_VGR}
#setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_VGR}/tab/instrument_detectors.tab

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# DAWN
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#setenv OMINAS_DAWN      ${OMINAS_DIR}/config/dawn/
#setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_DAWN}/tab/translators.tab
#setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_DAWN}/tab/transforms.tab
#setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_DAWN}
#setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_DAWN}/tab/instrument_detectors.tab




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


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# This variable points to the location of the Voyager SEDR files, which
# are NOT provided in the default OMINAS installation.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#setenv NV_SEDR_DATA     $HOME/data/SEDR/


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# These variables point to the locations of various star catalogs, which are
# required by some of the demo scripts, but NOT supplied in this default 
# setup.  You only need one of these for a given catalog.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#setenv NV_GSC_DATA	$HOME/data/gsc/
#setenv NV_TYCHO_DATA	$HOME/data/tycho/
#setenv NV_SAO_DATA	$HOME/data/sao/

#=============================================================================#
#                                                                             #
#  Your SEDR and star catalog installations can be tested using the example   #
#  script stars.example.  Note that stars.example will not work using Voyager #
#  SPICE because the image used in that script is not covered.  
#                                                                             #
#=============================================================================#



#----------------------------------------------------------------------------#
# XIDL
#
#  XIDL is a simple shell interface to IDL, which allows arguments to
#  be passed to IDL programs from the shell command prompt.  It can be 
#  downloaded separately.
#
#----------------------------------------------------------------------------#
setenv XIDL_DIR         $HOME/idl_pro/xidl/
alias xidl              'csh $XIDL_DIR/xidl.csh'
setenv IDL_PATH          ${IDL_PATH}:+${XIDL_DIR}


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
# OMINAS shell interface
#
#  The following XIDL-based wrappers allow shell access to some OMINAS
#  programs.
#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
alias grim              'xidl grim.bat +'
alias brim              'xidl brim.bat +'
alias rim               'xidl rim.bat +'
#alias grim              'xidl ominas grim.bat +' 	# for compiled OMINAS
#alias brim              'xidl ominas brim.bat +' 	# for compiled OMINAS


