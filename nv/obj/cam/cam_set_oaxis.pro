;===========================================================================
;+
; NAME:
;	cam_set_oaxis
;
;
; PURPOSE:
;       Replaces the oaxis array for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_oaxis, cd, oaxis
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Array (nt) of CAMERA descriptors.
;
;       oaxis:	Array (2,nt) of new oaxis values.
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
pro cam_set_oaxis, cd, oaxis, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.oaxis=oaxis

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



