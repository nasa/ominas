;=============================================================================
;+
; NAME:
;       sign
;
; PURPOSE:
;       Return the sign of the operand
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       return = sign(x)
;
;
; ARGUMENTS:
;  INPUT:
;       x:      An input value or array
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;       NONE
;
; RETURN:
;       An array whose elements are the sign (+1 or -1) of the input array.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function sign, x
 return, 2*(x GE 0) - 1
end
;============================================================================
