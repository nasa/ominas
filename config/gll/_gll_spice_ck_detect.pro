;=============================================================================
; gll_spice_ck_detect
;
;=============================================================================
function gll_spice_ck_detect, dd, ckpath, sc=sc, djd=djd, time=time, $
                             all=all, strict=strict

 all_files = file_search(ckpath + '*.plt')

 return, all_files
end
;=============================================================================
