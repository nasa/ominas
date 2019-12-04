;=============================================================================
; vims_spice_lsk_detect
;
;=============================================================================
function vims_spice_lsk_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all,sc=sc
  compile_opt idl2
  return, eph_spice_lsk_detect(dd, kpath, time=time, strict=strict, all=all,sc=sc)
end
;=============================================================================
