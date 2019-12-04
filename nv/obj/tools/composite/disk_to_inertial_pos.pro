;=============================================================================
;+
; NAME:
;       disk_to_inertial_pos
;
;
; PURPOSE:
;       Transforms position vectors in disk coordinates to inertial 
;	coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = disk_to_inertial_pos(dkx, v)
;
;
; ARGUMENTS:
;  INPUT:
;	dkx:	Array of nt descriptors, subclass of DISK.
;
;	v:	Array (nv x 3 x nt) of disk points.
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
;       Array (nv x 3 x nt) of inertial points.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function disk_to_inertial_pos, rd, p

 return, bod_body_to_inertial_pos(rd, $
           dsk_disk_to_body(rd, p))

end
;==================================================================================
