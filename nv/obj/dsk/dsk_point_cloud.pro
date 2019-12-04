;===========================================================================
;+
; NAME:
;	dsk_point_cloud
;
;
; PURPOSE:
;	Generates a random cloud of body-frame vectors within a DISK object.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	v = dsk_point_cloud(dkd, nv)
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	DISK descriptor.
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
function dsk_point_cloud, dkd, nv
common dsk_point_cloud_block, seed
@core.include

 _dkd = cor_dereference(dkd)

 ta = (randomu(seed, nv) * 2d*!dpi)

 rmax = dsk_get_radius(_dkd, ta)
 rad = (randomu(seed, nv) * rmax)

 disk_pts = dblarr(nv,3)
 disk_pts[*,0] = rad
 disk_pts[*,1] = ta

 return, dsk_disk_to_body(_dkd, disk_pts)
end
;===========================================================================
