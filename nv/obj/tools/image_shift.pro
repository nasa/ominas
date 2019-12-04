;=============================================================================
;+
; NAME:
;       image_shift
;
;
; PURPOSE:
;	Shifts an image by a specified (non-integer) amount using 
;	interpolation.  If applicable, the camera pont-spread function 
;	is accounted for in the interpolation.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       result = image_shift(image, dx, dy)
;
;
; ARGUMENTS:
;  INPUT:
;	image:	2-D array giving the image.
;
;	dx:	Offset in the x direction.
;
;	dy:	Offset in the y direction.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	cd:	Camera descriptor.
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Shifted image.
;
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function image_shift, image, dx, dy, cd=cd

 s = size(image, /dim)

 grid_x = (dindgen(s[0]) + dx)#make_array(s[1],val=1d)
 grid_y = (dindgen(s[1]) + dy)##make_array(s[0],val=1d)

 return, image_interp_cam(cd=cd, image, grid_x, grid_y)
end
;==================================================================================
