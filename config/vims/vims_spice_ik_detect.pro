function vims_spice_ik_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all,sc=sc
  compile_opt idl2
  return,cas_spice_ik_detect(dd, kpath, time=time, strict=strict, all=all,sc=sc)
end
