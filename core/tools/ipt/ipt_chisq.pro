;=============================================================================
;+
; NAME:
;	ipt_chisq
;
;
; PURPOSE:
;	Computes chi-squared value for given point fit parameters.
;
;
; CATEGORY:
;	UTIL/NV/LIB/TOOLS/IPT
;
;
; CALLING SEQUENCE:
;	result = ipt_chisq(dxy, dtheta, fix, pts_dx, pts_dy, pts)
;
;
; ARGUMENTS:
;  INPUT:
;	dxy:		Array (2) giving x- and y-offset solution.
;
;	dtheta:		Scalar giving theta-offset solution.
;
;	fix:		Array specifying which parameters to fix as
;			[dx,dy,dtheta].
;
;       pts_dx:         Array (n_points) containing offset of actual
;                       point from predicted point in x.
;
;       pts_dy:         Array (n_points) containing offset of actual
;                       point from predicted point in y.
;
;       pts:            Array (2,n_points) of image coordinates corresponding
;                       to actual point.
;
;	axis:		Array (2) giving image coordinates of rotation axis
;			in the case of a 3-parameter fit.
;
;  OUTPUT: NONE
;
;
; KEYWORDS: 
;  INPUT:
;	norm:		If set, the returned value is normalized by dividing
;			it by the number of degrees of freedom.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	The chi-squared value is returned.
;
;
; STATUS:
;	Completed.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Haemmerle, 12/1998
;	
;-
;=============================================================================
function ipt_chisq, dxy, dtheta, fix, pts_dx, pts_dy, pts, axis, norm=norm

 n = n_elements(pts_dx)

 nfix = n_elements(fix)

 R = pts - axis#make_array(n,val=1)
 DX = pts_dx - dxy[0]
 DY = pts_dy - dxy[1]

 chisq = total( (DY - dtheta*R[0,*])^2 + (DX + dtheta*R[1,*])^2 )

 if(keyword__set(norm)) then chisq = chisq / (n - nfix)

 return, chisq
end
;===========================================================================
