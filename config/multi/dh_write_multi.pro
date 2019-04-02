;=============================================================================
; dh_write_multi.pro
;
;=============================================================================
function dh_write_multi, dd, filename, nodata=nodata, sample=sample, status=status
 
 if(keyword_set(nodata)) then return, 0
 if(defined(sample)) then return, -1

; filename = dat_filename(dd)
 if(NOT keyword_set(filename)) then filename = dat_filename(dd)

 label = dat_header(dd)
 data = dat_data(dd)
 abscissa = dat_abscissa(dd)

 if(defined(abscissa)) then nv_message, /warning, $
                           'Abscissa not supported; writing data array only.'

 write_multi, filename, data
 return, 0
end
;=============================================================================
