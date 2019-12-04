;=============================================================================
;+
; NAME:
;       v_interp
;
;
; PURPOSE:
;       Interpolates column vectors along a curve.
;
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_interp(v, x)
;
;
; ARGUMENTS:
;  INPUT:
;               v:      An array of nv column vectors  (i.e., nv x 3 array) 
;			to resample.  
;
;		x:	1-D coordinate along curve for each interpolate.
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;  INPUT:	uniform:	If set, the 'x' argument is taken as a uniform
;				grid spacing instead of grid.  
;  OUTPUT: 
;       NONE
;
;
; RETURN:
;       Array of interpolated column vectors.
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
function v_interp, v, _xx, uniform=uniform, $
         spline=spline, lsquadratic=lsquadratic, quadratic=quadratic

 xx = _xx
 if(keyword_set(uniform)) then dx = xx

 ;------------------------
 ; get dimensions
 ;------------------------
 nv = n_elements(v)/3
 nxx = n_elements(xx)
 

 ;------------------------------------------------------------
 ; compute input spacings, and 1-D path offsets 
 ;------------------------------------------------------------
 x = v_abscissa(v, len=len)


 ;------------------------------------------------------------
 ; compute output spacings, and total path offsets 
 ;------------------------------------------------------------
 if(keyword_set(dx)) then $
  begin
   nxx = round(len / dx)
   xx = dx * dindgen(nxx)
  end

 ;------------------------------------------------------------
 ; interpolate vectors by component
 ;------------------------------------------------------------
 vv = dblarr(nxx,3)
 vv[*,0] = interpol(v[*,0], x, xx, spline=spline, lsquadratic=lsquadratic, quadratic=quadratic)
 vv[*,1] = interpol(v[*,1], x, xx, spline=spline, lsquadratic=lsquadratic, quadratic=quadratic)
 vv[*,2] = interpol(v[*,2], x, xx, spline=spline, lsquadratic=lsquadratic, quadratic=quadratic)


 return, vv
end
;===========================================================================
