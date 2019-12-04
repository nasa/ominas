function vims_spice_spk_detect, dd, kpath, $
  strict=strict, all=all, time=_time,sc=sc
  compile_opt idl2
  return, cas_spice_spk_detect(dd, kpath, $
    strict=strict, all=all, time=_time,sc=sc)
end
