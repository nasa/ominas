function vims_spice_ck_detect, dd, ckpath, djd=djd, time=time, $
  all=all, reject=reject, strict=strict,sc=sc
  compile_opt idl2
  return,cas_spice_ck_detect(dd, ckpath, djd=djd, time=time, $
    all=all, strict=strict,sc=sc)
end