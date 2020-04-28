;=============================================================================
;+
; NAME:
;       v_sqmag
;
;
; PURPOSE:
;       Computes the squared magnitudes of the given array of column vectors.
;
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_sqmag(v)
;
;
; ARGUMENTS:
;  INPUT:
;       v:     An array of nv x nt column vectors (i.e. nv x 3 x nt).
;
;  OUTPUT:
;       NONE
;
; RETURN:
;	An array of nv x nt squared magnitudes
;
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
function v_sqmag, v
 return, total(v*v, 2)
end
;===========================================================================
