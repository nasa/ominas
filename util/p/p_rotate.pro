;=============================================================================
;+
; NAME:
;       p_rotate
;
;
; PURPOSE:
;       Rotates the given image vectors about an axis projecting out of the 
;	image plane.
;
; CATEGORY:
;       UTIL/V
;
;
; CALLING SEQUENCE:
;       result = p_rotate(p, sin_theta, cos_theta)
;
;
; ARGUMENTS:
;  INPUT:
;	p:	An array of np x nt image vectors (i.e., 2 x np x nt).
;
;	sin_theta:	Sines of np x nt rotation angles in radians.
;
;	cos_theta:	Cosines of np x nt rotation angles in radians.
;
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of np x nt image vectors.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale	6/2005
;
;-
;=============================================================================
function p_rotate, p, sin_theta, cos_theta

; pp = [ p[0]*cos_theta + p[1]*sin_theta, $
;       -p[0]*sin_theta + p[1]*cos_theta ]
 pp = [ p[0,*]*cos_theta + p[1,*]*sin_theta, $
       -p[0,*]*sin_theta + p[1,*]*cos_theta ]

 return, pp
end
;=============================================================================
