;===========================================================================
;+
; NAME:
;	cam_set_scale
;
;
; PURPOSE:
;       Replaces the scale array for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_scale, cd, scale
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Array (nt) of CAMERA descriptors.
;
;	scale:	Array (2,nt) of new scale values.
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
pro cam_set_scale, cd, scale, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.scale=scale

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



