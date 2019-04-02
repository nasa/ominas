;===========================================================================
; detect_spdr.pro
;
;===========================================================================
function detect_spdr, dd

 header = dat_header(dd) 
 if ~isa(header,'string') then return,''
 w = where(strpos(header, 'SAN PEDRO') NE -1)
 if(w[0] NE -1) then return, 'SPDR'

 return, ''
end
;===========================================================================
