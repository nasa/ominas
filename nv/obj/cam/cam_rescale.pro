;===========================================================================
;+
; NAME:
;	cam_rescale
;
;
; PURPOSE:
;       Produces a new camera descriptor describing an image of the same 
;	angluar dimensions, but with a new scale, specified by camera scale.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_rescale, cd, scale
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	Array (nt) of CAMERA descriptors to modify.
;
;	scale:	Array (2,1,nt) of new camera scales.
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
pro cam_rescale, cd, scale, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 ratio = _cd.scale/scale

 _cd.size = _cd.size*ratio
 _cd.oaxis = _cd.oaxis*ratio
 _cd.scale = scale

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================

