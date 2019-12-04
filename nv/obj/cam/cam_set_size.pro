;===========================================================================
;+
; NAME:
;	cam_set_size
;
;
; PURPOSE:
;       Replaces the size array for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_size, cd, size
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	     Array (nt) of CAMERA descriptors.
;
;       size:        Array (2,nt) of new size values.
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
pro cam_set_size, cd, size, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.size=size

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



