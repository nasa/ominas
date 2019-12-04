;=======================================================================================
; vgr_spice_sct2et
;
;=======================================================================================
function vgr_spice_sct2et, dd, times
 sc_name = vgr_parse_inst(dat_instrument(dd), cam=cam_name)
 sc = -31l
 if(sc_name EQ 'vg2') then sc = -32l

 return, spice_sct2et(times, sc)
end
;=======================================================================================
