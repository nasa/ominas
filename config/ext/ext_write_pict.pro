;=============================================================================
; ext_write_pict
;
;  NOT TESTED
;=============================================================================
pro ext_write_pict, filename, dat

 dim = size(dat, /dim)
 if(n_elements(dim) EQ 3) then dat = transpose(dat, [2,0,1])

 write_pict, filename, dat
end
;=============================================================================
