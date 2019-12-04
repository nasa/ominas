;=============================================================================
; read_mask
;
;=============================================================================
function read_mask, filename, header=header, dim=dim, type=type, raw=raw, sub=w


 ;----------------------------------
 ; open file
 ;----------------------------------
 openr, unit, filename, /get_lun, error=error
 if(error NE 0) then $
  begin
   status=!err_string
   if(NOT keyword_set(silent)) then message, status
   return, 0
  end


 ;----------------------------------
 ; read data
 ;----------------------------------
 format = ''
 readf, unit, format

 nhead = 0l
 readu, unit, nhead

 ndim = 0l
 readu, unit, ndim

 dim = lonarr(ndim)
 readu, unit, dim

 nw = 0l
 readu, unit, nw

 w = lonarr(nw)
 readu, unit, w

 type = 0l
 readu, unit, type

 bh = bytarr(nhead)
 readu, unit, bh

 if(w[0] NE -1) then $
  begin
   dat = make_array(nw, type=type)
   readu, unit, dat
  end

 close, unit
 free_lun, unit


 ;----------------------------------
 ; construct data
 ;----------------------------------
 header = string(bh)

 if(keyword_set(raw)) then return, dat

 data = make_array(dim, type=type)
 if(w[0] NE -1) then data[w] = dat


 return, data
end
;=============================================================================



; writeu, unit, long(ndim), long(dim), long(nw), long(w), long(type), data
