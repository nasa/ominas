;=============================================================================
;+
; NAME:
;       image_to_surface
;
;
; PURPOSE:
;       Transforms points in image coordinates to surface coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = image_to_surface(cd, bx, p)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:      Array of nt camera or map descriptor
;
;	bx:      Array of nt object descriptors (subclass of BODY).
;
;	p:       Array (2 x nv x nt) of image points.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;   INPUT: NONE
;
;   OUTPUT: 
;	valid:	Indices of valid output points.
;
;       hit:	Array with one element per input point.  1 if point
;		falls on the body, 0 if not.
;
;	body_pts:	Body coordinates of output points.
;
;	discriminant:	Determinant D from the ray trace.  No solutions for
;			 D<0, two solutions for D=0, one slution for D>0.
;
;
; RETURN:
;       Array (nv x 3 x nt) of surface points.  In the case of a camera descriptor, ray
;	tracing is used.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function image_to_surface, cd, bx, p, body_pts=body_pts, $
                                discriminant=discriminant, hit=hit, valid=valid

; this needs to handle both kinds of bodies in one call.  See body_to_surface, e.g.

 if(NOT keyword_set(p)) then return, 0

 gbx = cor_select(bx, 'GLOBE', /class)
 dkx = cor_select(bx, 'DISK', /class)

 if(keyword_set(gbx)) then $
         return, image_to_globe(cd, gbx, p, body_pts=body_pts, $
                                           discriminant=discriminant, valid=valid)

 if(keyword_set(dkx)) then $
      return, image_to_disk(cd, dkx, p, body_pts=body_pts, hit=hit, valid=valid)

 hit = make_array(n_elements(p[0,*]), val=1b)
 valid = lindgen(n_elements(p[0,*]))
 return, image_to_radec(cd, p, body_pts=body_pts)
end
;==========================================================================
