;===========================================================================
;+
; NAME:
;	cam_fn_body_to_image
;
;
; PURPOSE:
;       Returns the name of the user-defined body --> image
;       transformation function for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	fn = cam_fn_body_to_image(cd)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	 Array (nt) of CAMERA descriptors.
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
;       Focal --> image transformation function associated with each
;       given camera descriptor.
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
function cam_fn_body_to_image, cd, noevent=noevent
@core.include

 nv_notify, cd, type = 1, noevent=noevent
 _cd = cor_dereference(cd)
 return, _cd.fn_body_to_image
end
;===========================================================================



