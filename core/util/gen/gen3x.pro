;=============================================================================
;+
; NAME:
;	gen3x
;
;
; PURPOSE:
;	Constructs nx x ny x nz array of subscripts with values incrementing 
;	in the x direction.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = gen3x(nx, ny, nz)
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
function gen3x, nx, ny, nz
 return, reform(transpose((lindgen(ny*nz,nx)/(ny*nz))),nx,ny,nz,/over)
end

; note could also use reform( indgen(--) mod -- )
;===========================================================================
