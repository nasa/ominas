;=============================================================================
; write_multi
;
;
;=============================================================================
pro write_multi, filename, _data

 if(size(_data, /type) NE 10) then data = nv_ptr_new(_data) $
 else data = _data

 n = n_elements(data)
 dims = lonarr(8,n)
 types = lonarr(n)

 dim_s = ''
 for i=0, n-1 do $
  begin
   dat = *data[i]
   buf = append_array(buf, reform(dat, n_elements(dat)))
   dim = size(dat, /dim)
   dims[0:n_elements(dim)-1,i] = dim
   types[i] = size(dat, /type)
  end



 openw, unit, filename, /get_lun

 writeu, unit, '___MULTI___'

 writeu, unit, long(n)
 writeu, unit, dims
 writeu, unit, types
 writeu, unit, buf

 close, unit
 free_lun, unit

 if(size(_data, /type) NE 10) then nv_ptr_free, data
end
;=============================================================================
