;=============================================================================
;+
; NAME:
;	ray_sub_point_graphic
;
;
; PURPOSE:
;	Iterates to find the point on the surface of the globe where the 
;	given ray is closest to the surface.
;
; CATEGORY:
;	NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;    result = ray_sub_point_graphic(gbx, v, r)
;
;
; ARGUMENTS:
;  INPUT:
;	gbx:	Any subclass of GLOBE.
;
;	v:	Array (nv,3) giving the ray origins in the BODY frame.
;
;	r:	Array (nv,3) giving the ray directions in the BODY frame.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	normal:	Array (nv,3) of surface normals at each closest
;	approach.
;
;
; RETURN: 
;	Array (nv,3) of closest approach poitns in the BODY frame.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;	
;-
;=============================================================================
function ray_sub_point_graphic, pd, v, r, vv=vv, normal=normal

 epsilon = 1d-5

 ;---------------------------------------
 ; initial guess
 ;---------------------------------------
 range = v_mag(v)


 ;-----------------------------
 ; iterate
 ;-----------------------------
 done = 0
 while(NOT done) do $
  begin
   rr = r*(range#make_array(3,val=1d))
   vrr = v + rr
   normal = v_unit(glb_get_surface_normal(/body, pd, vrr))

   theta = v_angle(r, normal)
   phi = !dpi/2d - theta

   w = where(phi GT epsilon)
   if(w[0] EQ -1) then done = 1 $
   else range = range - phi*v_mag(vrr)
  end

 p = glb_intersect(pd, vrr, -normal)

 dist = v_mag(p - vrr##make_array(2,val=1d))
 w = where(dist EQ min(dist))
 
 return, p[w,*]
end
;=============================================================================
