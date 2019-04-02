;===========================================================================
; detect_ctio.pro
;
;===========================================================================
function detect_ctio, dd

 header = dat_header(dd) 
 if ~isa(header,'string') then return,''
 w = where(strpos(header, 'CERRO TOLOLO') NE -1)
 if(w[0] NE -1) then return, 'CTIO'

 return, ''
end
;===========================================================================
