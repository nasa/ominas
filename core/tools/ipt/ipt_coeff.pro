;=============================================================================
;+
; NAME:
;	ipt_coeff
;
;
; PURPOSE:
;	Computes coefficients for the 2- or 3-parameter linear least-square fit.
;
;
; CATEGORY:
;	UTIL/NV/LIB/TOOLS/IPT
;
;
; CALLING SEQUENCE:
;	ipt_coeff, pts_x, pts_y, pts, axis, M=M, b=b
;
;
; ARGUMENTS:
;  INPUT:
;
;	pts_x:	        Value containing offset of actual
;			point from predicted point in x.
;
;       pts_y:          Value containing offset of actual
;                       point from predicted point in y.
;
;	pts:	        Array (2) of image coordinates corresponding
;			to actual point.
;
;	axis:		Array (2) giving image coordinates of rotation axis
;			in the case of a 3-parameter fit.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	sigma:	Uncertainty in each point position.
;
;  OUTPUT:
;	M:	3x3 matrix of coefficients for the linear fit.
;
;	b:	3-element column vector rhs of the linear fit.
;
;
; PROCEDURE:
;	Since the fit has been linearized, it can be written as a matrix
;	equation:
;
;				Mx = b,
;
;	where x is the 3-element column vector [dx, dy, dtheta] of the
;	independent variables. 	This routine computes the matrix M and the
;	vector b.  Once these are known, mbfit can be used to solve the
;	linear system.  Furthermore, since the fit is linear, a simultaneous
;	fit can be performed by simply adding together any number of
;	coefficient matrices and vectors, which can also be done using
;	mbfit.
;
;
; RESTRICTIONS:
;	The fit associated with these coefficients has been linearized
;	and is only valid for small corrections.  For larger corrections,
;	this procedure can be iterated.
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Haemmerle, 5/1998
;	
;-
;=============================================================================
pro ipt_coeff, pts_x, pts_y, pts, axis, M=M, b=b, sigma=sigma

 if(NOT keyword__set(sigma)) then sigma = 1d
 sigma2 = sigma^2

 R = pts - axis

 a11 = 1d / sigma
 a22 = 1d / sigma
 a33 = R[0]*R[0] + R[1]*R[1] / sigma
 a12 = 0d 
 a13 = -R[1] / sigma
 a23 = R[0] / sigma

 M = [ [a11, a12, a13], $
       [a12, a22, a23], $
       [a13, a23, a33] ]

 b1 = pts_x / sigma
 b2 = pts_y / sigma
 b3 = (R[0]*pts_y - R[1]*pts_x) / sigma

 b = [ [b1], $
       [b2], $
       [b3] ]

end
;===========================================================================
