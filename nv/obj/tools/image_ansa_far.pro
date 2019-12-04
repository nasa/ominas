;=============================================================================
;+
; NAME:
;       image_ansa_far
;
;
; PURPOSE:
;	Computes ring ansa longitudes assuming observer is very far from the 
;	rings.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       lons = image_ansa_far(cd, rd)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	dkx:	Any subclass of DISK.
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (2) of longitudes
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function image_ansa_far, cd, rd

 z = (bod_orient(rd))[2,*]
 c = (bod_orient(cd))[1,*]

 a1 = bod_inertial_to_body(rd, v_unit(v_cross(c,z)))
 a2 = -a1

 dsk_pts = dsk_body_to_disk(rd, [a1, a2])
 lons = dsk_pts[*,1]

 return, lons
end
;===================================================================================
