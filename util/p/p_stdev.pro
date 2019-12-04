;=============================================================================
;+
; NAME:
;       p_stdev
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
;       result = p_stdev(v)
;
;
; ARGUMENTS:
;  INPUT:
;       v:     An array of np x nt points (i.e. 2 x np x nt).
;
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of 1 x nt points (i.e., 2 x 1 x nt).
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
function p_stdev, p, mean=mean, mean2=mean2, wt=_wt

 dim = size(p, /dim)
 np = dim[1]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 if(keyword_set(_wt)) then wt = _wt $
 else wt = make_array(np,nt, val=1d)
 wt = wt[linegen3x(2,np,nt)]

 mean = p_mean(p, wt=_wt)
 mean2 = p_mean(p^2, wt=_wt)

 return, sqrt(mean2 - mean^2)
end
;==============================================================================================
