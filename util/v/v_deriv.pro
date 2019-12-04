;=============================================================================
;+
; NAME:
;       v_deriv
;
;
; PURPOSE:
;       Computes tangent vectors to a given curve composed of column vectors.
;
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_deriv(v)
;
;
; ARGUMENTS:
;  INPUT:
;               v:      An array of nv column vectors  (i.e., nv x 3 array) 
;			to resample. 
;
;		dv:	Spacing for new array.
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of nv tangent unit vectors.
;
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale  1/2017
;
;-
;=============================================================================
function v_deriv, v

 nv = n_elements(v)/3

 
 ;-------------------------------------------------------------------------
 ; construct grid of point midway between given points, plus an extra one
 ; on each end
 ;-------------------------------------------------------------------------
 x = v_abscissa(v, len=len)
 
 xx = 0.5*(x[0:nv-2] + x[1:*]) 
 xx_m = -xx[0]
 xx_p = x[nv-1] + (x[nv-1] - xx[nv-2])
 xx = [xx_m, xx, xx_p] 

 vv = v_interp(v, xx)
 

 ;-------------------------------------------------------------------------
 ; compute derivatives across each original grid point
 ;-------------------------------------------------------------------------
 dv = vv[1:*,*] - vv[0:nv-1,*]


 return, dv
end
;===========================================================================
