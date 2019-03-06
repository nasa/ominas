;=============================================================================
;+
; NAME:
;       decrapify
;
; PURPOSE:
;       Circumvents a quirk of idl, returns first value of input as a scalar
;       if number of elements in array is 1.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = decrapify(val)
;
;
; ARGUMENTS:
;  INPUT:
;       val:  An array.
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       val unchanged, unless n_elements(val) equals 1, if so, returns
;       val[0]
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
function decrapify, val

 if(n_elements(val) EQ 1) then return, val[0]
 return, val
end
;=============================================================================
