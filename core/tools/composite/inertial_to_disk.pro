;=============================================================================
;+
; NAME:
;       inertial_to_disk
;
;
; PURPOSE:
;       Transforms vectors in inertial coordinates to disk coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = inertial_to_image(dkx, v)
;
;
; ARGUMENTS:
;  INPUT:
;	dkx:	Array of nt descriptors, subclass of DISK.
;
;	v:	Array (nv x 3 x nt) of inertial vectors.
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
;       Array (nv x 3 x nt) of disk points.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 2/2004
;
;-
;=============================================================================
function inertial_to_disk, dkx, v
 return, dsk_body_to_disk(dkx, $
           bod_inertial_to_body(dkx, v))
end
;=============================================================================
