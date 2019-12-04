;=============================================================================
; dh_read_w10n_pds.pro
;
;=============================================================================
function dh_read_w10n_pds, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 url = dat_filename(dd)

 ;-----------------------------------------------------------------------
 ; min , max set to zero because no way to determine without reading
 ; entire data array
 ;-----------------------------------------------------------------------
 min=0
 max=0

 ;-----------------------------------------------------------------------
 ; read data array, subject to /nodata
 ;-----------------------------------------------------------------------
 silent = 1
 nv_verbosity = getenv('NV_VERBOSITY')
 if(keyword_set(nv_verbosity)) then begin
    verbosity = double(nv_verbosity)
    if(verbosity GE 0.9) then begin
      silent = 0
    endif
 endif
 data = read_w10n_pds(url, label, nodata=nodata, dim=dim, type=type, sample=sample, $
                                 returned_samples=returned_samples, silent=silent)

 return, data
end
;=============================================================================
