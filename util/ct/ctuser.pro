;========================================================================
;+
; NAME:
;       ctuser
;
; PURPOSE:
;       Returns a user color that was allocated using ctmod.
;
;
; CATEGORY:
;       UTIL/CT
;
;
; CALLING SEQUENCE:
;       return = ctuser()
;
; RETURN:
;       The lookup table or true color value for the user color with index i.
;
;-
;=======================================================================
function ctuser, i
@ct_block.common
 if(keyword_set(_color)) then return, _color 

 ctmod, visual=visual

 case visual of
  1		 : return, 1
  8		 : return, !d.table_size - 9 - i 
  24		 : return, long(_ctuser_r[i]) + $
                              256l*long(_ctuser_g[i]) + $
                                   65536l*long(_ctuser_b[i])
  else		 : return, 0
 endcase
end
;========================================================================
