;===========================================================================
; detect_mirac.pro
;
;===========================================================================
function detect_mirac, dd

 header = dat_header(dd) 
 if ~isa(header,'string') then return,''
 w = where(strpos(header, 'MIRAC') NE -1)
 if(w[0] NE -1) then return, 'MIRAC'

 return, ''
end
;===========================================================================
