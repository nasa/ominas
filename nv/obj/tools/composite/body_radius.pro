;=============================================================================
;+
; NAME:
;       body_radius
;
;
; PURPOSE:
;	Returns the sizes of the given bodies.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       body_radius(bx)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:      Globe or Disk descriptor; nt.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;   INPUT: NONE
;
;   OUTPUT: NONE
;
;
; RETURN: 
;	nt-element array giving the size of each body.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function body_radius, bx

 nt = n_elements(bx)
 size = dblarr(nt)

 gbx = cor_select(bx, 'GLOBE', ind=ii, /class)
 if(keyword_set(gbx)) then size[ii] = (glb_radii(bx))[0,ii]

 dkx = cor_select(bx, 'DISK', ind=ii, /class)
 if(keyword_set(dkx)) then size[ii] = $
                  (dsk_sma(dkx))[0,1,ii] * (1d + (dsk_ecc(dkx))[0,1,ii])

 return, size
end
;=============================================================================
