;===========================================================================
;+
; NAME:
;	cam_resize
;
;
; PURPOSE:
;       Produces a new camera descriptor describing an image of the same 
;	angluar dimensions, but with a new scale, specified by image size.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_resize, cd, size
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	Array (nt) of CAMERA descriptors to modify.
;
;	size:	Array (2,1,nt) of new image sizes.
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
; 	Written by:	Spitale, 7/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro cam_resize, cd, size, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 ratio = _cd.size/size

 _cd.size = size
 _cd.oaxis = _cd.oaxis/ratio
 _cd.scale = _cd.scale*ratio

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================
nx1*scale1 = nx*scale

nx1 = nx*scale/scale1
scale1 = scale*nx/nx1
