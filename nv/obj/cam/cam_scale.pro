;===========================================================================
;+
; NAME:
;	cam_scale
;
;
; PURPOSE:
;       Returns the 2-element array giving the camera scale
;       (radians/pixel) in each direction for each given camera
;       descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	scale = cam_scale(cd)
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
;	Scale array associated with each given camera descriptor.
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
function cam_scale, cd, noevent=noevent
@core.include

 nv_notify, cd, type = 1, noevent=noevent
 _cd = cor_dereference(cd)
 return, _cd.scale
end
;===========================================================================



