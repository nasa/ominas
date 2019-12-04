;===========================================================================
;+
; NAME:
;	cam_size
;
;
; PURPOSE:
;	Returns the image size (in pixels) for each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	size = cam_size(cd)
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
;	Size array associated with each given camera descriptor.
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
function cam_size, cd, noevent=noevent, nx=nx, ny=ny
@core.include

 nv_notify, cd, type = 1, noevent=noevent
 _cd = cor_dereference(cd)
 nx = _cd.size[0]
 ny = _cd.size[1]
 return, _cd.size
end
;===========================================================================



