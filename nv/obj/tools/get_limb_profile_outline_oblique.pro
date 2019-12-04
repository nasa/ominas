;=============================================================================
;++
; NAME:
;       get_limb_profile_outline_oblique.  **incomplete**
;
;
; PURPOSE:
;       Generates an outline of an oblique limb sector.
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;	result = get_limb_profile_outline_oblique(cd, gbx, points)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	gbx:	Globe descriptor.
;
;	points:	Array (2,2) of image points defining opposite corners
;		of the sector.
;
;	point:	
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	NONE 
;
;  OUTPUT:
;	inertial:	Inertial vectors corresponding to the limb sector 
;			outline points.
;
;
; RETURN:
;       Array of image points defining the outline of the sector.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 1/2009
;
;-
;=============================================================================
function get_limb_profile_outline_oblique, cd, gbx, points, point, $
                                             nalt=nalt, naz=naz, dkd=dkd

 ;----------------------------------------
 ; construct disk descriptor on skyplane
 ;----------------------------------------
 dkd = dsk_create_descriptors(1)
 bod_set_pos, dkd, bod_pos(gbx)
 sma = dsk_sma(dkd)
 sma[0,0] = 0d & sma[0,1] = 1d
 zz = (bod_orient(cd))[1,*] 			; optic axis vector
 vv = (bod_orient(gbx))[2,*]			; planet axis
 yy = v_unit(v_cross(zz, vv)) 			
 xx = v_unit(v_cross(yy, zz))			; zero of azimuth along xx
 orient = [xx, yy, zz]

 dsk_set_sma, dkd, sma
 bod_set_orient, dkd, orient

 cam_pos_body = bod_inertial_to_body_pos(gbx, bod_pos(cd))

 ;----------------------------------------
 ; set up bounds if not given
 ;----------------------------------------
 dsk_pts = image_to_disk(cd, dkd, points,, body=body_pts)
 dsk_pt = image_to_disk(cd, dkd, point, body=body_pts)

 crads = dsk_pts[*,0]
 ss = sort(crads)
 crads = crads[ss]

 clons = dsk_pts[*,1]
 clons = clons[ss]

 crad = dsk_pt[*,0]
 clon = dsk_pt[*,1]

 cazs = -orb_lon_to_anom(dkd, clons, dkd)
 clons = orb_anom_to_lon(dkd, -cazs, dkd)

 caz = -orb_lon_to_anom(dkd, clon, dkd)
 clon = orb_anom_to_lon(dkd, -caz, dkd)

 cmags = v_mag(glb_get_limb_points(gbx, cam_pos_body, 2, alpha=cazs))
 cmag = v_mag(glb_get_limb_points(gbx, cam_pos_body, 1, alpha=caz))

 calts = crads - cmags
 crads = calts + cmags

 calt = crad - cmag
 crad = calt + cmag


 ;----------------------------------------
 ; compute limb points
 ;----------------------------------------
; save_azs = caz

 daz = (caz - cazs[1])[0]

 az_inner = dindgen(naz)*daz/double(naz-1) + cazs[0]
 az_outer = dindgen(naz)*daz/double(naz-1) + cazs[1]

 inner_limb_pts_body = glb_get_limb_points(gbx, cam_pos_body, naz, alpha=az_inner)
 outer_limb_pts_body = glb_get_limb_points(gbx, cam_pos_body, naz, alpha=az_outer)


 ;----------------------------------------
 ; scale limb points to desired altitudes
 ;----------------------------------------
 dirs = v_unit(inner_limb_pts_body, mag=mags)
 mags = mags # make_array(3,val=1d)
 inner_pts_body = dirs * (mags+calts[0])

 dirs = v_unit(outer_limb_pts_body, mag=mags)
 mags = mags # make_array(3,val=1d)
 outer_pts_body = dirs * (mags+calts[1])

 inner_pts = bod_body_to_inertial_pos(gbx, inner_pts_body)
 outer_pts = bod_body_to_inertial_pos(gbx, outer_pts_body)


 ;----------------------------------------
 ; compute image coordinates
 ;----------------------------------------
 pp = dindgen(nalt)##(points[*,1] - points[*,0])/double(nalt-1) + $
                                  points[*,0]#make_array(nalt,val=1d)

 end_pts0_disk = image_to_disk(cd, dkd, pp)
 end_pts1_disk = end_pts0_disk
 end_pts1_disk[*,1] = end_pts1_disk[*,1] - daz

 end_pts0 = bod_body_to_inertial_pos(dkd, $
              dsk_disk_to_body(dkd, end_pts0_disk))
 end_pts1 = bod_body_to_inertial_pos(dkd, $
              dsk_disk_to_body(dkd, end_pts1_disk))

 inertial_pts = [inner_pts, end_pts0, outer_pts, end_pts1]

 im_pts = cam_focal_to_image(cd, $
              cam_body_to_focal(cd, $
                bod_inertial_to_body_pos(cd, inertial_pts)))

; az = reduce_angle(az)
 return, poly_rectify(reform(im_pts), [naz, nalt, naz, nalt])
; return, reform(im_pts)
end
;=============================================================================
