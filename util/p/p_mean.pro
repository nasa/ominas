;=============================================================================
;+
; NAME:
;       p_mean
;
;
; PURPOSE:
;       Computes the mean values of the given array of points
;	in the y direction.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = p_mean(v)
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
function p_mean, p, wt=_wt

 dim = size(p, /dim)
 np = dim[1]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 if(keyword_set(_wt)) then wt = _wt $
 else wt = make_array(np,nt, val=1d)
 wt = wt[linegen3x(2,np,nt)]

 return, reform(total(p*wt,2), 2, 1, nt)/total(wt,2)
end
;==============================================================================================
