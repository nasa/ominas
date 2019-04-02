;=============================================================================
; dh_read_fits.pro
;
;=============================================================================
function dh_read_fits, dd, header, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

 fits_read, filename, data, header
 type = size(data, /type)
 dim = size(data, /dim)

 fits_open, filename, fcb
 fits_read, fcb, abscissa, extname='ABSCISSA'
 fits_close, fcb

 return, data
end
;=============================================================================
