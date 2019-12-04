;===========================================================================
;+
; NAME:
;	cam_exposure
;
;
; PURPOSE:
;       Returns the exposure duration of each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	exposure = cam_exposure(cd)
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
;       Exposure duration associated with each given camera descriptor.
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
function cam_exposure, cd, noevent=noevent
@core.include

 nv_notify, cd, type = 1, noevent=noevent
 _cd = cor_dereference(cd)
 return, _cd.exposure
end
;===========================================================================



