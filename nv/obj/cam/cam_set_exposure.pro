;===========================================================================
;+
; NAME:
;	cam_set_exposure
;
;
; PURPOSE:
;       Replaces the exposure duration for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_exposure,cd,exposure
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	     Array (nt) of CAMERA descriptors.
;
;       exposure:    Array (nt) of new exposure values.
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
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro cam_set_exposure, cd, exposure, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.exposure=exposure

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



