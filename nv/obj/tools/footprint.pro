;=============================================================================
;+
; NAME:
;       footprint
;
;
; PURPOSE:
;	Computes the footprint of a camera on a given body.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       surface_pts = footprint(cd, bx)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:		Camera descripor.  Only one allowed.
;
;	bx:		Body descriptors.
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: 
;	corners:	Array(2,2) giving corers of image region to consider.
;
;	slop:		Number of pixels by which to expand the image in each
;			direction.
;
;	image_pts:	Array (2,np) of points along the edge of the image.
;
;	sample:		Sampling rate; default is 1 pixel.
;
;
;  OUTPUT: 
;	image_pts:	Footprint points in the image frame.
;
;	body_p:		Array (nhit) of pointers to body footprint points for 
;			each body hit.
;
;	hit_indices:	Array (nhit) of bx indices.  
;
; RETURN: 
;	Array (nhit) of pointers to inertial footprint points for each body hit.  
;	Zero is returned if no bodies are hit.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale		5/2014
;
;-
;=============================================================================
function footprint, cd, bx, slop=slop, corners=corners, hit_indices=ii, $
                   image_pts=image_pts, body_p=body_p, sample=sample


 ;-----------------------------------
 ; compute image border points
 ;-----------------------------------
 if(NOT keyword_set(image_pts)) then $
              image_pts = get_image_border_pts(cd, corners=corners, sample=sample)
 np = n_elements(image_pts)/2


 ;-----------------------------------
 ; compute intersections
 ;-----------------------------------
 raytrace, image_pts, cd=cd, bx=bx, $
                  hit_matrix=body_pts, hit_list=ii, hit_indices=hit
 if(ii[0] EQ -1) then return, 0


 ;-----------------------------------
 ; compute inertial points
 ;-----------------------------------
 nhit = n_elements(ii)
 inertial_p = ptrarr(nhit)
 body_p = ptrarr(nhit)
 for i=0, nhit-1 do $
  begin
   w = where(hit EQ ii[i])
   inertial_p[i] = ptr_new(bod_body_to_inertial_pos(bx[ii[i]], body_pts[w,*]))
   body_p[i] = ptr_new(body_pts[w,*])
  end


 return, inertial_p
end
;================================================================================
