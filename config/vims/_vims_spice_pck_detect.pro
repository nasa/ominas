;=============================================================================
; vims_spice_pck_detect
;
;
;=============================================================================
function vims_spice_pck_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all,sc=sc
  compile_opt idl2
  return, eph_spice_pck_detect(dd, kpath, time=time, strict=strict, all=all,sc=sc)
end
;=============================================================================
