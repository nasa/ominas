;=============================================================================
; ext_read_xwd
;
;  NOT TESTED
;=============================================================================
function ext_read_xwd, filename, dim=dim, nodata=nodata

 if(keyword_set(nodata)) then $
               nv_message, /warning, '/NO_DATA keyword ignored.


 dat = read_xwd(filename, r, g, b)

 dim = size(dat, /dim)

 if(n_elements(dim) EQ 3) then dat = transpose(dat, [1,2,0]) $
 else if(keyword_set(r)) then $
  begin
   _dat = bytarr([dim,3])
   _dat[*,*,0] = r[dat]
   _dat[*,*,1] = g[dat]
   _dat[*,*,2] = b[dat]
   dat = _dat
  end

 dim = size(dat, /dim)

 return, dat
end
;=============================================================================
