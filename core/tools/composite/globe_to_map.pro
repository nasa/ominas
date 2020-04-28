;=============================================================================
;+
; NAME:
;       globe_to_map
;
;
; PURPOSE:
;       Transforms points in globe coordinates to map coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = globe_to_map(md, gbx, globe_pts)
;
;
; ARGUMENTS:
;  INPUT:
;	md:	Array of nt map descriptor.
;
;	gbx:	Array of nt globe descriptor.
;
;	globe_pts:	Array (nv x 3 x nt) of globe points.
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
function globe_to_map, md, gbx, globe_pts
 return, surface_to_map(md, gbx, globe_pts)
end
;===========================================================================
