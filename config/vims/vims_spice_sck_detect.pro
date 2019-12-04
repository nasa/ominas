function vims_spice_sck_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all,sc=sc
  compile_opt idl2
  return,cas_spice_sck_detect(dd, kpath, time=time, strict=strict, all=all,sc=sc)
end
