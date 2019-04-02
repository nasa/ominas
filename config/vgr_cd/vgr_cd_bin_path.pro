;===========================================================================
; vgr_cd_bin_path
;
;
;===========================================================================
function vgr_cd_bin_path

 nv_vgr_cd = getenv('NV_VGR_CD')
 if(nv_vgr_cd EQ '') then nv_message, 'NV_VGR_CD variable not set.'

 platform = getenv('OMINAS_PLATFORM')
 if(platform EQ '') then nv_message, 'OMINAS_PLATFORM variable not set.'

 add = ''


 return, nv_vgr_cd+sep+'bin'+sep+platform+add+sep

end
;===========================================================================
