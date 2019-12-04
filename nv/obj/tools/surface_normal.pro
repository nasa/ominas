;===========================================================================
;+
; NAME:
;	surface_normal
;
;
; PURPOSE:
;	Computes the normal at points on a surface.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;	norm_pts = surface_normal(bx, r)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	Array (nt) of any subclass of BODY descriptors with
;		the expected surface parameters.
;
;	v:	Array (nv,3,nt) giving observer positions in the BODY frame.
;
;	r:	Array (nv,3,nt) giving surface positions in the BODY frame.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	frame_bd:  Frame descriptor, if required for bx.
;
;	north:     Passed to dsk_surface_normal.  Causes surface normal
;	           to point north regardless of observer position.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (nv, 3, nt) of surface unit normals in the BODY frame.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;===========================================================================
function surface_normal, bx, v, r, frame_bd=frame_bd, north=north

; this needs to handle both kinds of bodies in one call.  See body_to_surface, e.g.

 gbx = cor_select(bx, 'GLOBE', /class)
 dkx = cor_select(bx, 'DISK', /class)

 if(keyword_set(gbx)) then norm_pts = glb_get_surface_normal(/body, gbx, r) $
 else if(keyword_set(dkx)) then $
       norm_pts = dsk_surface_normal(dkx, v, r, frame_bd=frame_bd, north=north)

 return, norm_pts
end
;===========================================================================
