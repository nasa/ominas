;==============================================================================
;+
; NAME:
;	cam_replicate
;
;
; PURPOSE:
;	Replicates the given camera descriptor, producing an array of the given
;	dimensions containing cloned versions of the input descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	new_cd = cam_replicate(cd, dim)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	 One CAMERA descriptor.
;
;	dim:	 Dimensions of the result.
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
;	Array of the given dimensions containing cloned versions of the input 
;	camera descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;==============================================================================
function cam_replicate, cd, dim
@core.include
 new_cd = dat_replicate(cd, dim, fn='nv_clone')
 return, new_cd
end
;==============================================================================
