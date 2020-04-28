;=============================================================================
;+
; NAME:
;       minmax_latlon
;
;
; PURPOSE:
;	Computes latitide/longitude ranges visible in a given camera.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       minmax_latlon, cd, gbx, dkx
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	gbx:	Globe descriptor.
;
;	dkx:	Disk descriptor, for hiding points.
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: 
;	slop:	Amount by which to expand image border for search.
;
;  OUTPUT: 
;	latmin:	Southernmost latitude visible.
;
;	latmax:	Northernmost latitude visible.
;
;	lonmin:	Westernmost longitude visible.
;
;	lonmax:	Easternmost longitude visible.
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


;===========================================================================
; minmax_latlon
;
;  latmin = southernmost lat.
;  latmax = northernmost lat.
;  lonmin = westernmost lon.
;  lonmax = easternmost lon.
;
;===========================================================================
pro minmax_latlon, cd, pd, rd, slop=slop, $
      latmin=latmin, latmax=latmax, lonmin=lonmin, lonmax=lonmax, status=status

 status = -1
 latmin = (latmax = (lonmin = (lonmax = 0)))

 ;--------------------------------------------------
 ; get points on image border
 ;--------------------------------------------------
 border_pts_im = get_image_border_pts(cd)
 np = n_elements(border_pts_im)/2

 r = bod_inertial_to_body(pd, image_to_inertial(cd, border_pts_im))
 v = bod_inertial_to_body_pos(pd, bod_pos(cd) ## make_array(np, val=1d))
 edge_pts_body = glb_intersect(pd, v, r, dis=dis)
 w = where(dis GE 0)
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
 image_pts = inertial_to_image_pos(cd, $
                 bod_body_to_inertial_pos(pd, body_pts))
; w = dbp_in_image(cd, image_pts, slop=slop)
 w = in_image(cd, image_pts, slop=slop)
 if(w[0] EQ -1) then return $
 else body_pts = body_pts[w,*]

 ;----------------------------------------------
 ; remove points hidden by rings
 ;----------------------------------------------
 if(keyword__set(rd)) then $
  begin
   inertial_pts = bod_body_to_inertial_pos(pd, body_pts)
   dsk_pts = bod_inertial_to_body_pos(rd, inertial_pts)
   hide_sub = dsk_hide_points(rd, $
                bod_inertial_to_body_pos(rd, bod_pos(cd)), dsk_pts)
   if(hide_sub[0] NE -1) then $
    begin
     vis_sub = complement(dsk_pts[*,0], hide_sub)
;     if(vis_sub[0] EQ -1) then body_pts = 0 $
;     else body_pts = body_pts[vis_sub,*]
     if(vis_sub[0] EQ -1) then return
     body_pts = body_pts[vis_sub,*]
    end
  end

 ;----------------------------------------------
 ; compute min/max lat/lon
 ;----------------------------------------------
 surf_pts = glb_body_to_globe(pd, body_pts)

 ;- - - - - - - - - - - - - - -
 ; latitude
 ;- - - - - - - - - - - - - - -
 lat = surf_pts[*,0]
 latmin = min(lat) & latmax = max(lat)

 ;-  -  -  -  -  -  -  -  -  -  -
 ; test poles
 ;-  -  -  -  -  -  -  -  -  -  -
; pole_pts_surf = [ tr([!dpi/2d, 0d, glb_get_radius(pd, !dpi/2d, 0d)]), $
;                   tr([-!dpi/2d, 0d, glb_get_radius(pd, -!dpi/2d, 0d)]) ]
 pole_pts_surf = [ tr([!dpi/2d, 0d, 0d]), $
                   tr([-!dpi/2d, 0d, 0d]) ]
 pole_pts_image = $
          surface_to_image(cd, pd, pole_pts_surf, body_pts=pole_pts_body)

; w = dbp_in_image(cd, pole_pts_image, slop=slop)
 w = in_image(cd, pole_pts_image, slop=slop)
 ww = glb_hide_points_limb(pd, $
             bod_inertial_to_body_pos(pd, bod_pos(cd)), pole_pts_body)

 if(((where(w EQ 0))[0] NE -1) $
                   AND ((where(ww EQ 0))[0] EQ -1)) then latmax = !dpi/2d
 if(((where(w EQ 1))[0] NE -1) $
                   AND ((where(ww EQ 1))[0] EQ -1)) then latmin = -!dpi/2d


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

 status = 0

end
;===========================================================================
