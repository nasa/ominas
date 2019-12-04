# ominas_env_dawn.csh
#-----------------------------------------------------------------------------------#
#	OMINAS Dawn setup for (t)csh													#
#																					#
#-----------------------------------------------------------------------------------#

setenv OMINAS_DAWN      ${OMINAS_DIR}/config/dawn/
setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_DAWN}/tab/translators.tab
setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_DAWN}/tab/transforms.tab
setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_DAWN}
setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_DAWN}/tab/instrument_detectors.tab

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