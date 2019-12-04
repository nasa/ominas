;=============================================================================
;+
; NAME:
;       globe_to_image
;
;
; PURPOSE:
;       Transforms points in body globe coordinates to image coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = globe_to_image(cd, gbd, p)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Array of nt Camera or map descriptor
;
;	gbx:	Array of nt Object descriptor (of type GLOBE)
;
;	p:	Array (nv x 3 x nt) of globe points
;
;  OUTPUT:
;	body_pts:	Body coordinates of output points.
;
;
; RETURN:
;       Array (2 x nv x nt) of image points.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale;
;-
;=============================================================================
function globe_to_image, cd, gbx, p, body_pts=body_pts, valid=valid

 nt = n_elements(cd)
 sv = size(p)
 nv = sv[1]

 class = (cor_class(cd))[0]

 case class of 
  'MAP' : return, map_map_to_image(cd, globe_to_map(cd, gbx, p), valid=valid)

  'CAMERA' : $
	begin
	 body_pts = glb_globe_to_body(gbx, p)
	 image_pts = inertial_to_image_pos(cd, $
                           bod_body_to_inertial_pos(gbx, body_pts))
         valid = lindgen(nv,nt)
	 return, image_pts
	end

  else :
 endcase

end
;==========================================================================
