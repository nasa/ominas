;=============================================================================
; dh_read_ext.pro
;
;=============================================================================
function dh_read_ext, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

min=0
max=0
 return, read_ext(filename, label, dim=dim, type=type, nodata=nodata)
end
;=============================================================================
