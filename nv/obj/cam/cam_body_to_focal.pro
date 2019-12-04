;===========================================================================
;+
; NAME:
;	cam_body_to_focal
;
;
; PURPOSE:
;       Transforms the given column vectors from the body coordinate
;       system to the camera focal plane coordinate system.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	focal_pts = cam_body_to_focal(cd, body_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	        Array (nt) of CAMERA descriptors.
;
;	body_pts:	Array (nv,3,nt) of column vectors in the body frame.
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
;       Array (2,nv,nt) of points in the camera focal plane frame.
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
function cam_body_to_focal, cd, v
@core.include

 _cd = cor_dereference(cd)

 sv = size(v)
 nv = sv[1]
 nt = n_elements(_cd)

 vv = v_mag(v)

 rho = acos(v[*,1,*]/vv)				; angles from optic axis

 hyp = sqrt( v[*,2,*]^2 + v[*,0,*]^2 )
 p = rho * v[*,0,*]/hyp					; rho*cos(theta)
 q = rho * v[*,2,*]/hyp					; rho*sin(theta)

 w=where(hyp EQ 0)
 if(w[0] NE -1) then p[w]=(q[w]=0.0)

 if((size(p))[0] EQ 3) then $
  begin
   result = dblarr(2,nv,nt, /nozero)
   result[0,*,*] = transpose(p, [1,0,2])
   result[1,*,*] = transpose(q, [1,0,2])
   return, result
  end $
 else return, [transpose(p), transpose(q)]
end
;===========================================================================



