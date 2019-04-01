;=============================================================================
;+
; NAME:
;       glb_image_bounds
;
;
; PURPOSE:
;	Determines globe coordinate ranges visible in an image described
;	by a given camera descriptor.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       glb_image_bounds, cd, gbx, $
;	        latmin=latmin, latmax=latmax, lonmin=lonmin, lonmax=lonmax
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descripor.
;
;	gbx:	Any subclass of GLOBE.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	corners:	Array(2,2) giving corers of image region to consider.
;
;	slop:	Number of pixels by which to expand the image in each
;		direction.
;
;
;  OUTPUT: 
;	latmin:	Minimum latitude in image.
;
;	latmax:	Maximum latitude in image.
;
;	lonmin:	Minimum longitude in image.
;
;	lonmax:	Maximum longitude in image.
;
;	border_pts_im:	Array (2,np) of points along the edge of the image.
;
;	status:	-1 if no globe in the image, 0 otherwise.
;
;
; RETURN: NONE
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
pro glb_image_bounds, cd, pd, slop=slop, border_pts_im=border_pts_im, $
       corners=corners, center=center, $
       latmin=latmin, latmax=latmax, lonmin=lonmin, lonmax=lonmax, status=status, $
       viewport=viewport

 status = -1

 ;-----------------------------------
 ; compute image border points
 ;-----------------------------------
 if(NOT keyword_set(border_pts_im)) then $
         border_pts_im = get_image_border_pts(cd, corners=corners, center=center, viewport=viewport)
 np = n_elements(border_pts_im)/2

 if(keyword_set(slop)) then corners = !null $
 else slop = 1

 ;-----------------------------------
 ; compute globe intersections
 ;-----------------------------------
 edge_pts_body = image_to_body(cd, pd, border_pts_im, hit=w)

 if(w[0] EQ -1) then edge_pts_body = 0 $
 else edge_pts_body = edge_pts_body[w,*]

 ;--------------------------------------------------
 ; get points on limb
 ;--------------------------------------------------
 limb_pts_body = $
     glb_get_limb_points(pd, bod_inertial_to_body_pos(pd, bod_pos(cd)))

 ;----------------------------------------------
 ; combine points
 ;----------------------------------------------
 nedge = n_elements(edge_pts_body)/3
 nlimb = n_elements(limb_pts_body)/3
 n = nedge + nlimb
 body_pts = dblarr(n,3)
 if(nedge GT 0) then body_pts[0:nedge-1,*] = edge_pts_body
 if(nlimb GT 0) then body_pts[nedge:*,*] = limb_pts_body


 ;----------------------------------------------
 ; remove points outside image
 ;----------------------------------------------
 image_pts = body_to_image_pos(cd, pd, body_pts)

 w = in_image(cd, image_pts, slop=slop, corners=corners)
 if(w[0] EQ -1) then return $
 else body_pts = body_pts[w,*]


 ;----------------------------------------------
 ; compute min/max lat/lon
 ;----------------------------------------------
 surf_pts = glb_body_to_globe(pd, body_pts)


 ;- - - - - - - - - - - - - - -
 ; latitude
 ;- - - - - - - - - - - - - - -
 lat = surf_pts[*,0]
 latmin = min(lat) & latmax = max(lat)

 ;- - - - - - - - - - - - - - -
 ; longitude
 ;- - - - - - - - - - - - - - -
 v = bod_inertial_to_body_pos(pd, bod_pos(cd))
 sub_latlon, pd, v, sclat, sclon

 lon = reduce_angle(surf_pts[*,1])
 sclon = reduce_angle(sclon)

 ll = reduce_angle(lon - sclon, max=!dpi)
 lonmin = reduce_angle(sclon + min(ll))
 lonmax = reduce_angle(sclon + max(ll))

 ;-  -  -  -  -  -  -  -  -  -  -
 ; test poles
 ;-  -  -  -  -  -  -  -  -  -  -
; pole_pts_surf = [ tr([!dpi/2d, 0d, glb_get_radius(pd, !dpi/2d, 0d)]), $
;                   tr([-!dpi/2d, 0d, glb_get_radius(pd, -!dpi/2d, 0d)]) ]
 pole_pts_surf = [ tr([!dpi/2d, 0d, 0d]), $
                   tr([-!dpi/2d, 0d, 0d]) ]
 pole_pts_image = $
          surface_to_image(cd, pd, pole_pts_surf, body_pts=pole_pts_body)

 w = in_image(cd, pole_pts_image, slop=slop, corners=corners)
 ww = glb_hide_points_limb(pd, $
             bod_inertial_to_body_pos(pd, bod_pos(cd)), pole_pts_body)

 if(((where(w EQ 0))[0] NE -1) $
      AND ((where(ww EQ 0))[0] EQ -1)) then $
  begin
   latmax = !dpi/2d
   lonmin = 0d & lonmax = 2d*!dpi
  end

 if(((where(w EQ 1))[0] NE -1) $
      AND ((where(ww EQ 1))[0] EQ -1)) then $
  begin
   latmin = -!dpi/2d
   lonmin = 0d & lonmax = 2d*!dpi
  end


 status = 0
end
;===========================================================================
