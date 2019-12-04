;=============================================================================
;+
; NAME:
;       ta_to_az
;
;
; PURPOSE:
;	Computes azimuths relative to a given observer descriptor.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = ta_to_az(ta, dkx, bx)
;
;
; ARGUMENTS:
;  INPUT:
;	ta:	Longitude.
;
;	dkx:	Disk descriptor.
;
;	bx:	Object descriptor (subclass of BODY) describing the observer.
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
;       An array of azimuths.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function ta_to_az, ta, dkx, bx

 n = n_elements(ta)

 vref_inertial = get_disk_ref(dkx, bx)
 vref_disk = dsk_body_to_disk(dkx, $
               bod_inertial_to_body(dkx, vref_inertial))

 ta_ref = vref_disk[*,1]

 az = ta - make_array(n, val=ta_ref[0])

 return, az
end
;===========================================================================
