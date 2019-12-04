;=============================================================================
;+
; NAME:
;       get_image_vector
;
;
; PURPOSE:
;	Projects inertial vectors into an image.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       p = get_image_vector(cd, v)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Array (nt) of camera descriptors.
;
;	v:	Array (nv,3,nt) of vectors in the inertial frame.
;
;  OUTPUT:
;       NONE
;
;
; KEYOWRDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (2,nv,nt) of image vectors.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function get_image_vector, cd, v

 nt = n_elements(cd)
 nv = n_elements(v)/3/nt

 orient = bod_orient(cd)
 xx = orient[0,*,*]
 yy = orient[2,*,*]

 x = v_inner(xx, v)
 y = v_inner(yy, v)

 p = dblarr(2,nv,nt)
 p[0,*,*] = x
 p[1,*,*] = y

 return, p
end
;==================================================================================
