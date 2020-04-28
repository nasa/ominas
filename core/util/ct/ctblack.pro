;========================================================================
;+
; NAME:
;       ctblack
;
; PURPOSE:
;       To allocate/return the color black.
;
;
; CATEGORY:
;       UTIL/CT
;
;
; CALLING SEQUENCE:
;       return = ctblack()
;
; RETURN:
;       The lookup table or true color value for black
;
;-
;========================================================================
function ctblack
@ct_block.common
 if(keyword_set(_color)) then return, _color 

 ctmod, visual=visual

 case visual of
  1		 : return, 0
  8		 : return, !d.table_size - 8
  24		 : return, 0
  else		 : return, 0
 endcase
end
;========================================================================
