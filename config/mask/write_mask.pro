;=============================================================================
; write_mask
;
;=============================================================================
pro write_mask, filename, _data, header, dim=dim, silent=silent

 data = _data

 if(keyword_set(dim)) then $
  begin
   w = data
   data[*] = 1
;   type = 1
  end $
 else $
  begin
   dim = size(data, /dim)
;   type = size(data, /type)
   w = where(data NE 0)
   if(w[0] NE -1) then data = data[w]
  end

 type = size(data, /type)

 ndim = n_elements(dim)
 nw = n_elements(w)

 bh = ' '
 if(keyword_set(header)) then bh = byte(header)
 nhead = n_elements(bh)

 openw, unit, filename, /get_lun, error=error
 if(error NE 0) then $
  begin
   status=!err_string
   if(NOT keyword_set(silent)) then message, status
   return
  end

 printf, unit, 'mask'
 writeu, unit, long(nhead), long(ndim), long(dim), long(nw), long(w), long(type), bh, data
 if(w[0] NE -1) then writeu, unit, data

 close, unit
 free_lun, unit
end
;=============================================================================
