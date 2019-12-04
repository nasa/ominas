;===========================================================================
;+
; NAME:
;	cam_subimage
;
;
; PURPOSE:
;       Produces a new camera descriptor corresponding to dividing the 
;	associated image as specified.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_subimage, cd, p0, nxy
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	Array (nt) of CAMERA descriptors to modify.
;
;	p0:	Starting corner of subimage.
;
;	size:	Array (2,1,nt) of image sizes.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
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
; 	Written by:	Spitale, 4/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro cam_subimage, cd, p0, size, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.size = size
 _cd.oaxis = _cd.oaxis - p0

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================

