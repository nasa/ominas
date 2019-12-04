;=============================================================================
; dh_read_pds4.pro
;
;=============================================================================
function dh_read_pds4, dd, header, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

 return, readpds4(filename, header, dat=dat)
end
;=============================================================================
