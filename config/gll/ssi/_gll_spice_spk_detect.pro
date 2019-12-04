;=============================================================================
; gll_spice_spk_detect
;
;=============================================================================
function gll_spice_spk_detect, dd, kpath, sc=sc, strict=strict, all=all, time=_time



 all_files = file_search(kpath + '*.bsp')

 return, all_files
end
;=============================================================================
