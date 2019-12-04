;=============================================================================
; ext_write_tif
;
;  NOT TESTED
;=============================================================================
pro ext_write_tif, filename, dat

 dim = size(dat, /dim)
 if(n_elements(dim) EQ 3) then dat = transpose(dat, [2,0,1])

 write_tiff, filename, dat
end
;=============================================================================
