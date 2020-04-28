;=============================================================================
;+
; NAME:
;	map_east_to_west
;
;
; PURPOSE:
;	Converts longitudes from the eastward to the westward
;	convention.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	map_pts_g = map_east_to_west(md, map_pts_c)
;
;
; ARGUMENTS:
;  INPUT: 
;	md:	Array (nt) of map descriptors.
;
;	map_pts_c:	Array (2,nv,nt) of map points in which the 
;			longitudes are eastward.
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
; RETURN: 
;	Array (2,nv,nt) of map points in which the longitudes are 
;	westward.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/201y
;	
;-
;=============================================================================
function map_east_to_west, md, map_pts0
@core.include
 _md = cor_dereference(md)

 map_pts = map_pts0
 map_pts[1,*] = east_to_west_longitude(map_pts[1,*], max=!dpi)

 return, map_pts
end
;===========================================================================
