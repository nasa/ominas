;=============================================================================
;+
; NAME:
;       p_mag
;
;
; PURPOSE:
;       Computes the squared magnitudes of the given array of image vectors.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = p_sqmag(p)
;
;
; ARGUMENTS:
;  INPUT:
;	p:	An array of np x nt image vectors (i.e., 2 x np x nt).
;
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of np x nt squared magnitudes.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale	6/2005
;
;-
;=============================================================================
function p_sqmag, p
 return, total(p*p, 1)
end
;===========================================================================
