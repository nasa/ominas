;=============================================================================
; ext_read_x11
;
;  NOT TESTED
;=============================================================================
function ext_read_x11, filename, dim=dim, nodata=nodata

 if(keyword_set(nodata)) then $
               nv_message, /warning, '/NO_DATA keyword ignored.


 read_x11_bitmap, filename, dat, /expand_to_bytes

 dim = size(dat, /dim)
 if(n_elements(dim) EQ 3) then dat = transpose(dat, [1,2,0])
 dim = size(dat, /dim)

 return, dat
end
;=============================================================================
