;=============================================================================
; read_multi
;
;=============================================================================
function read_multi, filename, dim=dim_p, type=types, nodata=nodata

 openr, unit, filename, /get_lun

 tag = '___MULTI___'
 readu, unit, tag

 n = 0l
 readu, unit, n

 dims = lonarr(8,n)
 readu, unit, dims

 types = lonarr(n)
 readu, unit, types

 data = ptrarr(n)
 dim_p = ptrarr(n)
 for i=0, n-1 do $
  begin
   dim = dims[*,i]
   w = where(dim NE 0)
   dim = dim[w]
   dim_p[i] = nv_ptr_new(dim)
   dat = make_array(dim=dim, type=types[i])
   readu, unit, dat
   data[i] = nv_ptr_new(dat)
  end

 close, unit
 free_lun, unit

 return, data
end
;=============================================================================
