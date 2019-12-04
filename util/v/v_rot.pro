;=============================================================================
;+
; NAME:
;       v_rot
;
;
; PURPOSE:
;       Computes a rotation matrix between two vectors.
;
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;	result = v_rot(v1, v2)
;
;
; ARGUMENTS:
;  INPUT:
;	v1, v2:      Arrays (nv,3,nt) of column unit vectors.
;
;  OUTPUT:
;       NONE
;
; RETURN:
;	Rotation matrix transforming v1 to v2, i.e.: v2 = R##v1.
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
function v_rot, v1, v2

 n = v_unit(v_cross(v1,v2))

 c1 = v_cross(n, v1) 
 c2 = v_cross(n, v2) 

 M1 = [v1, n, c1]
 M2 = [v2, n, c2]

 return, transpose(M1)#M2
end
;===========================================================================
