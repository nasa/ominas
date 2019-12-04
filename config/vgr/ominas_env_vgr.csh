# ominas_env_vgr.csh
#-----------------------------------------------------------------------------------#
#	OMINAS Voyager setup for (t)csh													#
#																					#
#-----------------------------------------------------------------------------------#

setenv OMINAS_VGR       ${OMINAS_DIR}/config/vgr/
setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_VGR}/tab/translators.tab
setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_VGR}/tab/transforms.tab
setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_VGR}
setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_VGR}/tab/instrument_detectors.tab

set pool = $1
if ! ( -d "${pool}/ck" ) then pool = "${pool}/kernels"
set sclk = "sclk"
if ! ( -d "${pool}/$sck" ) then sclk = "sck"
if ! ( $1 == "" ) then
    setenv VGR_SPICE_CK 	${pool}/ck/
    setenv VGR_SPICE_EK 	${pool}/ek/
    setenv VGR_SPICE_FK 	${pool}/fk/
    setenv VGR_SPICE_IK 	${pool}/ik/
    setenv VGR_SPICE_LSK 	${pool}/lsk/
    setenv VGR_SPICE_PCK	${pool}/pck/
    setenv VGR_SPICE_SCK 	${pool}/$sclk/
    setenv VGR_SPICE_SPK 	${pool}/spk/
endif