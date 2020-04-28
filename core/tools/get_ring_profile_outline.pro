;=============================================================================
;+
; NAME:
;       get_profile_ring_outline
;
;
; PURPOSE:
;       Generates an outline of a ring sector.
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;    result = get_profile_ring_outline(cd, dkd, lon, rad, inertial=inertial)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	dkx:	Disk descriptor.
;
;	points:	Array (2,2) of image points defining corners of the sector.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	lon:	Array of disk longitudes for sector
;
;	rad:	Array of disk radii for sector
;
;	nrad:	Number of points in the radial direction.
;
;	nlon:	Number of points in the longitudinal direction.
;
;  OUTPUT:
;	inertial:	Inertial vectors corresponding to the ring sector 
;			outline points.
;
;
; RETURN:
;       Output is set of image points (x,y) defining the outline of the
;       ring sector.
;
; MODIFICATION HISTORY:
;       Written by:     Vance Haemmerle & Joe Spitale, 6/1998
;
;-
;=============================================================================
function get_ring_profile_outline, cd, dkd, points, rad=crad, lon=clon, $
       xlon=xlon, dir=dir, $
       nrad=nrad, nlon=nlon, slope=slope, inertial=inertial

 if(NOT keyword_set(slope)) then slope = 0d

 if(NOT keyword_set(crad)) then $
  begin
   dsk_pts = image_to_disk(cd, dkd, points)
   crad = dsk_pts[*,0]
   clon = dsk_pts[*,1]
  end


 if(keyword_set(xlon)) then dir = 2*(xlon GT clon[0]) - 1

 if(keyword_set(dir)) then $
  begin
   if(dir LT 0) then $
    if(clon[1] GT clon[0]) then $
     if(clon[1] GT !dpi/12d) then clon[1] = clon[1]-2d*!dpi
  end



 xlon = clon[1]

 lon = dindgen(nlon)/(nlon-1 > 1)*(clon[1]-clon[0]) + clon[0]
 rad = dindgen(nrad)/(nrad-1 > 1)*(crad[1]-crad[0]) + crad[0]

 npoints = 2*nrad + 2*nlon


 ;----------------------------------------
 ; ringplane coords of points in outline 
 ;----------------------------------------
 rad_pts = [ make_array(nlon,val=rad[0]), $
             rad, $
             make_array(nlon,val=rad[nrad-1]), $
             rotate(rad,2) ]

 lon_pts = [ lon, $
             make_array(nrad,val=lon[nlon-1]), $
             rotate(lon,2), $
             make_array(nrad,val=lon[0]) ]

 lon_pts = lon_pts + slope*(rad_pts-rad[0])

 rp_pts = dblarr(npoints,3)
 rp_pts[*,0] = rad_pts
 rp_pts[*,1] = lon_pts


 ;-------------------------------
 ; convert to image coordinates
 ;-------------------------------
 inertial = bod_body_to_inertial_pos(dkd, $
              dsk_disk_to_body(dkd, rp_pts))

 im_pts = cam_focal_to_image(cd, $
            cam_body_to_focal(cd, $
               bod_inertial_to_body_pos(cd, inertial)))


 return, im_pts
end
;===========================================================================



