;=============================================================================
;+
; NAME:
;       ray_points
;
;
; PURPOSE:
;       Computes points along rays.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       ray_pts = ray_points(r, v, np, dp)
;
;
; ARGUMENTS:
;  INPUT:
;       r:	Array (nt) of inertial ray origins.
;
;       v:	Array (nt) of inertial ray directions, of unit length.
;
;	np:	Number of points to compute on each ray.
;
;	dp:	Point spacing.
;
;  OUTPUT:
;       NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	cd:	Optional array (nt) of camera descriptors.
;
;  OUTPUT: NONE
;
; RETURN: 
;	If no camera descriptor is given, an array (np,3,nt) of inertial
;	position vectors is returned.  If cd is given, an array (2,np,nt)
;	of image points is returned.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function ray_points, r, v, np, dp, cd=cd

 n = n_elements(r)/3

 ray_pts = dblarr(np,3,n)

 for i=0, n-1 do $
  ray_pts[*,*,i] = r[i,*]##make_array(np, val=1d) + $
      v[i,*]##make_array(np, val=1d) * (dindgen(np)*dp#make_array(3,val=1d)) 


 if(n GT 1) then ray_pts = reform(transpose(ray_pts, [0,2,1]), n*np, 3)

 if(keyword_set(cd)) then ray_pts = inertial_to_image_pos(cd, ray_pts)

 return, ray_pts
end
;==============================================================================
