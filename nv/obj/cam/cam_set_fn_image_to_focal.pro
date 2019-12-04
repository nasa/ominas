;===========================================================================
;+
; NAME:
;	cam_set_fn_image_to_focal
;
;
; PURPOSE:
;       Sets the user-defined image --> focal transformation function
;       for the given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_fn_image_to_focal, cd, fn
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	 Array (nt) of CAMERA descriptors.
;
;	fn:	 Array (nt) of user-defined image --> focal functions.
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
pro cam_set_fn_image_to_focal, cd, fn_image_to_focal, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.fn_image_to_focal=fn_image_to_focal

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



