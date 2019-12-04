;=============================================================================
;+
; NAME:
;       v_mean
;
;
; PURPOSE:
;       Computes the mean values of the given array of column vectors
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
function v_mean, v, wt=_wt

 dim = size(v, /dim)
 nv = dim[0]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 if(keyword_set(_wt)) then wt = _wt $
 else wt = make_array(nv,nt, val=1d)
 wt = wt[linegen3y(nv,3,nt)]

 return, reform(total(v*wt,1), 1, 3, nt)/total(wt,1)
end
;==============================================================================================
