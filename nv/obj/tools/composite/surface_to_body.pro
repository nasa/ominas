;=============================================================================
;+
; NAME:
;       surface_to_body
;
;
; PURPOSE:
;       Transforms points in any surface coordinate system to body
;	coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = surface_to_body(bx, surface_pts)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:      Array of nt object descriptors (subclass of BODY).
;
;	surface_pts:       Array (nv x 3 x nt) of surface points
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
;       Array (nv x 3 x nt) of body coordinates.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function surface_to_body, bx, p

; this needs to handle both kinds of bodies in one call.  See body_to_surface, e.g.

 if(NOT keyword_set(p)) then return, 0

 gbx = cor_select(bx, 'GLOBE', /class)
 dkx = cor_select(bx, 'DISK', /class)

 if(keyword_set(gbx)) then return, glb_globe_to_body(gbx, p)
 if(keyword_set(dkx)) then return, dsk_disk_to_body(dkx, p)
 return, bod_radec_to_body(bx, p)

end
;===========================================================================
