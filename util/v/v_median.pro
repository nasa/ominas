;=============================================================================
;+
; NAME:
;       v_median
;
;
; PURPOSE:
;       Computes the median values of the given array of column vectors
;	in the x direction.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_mean(v)
;
;
; ARGUMENTS:
;  INPUT:
;       v:     An array of nv x nt column vectors (i.e. nv x 3 x nt).
;
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of 1 x nt column vectors (i.e., 1 x 3 x nt).
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
function v_median, v

 dim = size(v, /dim)
 nv = dim[0]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 result = dblarr(1,3,nt)

 for i=0, nt-1 do result[0,0,*] = median(v[*,0,*])
 for i=0, nt-1 do result[0,1,*] = median(v[*,1,*])
 for i=0, nt-1 do result[0,2,*] = median(v[*,2,*])
 
 return, result
end
;==============================================================================================
