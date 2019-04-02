;=============================================================================
;+
; NAME:
;       surface_to_inertial
;
;
; PURPOSE:
;       Transforms vectors in any surface coordinate system to inertial
;	coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = surface_to_inertial(bx, surface_pts)
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
;       Array (nv x 3 x nt) of inertial coordinates.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 6/2018
;-
;=============================================================================
function surface_to_inertial, bx, p

 if(NOT keyword_set(p)) then return, 0

 return, bod_body_to_inertial_pos(bx, $
           surface_to_body(bx, p))
end
;===========================================================================
