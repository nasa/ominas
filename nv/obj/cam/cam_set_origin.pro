;===========================================================================
;+
; NAME:
;	cam_set_origin
;
;
; PURPOSE:
;       Replaces the origin array for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_origin, cd, origin
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Array (nt) of CAMERA descriptors.
;
;       origin:	Array (2,nt) of new origin values.
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
pro cam_set_origin, cd, origin, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.origin=origin

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



