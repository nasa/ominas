;=============================================================================
; dh_write_fits.pro
;
;=============================================================================
function dh_write_fits, dd, filename, nodata=nodata, sample=sample, status=status
 
 if(keyword_set(nodata)) then return, 0
 if(defined(sample)) then return, -1

; filename = dat_filename(dd)
 if(NOT keyword_set(filename)) then filename = dat_filename(dd)

 header = dat_header(dd)
 data = dat_data(dd)
 abscissa = dat_abscissa(dd)

 fits_write, filename, data, header
 if(defined(abscissa)) then $
  begin
   fits_open, filename, fcb, /append
   fits_write, fcb, abscissa, extname='ABSCISSA', xtension='IMAGE'
   fits_close, fcb
  end


 return, 0
end
;=============================================================================
