;=============================================================================
;+
; NAME:
;       p_mxp
;
;
; PURPOSE:
;       Computes matrix product between square matrices and points.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = p_mxp(m, p)
;
;
; ARGUMENTS:
;  INPUT:
;	m:	An array of 2 x 2 matrices (i.e., 2 x 2 x nt).
;
;	p:	An array of np x nt image points (i.e., 2 x np x nt).
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array 2 x np x nt of matrix products.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale	6/2016
;
;-
;=============================================================================
function p_mxp, m, p

 dim = size(p, /dim)
 np = dim[1]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 q = dblarr(2,np,nt)

; for i=0, 1 do $
;  for j=0, 1 do if(m[i,j] NE 0) then q[i,*] = q[i,*] + m[i,j]*p[j,*]

 for i=0, 1 do $
  for j=0, 1 do $
   begin
    w = where(m[i,j,*] NE 0) 
    if(w[0] NE -1) then q[i,*,w] = q[i,*,w] + (m[i,j,w])[linegen3y(1,np,nt)]*p[j,*,w]
   end

 return, q
end
;===========================================================================
