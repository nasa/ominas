;=============================================================================
; dh_write_occ.pro
;
;=============================================================================
function dh_write_occ, dd, filename, nodata=nodata, sample=sample, status=status
 
 if(keyword_set(nodata)) then return, 0
 if(defined(sample)) then return, -1

; filename = dat_filename(dd)
 if(NOT keyword_set(filename)) then filename = dat_filename(dd)

 label = dat_header(dd)
 data = dat_data(dd)
 abscissa = dat_abscissa(dd)

 if(defined(abscissa)) then nv_message, /warning, $
                           'Abscissa not supported; writing data array only.'

 dsk_pts = cor_udata(dd, 'DISK_PTS')
 dn = transpose(data[1,*])
 rad = transpose(data[0,*])
 lon = dsk_pts[*,1]
 times = dblarr(n_elements(dn))


 write_occ, filename, times, dn, rad, lon
 return, 0
end
;=============================================================================
