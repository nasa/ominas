;===========================================================================
;+
; NAME:
;	cam_origin
;
;
; PURPOSE:
;       Returns the 2-element array giving the image coordinates (in
;       pixels) corresponding to the camera optic axis for each given
;       camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	origin = cam_origin(cd)
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
;	origin array associated with each given camera descriptor.
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
;===========================================================================
function cam_origin, cd, noevent=noevent
@core.include

 nv_notify, cd, type = 1, noevent=noevent
 _cd = cor_dereference(cd)
 return, _cd.origin
end
;===========================================================================



