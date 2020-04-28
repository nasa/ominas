;=============================================================================
;+
; NAME:
;       disk_to_map
;
;
; PURPOSE:
;       Transforms points in disk coordinates to map coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = disk_to_map(md, dkx, disk_pts)
;
;
; ARGUMENTS:
;  INPUT:
;	md:      Array of nt map descriptors.
;
;	dkx:     Array of nt disk descriptors.
;
;	disk_pts:       Array (nv x 3 x nt) of disk points.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;   INPUT: NONE
;
;   OUTPUT: NONE
;
;
; RETURN:
;       Array (2 x nv x nt) of map coordinates.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function disk_to_map, md, dkd, disk_pts
 return, surface_to_map(md, dkd, disk_pts)
end
;===========================================================================
