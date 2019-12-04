;===========================================================================
;+
; NAME:
;	cam_set_fn_focal_to_image
;
;
; PURPOSE:
;       Sets the user-defined focal --> image transformation function
;       for the given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_fn_focal_to_image, cd, fn
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	 Array (nt) of CAMERA descriptors.
;
;	fn:	 Array (nt) of user-defined focal --> image functions.
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
; RETURN: NONE
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
;===========================================================================
pro cam_set_fn_focal_to_image, cd, fn_focal_to_image, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.fn_focal_to_image=fn_focal_to_image

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



