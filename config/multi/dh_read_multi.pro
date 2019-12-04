;=============================================================================
; dh_read_multi.pro
;
;=============================================================================
function dh_read_multi, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

 data = read_multi(filename, nodata=nodata, dim=dim, type=type)
min=0
max=0

 return, data
end
;=============================================================================
