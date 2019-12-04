# ominas_env_gll.csh
#-----------------------------------------------------------------------------------#
#	OMINAS Galilieo setup for (t)csh												#
#																					#
#-----------------------------------------------------------------------------------#

setenv OMINAS_GLL       ${OMINAS_DIR}/config/gll/
setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_GLL}/tab/translators.tab
setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_GLL}/tab/transforms.tab
setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_GLL}
setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_GLL}/tab/instrument_detectors.tab

if ! ( $1 == "" ) then
	set pool = $1
	if ! ( -d "${pool}/ck" ) then pool = "${pool}/kernels"
	set sck = "sck"
	if ! ( -d "${pool}/sck" ) then sck = "sclk"
    setenv VGR_SPICE_CK 	${pool}/ck/
    setenv VGR_SPICE_EK 	${pool}/ek/
    setenv VGR_SPICE_FK 	${pool}/fk/
    setenv VGR_SPICE_IK 	${pool}/ik/
    setenv VGR_SPICE_LSK 	${pool}/lsk/
    setenv VGR_SPICE_PCK	${pool}/pck/
    setenv VGR_SPICE_SCK 	${pool}/$sclk/
    setenv VGR_SPICE_SPK 	${pool}/spk/
endif