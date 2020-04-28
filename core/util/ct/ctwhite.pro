;========================================================================
;+
; NAME:
;       ctwhite
;
; PURPOSE:
;       To allocate/return the color white.
;
;
; CATEGORY:
;       UTIL/CT
;
;
; CALLING SEQUENCE:
;       return = ctwhite()
;
; RETURN:
;       The lookup table or true color value for white
;
;-
;========================================================================
function ctwhite, frac
 if(keyword_set(_color)) then return, _color 

 if(NOT defined(frac)) then frac = 1.0

 ctmod, visual=visual

 ff = long(255.*frac)

 case visual of
  1		 : return, 1
  8		 : return, !d.table_size - 1
  24		 : return, ff*65536 +ff*256 + ff
  else		 : return, 0
 endcase
end
;========================================================================
