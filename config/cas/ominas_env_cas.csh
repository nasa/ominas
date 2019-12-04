# ominas_env_cas.csh
#-----------------------------------------------------------------------------------#
#	OMINAS Cassini setup for (t)csh													#
#																					#
#-----------------------------------------------------------------------------------#

setenv OMINAS_CAS       ${OMINAS_DIR}/config/cas/
setenv NV_TRANSLATORS   ${NV_TRANSLATORS}:${OMINAS_CAS}/tab/translators.tab
setenv NV_TRANSFORMS    ${NV_TRANSFORMS}:${OMINAS_CAS}/tab/transforms.tab
setenv NV_SPICE_KER     ${NV_SPICE_KER}:${OMINAS_CAS}
setenv NV_INS_DETECT    ${NV_INS_DETECT}:${OMINAS_CAS}/tab/instrument_detectors.tab

if ! ( $1 == "" ) then
	set pool = $1
	if ! ( -d "${pool}/ck" ) (pool = "${pool}/kernels")
	set sck = "sck"
	if ! ( -d "${pool}/sck" ) (sck = "sclk")
    setenv VGR_SPICE_CK 	${pool}/ck/
    setenv VGR_SPICE_EK 	${pool}/ek/
    setenv VGR_SPICE_FK 	${pool}/fk/
    setenv VGR_SPICE_IK 	${pool}/ik/
    setenv VGR_SPICE_LSK 	${pool}/lsk/
    setenv VGR_SPICE_PCK	${pool}/pck/
    setenv VGR_SPICE_SCK 	${pool}/$sclk/
    setenv VGR_SPICE_SPK 	${pool}/spk/
endif