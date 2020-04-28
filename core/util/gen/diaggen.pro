;=============================================================================
;+
; NAME:
;	diaggen
;
;
; PURPOSE:
;	Constructs 1d subscripts of diagonal elements of an array of nn nxn
;	matrices such that subscripting the array of matrices will produce
;	an array of column vectors with each column containing the diagonal
;	elements of the corresponding matrix.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = diaggen(n, nn)
;
;
; ARGUMENTS:
;  INPUT:
;	n:	 Degree of matrix, i.e., number of rows / columns.
;
;	nn:	 Number of matrices.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n x n x nn) of subscripts.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function diaggen, n, nn
 return, transpose( $
  reform(lindgen(n,nn)*(n+1)-(lindgen(nn)*n)##make_array(n,val=1), n,nn,/over) )
end
;===========================================================================
