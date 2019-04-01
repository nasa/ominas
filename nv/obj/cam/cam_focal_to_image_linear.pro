;===========================================================================
;+
; NAME:
;	cam_focal_to_image_linear
;
;
; PURPOSE:
;       Transforms the given array of points in the focal plane
;       coordinate system to an array of points in the image
;       coordinate system using a linear model that assumes that
;       distances in the image are proportional to angles in the focal
;       plane.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	image_pts = cam_focal_to_image_linear(cd, focal_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	        Array (nt) of CAMERA descriptors.
;
;	focal_pts:	Array (2,nv,nt) of points in the camera focal frame.
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
; RETURN:
;       Array (2,nv,nt) of points in the image coordinate system.
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
function cam_focal_to_image_linear, cd, v
@core.include

 _cd = cor_dereference(cd)

 sv = size(v)
 nv = 1
 if(sv[0] GT 1) then nv = sv[2]
 nt = n_elements(_cd)

 vv = reform(v, 2,nv*nt)

 MM = make_array(nv, val=1)

 scale = dblarr(2,nv,nt,/nozero)
 scale[0,*,*] = [_cd.scale[0,*,*]]##MM
 scale[1,*,*] = [_cd.scale[1,*,*]]##MM

 oaxis = dblarr(2,nv,nt,/nozero)
 oaxis[0,*,*] = [_cd.oaxis[0,*,*]]##MM
 oaxis[1,*,*] = [_cd.oaxis[1,*,*]]##MM

 return, reform(reform(vv/scale + oaxis, 2,nv,nt, /over), /over)
end
;===========================================================================



