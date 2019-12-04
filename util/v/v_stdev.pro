;=============================================================================
;+
; NAME:
;       v_stdev
;
;
; PURPOSE:
;       Computes the standard deviations of the given array of column vectors
;	in the x direction.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = v_stdev(v)
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
function v_stdev, v, mean=mean, mean2=mean2, wt=_wt

 dim = size(v, /dim)
 nv = dim[0]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 if(keyword_set(_wt)) then wt = _wt $
 else wt = make_array(nv,nt, val=1d)
 wt = wt[linegen3y(nv,3,nt)]

 mean = v_mean(v, wt=_wt)
 mean2 = v_mean(v^2, wt=_wt)

 return, sqrt(mean2 - mean^2)
end
;==============================================================================================
