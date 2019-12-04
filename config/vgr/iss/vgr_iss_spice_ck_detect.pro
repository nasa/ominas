;=============================================================================
; vgr_iss_spice_ck_detect
;
;=============================================================================
function vgr_iss_spice_ck_detect, dd, kpath, sc=sc, djd=djd, time=time, $
                             all=all, strict=strict

 scname = vgr_iss_parse_inst(dat_instrument(dd), cam=cam)
 all_files = file_search(kpath + scname + '_???_???_' + cam + '.bc')

 return, all_files
end
;=============================================================================
