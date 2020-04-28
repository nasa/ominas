;=============================================================================
;+
; NAME:
;       d_undefined
;
;
; PURPOSE:
;       Output the largest usable double floating value.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = d_undefined()
;
;
; ARGUMENTS:
;       NONE
;
; RETURN:
;       The largest usable double floating value.
;
; PROCEDURE:
;       Calls the idl function machar which determines machine-specific
;       parameters effecting floating-point arithmatic.  Uses the
;       field XMAX.
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
function d_undefined
 return, (machar(/double)).xmax
end
;===========================================================================
