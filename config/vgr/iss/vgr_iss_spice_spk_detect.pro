;=============================================================================
; vgr_iss_spice_spk_detect
;
;=============================================================================
function vgr_iss_spice_spk_detect, dd, kpath, sc=sc, strict=strict, all=all, time=_time

 scname = vgr_iss_parse_inst(dat_instrument(dd), cam=cam)
 all_files = file_search(kpath + scname + '_???.bsp')

 return, all_files
end
;=============================================================================
