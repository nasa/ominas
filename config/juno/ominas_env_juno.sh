#!/bin/sh
# ominas_env_juno.sh
#-----------------------------------------------------------------------------------#
#	OMINAS Juno setup for sh   						    #
#       The copy of this file at ~/.ominas/config is overwritten by the installer   #
#-----------------------------------------------------------------------------------#

OMINAS_JUNO=${OMINAS_DIR}/config/juno
export OMINAS_JUNO
NV_TRANSLATORS=${NV_TRANSLATORS}:${OMINAS_JUNO}/tab/translators.tab
export NV_TRANSLATORS
NV_TRANSFORMS=${NV_TRANSFORMS}:${OMINAS_JUNO}/tab/transforms.tab
export NV_TRANSFORMS
NV_SPICE_KER=${NV_SPICE_KER}:${OMINAS_JUNO}
export NV_SPICE_KER
NV_FTP_DETECT=${NV_FTP_DETECT}:${OMINAS_JUNO}/tab/filetype_detectors.tab
export NV_FTP_DETECT
NV_INS_DETECT=${NV_INS_DETECT}:${OMINAS_JUNO}/tab/instrument_detectors.tab
export NV_INS_DETECT
NV_IO=${NV_IO}:${OMINAS_JUNO}/tab/io.tab
export NV_IO


if ! [ -z ${1+x} ]; then
    pool=$1
    if ! [ -d "${pool}/ck" ]; then pool="${pool}/kernels"; fi
    sclk="sclk"
    if ! [ -d "${pool}/$sck" ]; then sclk="sck"; fi
    JUNO_SPICE_CK=${pool}/ck/
    export JUNO_SPICE_CK
    JUNO_SPICE_EK=${pool}/ek/
    export JUNO_SPICE_EK
    JUNO_SPICE_FK=${pool}/fk/
    export JUNO_SPICE_FK
    JUNO_SPICE_IK=${pool}/ik/
    export JUNO_SPICE_IK
    JUNO_SPICE_LSK=${pool}/lsk/
    export JUNO_SPICE_LSK
    JUNO_SPICE_PCK=${pool}/pck/
    export JUNO_SPICE_PCK
    JUNO_SPICE_SCK=${pool}/$sclk/
    export JUNO_SPICE_SCK
    JUNO_SPICE_SPK=${pool}/spk/
    export JUNO_SPICE_SPK
fi
