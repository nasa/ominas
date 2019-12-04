;===========================================================================
;+
; NAME:
;	glb_point_cloud
;
;
; PURPOSE:
;	Generates a random cloud of body-frame vectors within a GLOBE object.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	v = glb_point_cloud(gbd, nv)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	GLOBE descriptor.
;
;	nv:	Number of points to generate.  
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
; RETURN: Array (nv x 3) of body-frame vectors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;===========================================================================
function glb_point_cloud, gbd, nv
common glb_point_cloud_block, seed
@core.include

 _gbd = cor_dereference(gbd)

 lat = (randomu(seed, nv)*!dpi - !dpi/2d)
 lon = (randomu(seed, nv) * 2d*!dpi)

 rmax = glb_get_radius(_gbd, lat, lon)
 rad = (randomu(seed, nv) * rmax)

 globe_pts = dblarr(nv,3)
 globe_pts[*,0] = lat
 globe_pts[*,1] = lon
 globe_pts[*,2] = rad - rmax

 return, glb_globe_to_body(_gbd, globe_pts)
end
;===========================================================================
