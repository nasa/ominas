;=============================================================================
;+
; NAME:
;       image_to_body
;
;
; PURPOSE:
;       Transforms points in image coordinates to body coordinates on the
;	object.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = image_to_body(cd, bx, p)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:       Array of nt camera or map descriptor.
;
;	bx:       Array of nt body descriptor (subclass of GLOBE or DISK).
;
;	p:       Array (2 x nv x nt) of image points.
;
;  OUTPUT:
;       hit:	Array with one element per input point.  1 if point
;		falls on the body, 0 if not.
;
; RETURN:
;       Array (nv x 3 x nt) of body-frame vectors.  Zero vectors are returned if a
;	body point cannot be computed (e.g., the ray misses the planet).
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 8/2006
;-
;=============================================================================
function image_to_body, cd, bx, p, hit=hit, back=back, all=all

; if(keyword_set(cd)) then class = cor_class(cd[0])
 class = (cor_class(cd))[0]

 case class of 
  'MAP' : return, surface_to_body(bx, $
	            image_to_surface(cd, bx, p))

  'CAMERA' : $
	begin
	 np = n_elements(p)/2
	 dim = size(p, /dim)
	 if(n_elements(dim) GT 1) then np = dim[1] 
	 nt = n_elements(bx)

	 cam_pos = bod_pos(cd)
	 if(nt GT 1) then cam_pos = cam_pos[linegen3z(1,3,nt)]
	 v = bod_inertial_to_body_pos(bx, cam_pos)
	 v = v[linegen3x(np,3,nt)]
	 rr = image_to_inertial(cd, p)
	 r = bod_inertial_to_body(bx, rr)

         body_pts = surface_intersect(bx, v, r, hit=hit)

         if(NOT keyword_set(all)) then $
          begin
           if(keyword_set(back)) then body_pts = body_pts[np:*,*] $
           else body_pts = body_pts[0:np-1,*]
          end

	 return, body_pts
	end

  else :
 endcase


end
;=============================================================================
