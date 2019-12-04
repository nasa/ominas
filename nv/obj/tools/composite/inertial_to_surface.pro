;=============================================================================
;+
; NAME:
;       inertial_to_surface
;
;
; PURPOSE:
;       Transforms vectors in inertial coordinates to surface coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = inertial_to_surface(bx, inertial_pts)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:             Array of nt object descriptors (subclass of BODY).
;
;	inertial_pts:   Array (nv x 3 x nt) of inertial vectors.
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
;       Array (nv x 3 x nt) of surface coordinates.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 6/2018
;-
;=============================================================================
function inertial_to_surface, bx, p

 if(NOT keyword_set(p)) then return, 0

 nv = (size(p, /dim))[0]
 nt = n_elements(bx)
 result = dblarr(nv,3,nt)

 gbx = cor_select(bx, 'GLOBE', /class, indices=ii_gbx)
 dkx = cor_select(bx, 'DISK', /class, indices=ii_dkx)
 ii_bx = rm_list_item(lindgen(nt), [ii_gbx, ii_dkx], only=-1)

 if(keyword_set(gbx)) then $
            result[*,*,ii_gbx] = inertial_to_globe(gbx, p[*,*,ii_gbx])
 if(keyword_set(dkx)) then $
            result[*,*,ii_dkx] = inertial_to_disk(dkx, p[*,*,ii_dkx])
;; if(ii_bx[0] NE -1) then $
;;            result[*,*,ii_bx] = bod_body_to_radec(bx[ii_bx], p[*,*,ii_bx])

 return, result
end
;===========================================================================
