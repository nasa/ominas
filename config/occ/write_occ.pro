;=======================================================================================
; write_occ
;
;=======================================================================================
pro write_occ, filename, _times, _dn, _rad, _lon, bin=bin, smooth=smooth, $
      instrument=instrument, time_offset=time_offset, time_units=time_units, $
      resrad=resrad

 times = _times
 dn = _dn
 rad = _rad
 lon = _lon 

 if(NOT keyword_set(time_offset)) then time_offset = 0d
 if(NOT keyword_set(time_units)) then time_units = 1d		; time --> seconds

 if(keyword_set(smooth)) then dn = smooth(dn, smooth)

 if(keyword_set(bin)) then $
  begin
   bin = long(bin)
   n = n_elements(times)
   nbin = long(n/bin)
   trunc = nbin*bin

   times = rebin(times[0:trunc-1], nbin)
   dn = rebin(dn[0:trunc-1], nbin)
   rad = rebin(rad[0:trunc-1], nbin)
   lon = rebin(lon[0:trunc-1], nbin)
  end

 lab = ''
 if(keyword_set(smooth)) then vicsetpar, lab, 'SMOOTH', strtrim(smooth,2)
 if(keyword_set(bin)) then vicsetpar, lab, 'BIN', strtrim(bin,2)
 vicsetpar, lab, 'OCCFILE', ''
 vicsetpar, lab, 'INSTRUMENT', instrument
 vicsetpar, lab, 'TIME_OFFSET', strtrim(string(time_offset, form='(g20.10)'),2)
 vicsetpar, lab, 'TIME_UNITS', strtrim(time_units,2)
 if(keyword_set(resrad)) then vicsetpar, lab, 'RESRAD', strtrim(resrad,2)

 write_vicar, filename, [tr(times), tr(dn), tr(rad), tr(lon)], lab

end
;=======================================================================================
