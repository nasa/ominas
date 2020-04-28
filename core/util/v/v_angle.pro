;=============================================================================
;+
; NAME:
;       v_angle
;
;
; PURPOSE:
;       Computes the angles between the given arrays of column vectors.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_angle(v1, v2)
;
;
; ARGUMENTS:
;  INPUT:
;       v1:     An array of nv x nt column vectors (i.e. nv x 3 x nt).
;
;       v2:     Another array of nv x nt column vectors).
;
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of nv x nt angles in radians.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale	3/2002
;
;-
;=============================================================================
function v_angle, v1, v2

 dot = -1d > v_inner(v_unit(v1), v_unit(v2)) < 1d

 return, acos(dot)
end
;===========================================================================
