;=============================================================================
;+
; NAME:
;       v_cross
;
;
; PURPOSE:
;       Computes the cross products between the given arrays of column
;       vectors.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_cross(v1, v2)
;
;
; ARGUMENTS:
;  INPUT:
;       v1:     An array of nv x nt column vectors (i.e. nv x 3 x nt).
;
;       v2:     Another array of nv x nt column vectors.
;
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of nv x nt cross products.
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
function v_cross, v1, v2

 result=v1

 result[*,0,*]=v1[*,1,*]*v2[*,2,*] - v1[*,2,*]*v2[*,1,*]
 result[*,1,*]=v1[*,2,*]*v2[*,0,*] - v1[*,0,*]*v2[*,2,*]
 result[*,2,*]=v1[*,0,*]*v2[*,1,*] - v1[*,1,*]*v2[*,0,*]

 return, result
end
;===========================================================================
