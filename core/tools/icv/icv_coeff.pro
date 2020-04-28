;=============================================================================
;+
; NAME:
;	icv_coeff
;
;
; PURPOSE:
;	Computes coefficients for the 2- or 3-parameter linear least-square fit.
;
;
; CATEGORY:
;	NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;	icv_coeff, cos_alpha, sin_alpha, scan_offsets, scan_pts, axis, M=M, b=b
;
;
; ARGUMENTS:
;  INPUT:
;	cos_alpha:	Array (n_points) of direction cosines computed by
;			icv_compute_directions.
;
;	sin_alpha:	Array (n_points) of direction sines computed by
;			icv_compute_directions.
;
;	scan_offsets:	Array (n_points) containing offset of best correlation 
;			at each point on the curve.  Produced by icv_scan_strip.
;
;	scan_pts:	Array (2, n_points) of image coordinates corresponding
;			to each scan offset.
;
;	axis:		Array (2) giving image coordinates of rotation axis
;			in the case of a 3-parameter fit.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	sigma:	Uncertainty in each scan_offset.  Defaults to 1.
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
;	linear system.  Moreover, since the fit is linear, a simultaneous
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
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro icv_coeff, _cos_alpha, _sin_alpha, scan_offsets, scan_pts, axis, $
               sigma=sigma, M=M, b=b

 if(NOT keyword_set(sigma)) then sigma = 1d
 sigma2 = sigma^2

 n = n_elements(sin_alpha)

 d = scan_offsets
; w = where(scan_offsets LT 1d99)
 w = where(scan_offsets LT 1000)
 if(w[0] EQ -1) then return

 nw = n_elements(w)
 cos_alpha = _cos_alpha[*,w]
 sin_alpha = _sin_alpha[*,w]
 d = d[*,w]
 sigma2 = sigma2[*,w]

 R = scan_pts[*,w] - axis#make_array(nw,val=1)
 Q = -cos_alpha*R[1,*] + sin_alpha*R[0,*]

 a11 = total(cos_alpha^2 / sigma2)
 a22 = total(sin_alpha^2 / sigma2) 
 a33 = total(Q^2 / sigma2) 
 a12 = total(sin_alpha*cos_alpha / sigma2) 
 a13 = total(cos_alpha*Q / sigma2) 
 a23 = total(sin_alpha*Q / sigma2) 

 M = [ [a11, a12, a13], $
       [a12, a22, a23], $
       [a13, a23, a33] ]

 b1 = total(d*cos_alpha / sigma2) 
 b2 = total(d*sin_alpha / sigma2) 
 b3 = total(d*Q / sigma2)

 b = [ [b1], $
       [b2], $
       [b3] ]

end
;===========================================================================
