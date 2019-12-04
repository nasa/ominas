;=============================================================================
;+
; NAME:
;       v_abscissa
;
;
; PURPOSE:
;       Creates a 1-D abscissa for the given curve compsed of column vectors.
;
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_abscissa(v)
;
;
; ARGUMENTS:
;  INPUT:
;		v:      An array of nv column vectors  (i.e., nv x 3 array).  
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;  INPUT: 
;       NONE
;
;  OUTPUT: 
;     		len:	Length of the entire path.
;
;
; RETURN:
;       Array of abscissa values (i.e. 1-D offsets along the given curve).
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
function v_abscissa, v, len=len

 ;------------------------
 ; get dimensions
 ;------------------------
 nv = n_elements(v)/3
 
 ;------------------------------------------------------------
 ; compute input spacings, and 1-D path offsets 
 ;------------------------------------------------------------
 d = [0, v_mag(v[0:nv-2,*] - v[1:*,*])]
 len = total(d)
 x = total(d, /cumulative)

 return, x
end
;===========================================================================
