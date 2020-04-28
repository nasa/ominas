;=============================================================================
;+
; NAME:
;	pg_covariance
;
;
; PURPOSE:
;	Computes a covariance matrix for the least-square fit specified by the
;	input scan coefficients.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	dxy = pg_covariance(cf)
;
;
; ARGUMENTS:
;  INPUT:
;	cf:	Array of pg_fit_coeff_struct as produced by pg_cvscan_coeff or
;		pg_ptscan_coeff.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	status:	0 if successful, -1 otherwise.
;
;
; RETURN:
;	Covariance matrix.  The diagonal elements are the variances in each fit
;	parameter, the off-diagonal elements are the covariances.
;
;
; RESTRICTIONS:
;	It is the caller's responsibility to ensure that all of the input
;	coefficients were computed using with the same set of fixed parameters.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_cvscan, pg_cvscan_coeff, pg_ptscan, pg_ptscan_coeff, 
;	pg_cvchisq, pg_ptchisq, pg_threshold
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
function pg_covariance, cf, status=status

 return, covariance(cf.M, status=status)
end
;=============================================================================
