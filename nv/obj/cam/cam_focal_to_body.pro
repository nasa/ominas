;===========================================================================
;+
; NAME:
;	cam_focal_to_body
;
;
; PURPOSE:
;       Transforms the given array of points from the camera focal
;       plane coordinate system to the body coordinate system.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	body_pts = cam_focal_to_body(cd, focal_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	        Array (nt) of CAMERA descriptors.
;
;	focal_pts:	Array (2,nv,nt) of points in the camera focal plane frame.
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
;       Array (nv,3,nt) of column vectors in the body frame.
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
function cam_focal_to_body, cd, v
@core.include

 _cd = cor_dereference(cd)

 sv = size(v)
 nv = 1
 if(sv[0] GT 1) then nv = sv[2]
 nt = n_elements(_cd)

 p=v[0,*,*]
 q=v[1,*,*]

 rho=sqrt(p^2+q^2)
 rho_safe=rho

 w=where(rho EQ 0.)					; rho_safe can be used
 if(w[0] NE -1) then rho_safe[w]=1.			; in the denominator 

 cos_theta=p/rho_safe					; (rho=0 <=> p=q=0) =>
 sin_theta=q/rho_safe					;  => result = [0,1,0]
 sin_rho=sin(rho)
 
 result=dblarr(nv,3,nt, /nozero)
 result[*,0,*] = cos_theta*sin_rho
 result[*,1,*] = cos(rho)
 result[*,2,*] = sin_theta*sin_rho


 return, result
end
;===========================================================================



