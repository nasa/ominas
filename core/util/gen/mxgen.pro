;=============================================================================
;+
; NAME:
;	mxgen
;
;
; PURPOSE:
; 	Generates 1d subscripts for an array of nn m-element column vectors 
;	such that subscripting the array of vectors will produce an array of 
;	nn n x m matrices with the given vectors forming the columns of the 
;	resulting matrices.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = mxgen(n, m, nn)
;
;
; ARGUMENTS:
;  INPUT:
;	n:	 Number of matrix columns.
;
;	m: 	 Number of matrix rows.
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
;	Array (n x m x nn) of subscripts.
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
function mxgen, n, m, nn
 return, transpose(reform(lindgen(nn*m, n),n,nn,m,/over), [0,2,1])
end
;===========================================================================
