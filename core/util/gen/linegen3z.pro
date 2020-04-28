;=============================================================================
;+
; NAME:
;	linegen3y
;
;
; PURPOSE:
;	Constructs a 3d array of subscripts that looks like indgen(nx, ny) in 
;	the x and y directions and is replicated in the z direction.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = linegen3y(nx, ny, nz)
;
;
; ARGUMENTS:
;  INPUT:
;	nx:	 Number of elements in the x direction.
;
;	ny:	 Number of elements in the y direction.
;
;	nz:	 Number of elements in the z direction.
;
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
; EXAMPLE:
; 	For nx=6, ny=3, nz=2:
;		0  1  2  3  4  5
;		6  7  8  9  10 11
;		12 13 14 15 16 17
;
;		0  1  2  3  4  5
;		6  7  8  9  10 11
;		12 13 14 15 16 17
;
;
; RETURN:
;	Array (nx x ny x nz) of subscripts.
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
function linegen3z, n, m, l
 return, reform(lindgen(n,m,l) mod (n*m), n,m,l, /overwrite)
end
;===========================================================================
