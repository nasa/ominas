;=============================================================================
;+
; NAME:
;	glb_nj
;
;
; PURPOSE:
;	Returns an integer indicating the maximum number of zonal harmonics
;	allowed in the 'j' field of the globe descriptor.  This number
;	can be adjusted using the environment variable 'GLB_NJ'.  The default
;	is 11.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	nj = glb_nj()
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;
;  OUTPUT: NONE
;
;
; ENVIRONMENT VARIABLES:
;	GLB_NJ:		Sets the nj value.
;
;
; RETURN:
;	Current nj value.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function glb_nj

 nj_string = getenv('GLB_NJ')
 if(keyword__set(nj_string)) then nj = strtrim(nj_string, 2) else nj = 129

 return, nj
end
;===========================================================================



