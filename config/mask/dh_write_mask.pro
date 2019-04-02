;=============================================================================
; dh_write_mask.pro
;
;=============================================================================
function dh_write_mask, dd, filename, nodata=nodata, sample=sample, status=status
 
 if(keyword_set(nodata)) then return, 0
 if(defined(sample)) then return, -1

; filename = dat_filename(dd)
 if(NOT keyword_set(filename)) then filename = dat_filename(dd)

 header = dat_header(dd)
 data = dat_data(dd)
 abscissa = dat_abscissa(dd)

 if(defined(abscissa)) then nv_message, /warning, $
                           'Abscissa not supported; writing data array only.'

 write_mask, filename, data, header
 return, 0
end
;=============================================================================
