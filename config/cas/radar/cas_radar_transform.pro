;==============================================================================
; cas_radar_transform
; 
; based on documentation at https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/CORADR_0045/DOCUMENT/
;
;==============================================================================
pro cas_radar_transform, dd, force=force
  compile_opt idl2,logical_predicate

  ima = dat_data(dd, /true)
  label = dat_header(dd)

  missing=label[where(stregex(label,'MISSING_CONSTANT',/bool))]
  misval=(stregex(missing,'=[[:space:]]*"?16#([[:xdigit:]]+)#',/extract,/subexpr))[-1]
  ;dat_header_value,dd,'MISSING_CONSTANT',get=missing
  ;misval=(stregex(missing,'16#([[:xdigit:]]+)#',/subexpr,/extract))[-1]
  ;dat_header_value,dd,'SAMPLE_BITS',get=sb
  ;sb=strtrim(sb[0],2)
  sb=label[where(stregex(label,'SAMPLE_BITS',/bool))]
  sb=(stregex(sb,'=[[:space:]]*([[:digit:]]+)',/extract,/subexpr))[-1]
  mv=sb eq '32' ? 0L : 0LL
  reads,misval,mv,format='(Z)'
  
  mv=sb eq '32' ? float(mv,0) : double(mv,0)
  w=where(ima eq mv,count)
  if count then ima[w]=!values.d_nan
  ima=rotate(ima,1)
 
  dat_set_data, dd, ima
end
;==============================================================================
