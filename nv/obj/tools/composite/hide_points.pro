;=============================================================================
;+
; NAME:
;       hide_points
;
;
; PURPOSE:
;	Hides points with respect to given object and observer.
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = hide_points(bx, view_pts, hide_pts)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:		Array (nt) of any subclass of BODY.
;
;	view_pts:	Columns vector giving the BODY-frame position of the viewer.
;
;	hide_pts:	Array (nv) of BODY-frame vectors giving the points to hide.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;   INPUT: 
;	rm:	If set, points are flagged for being in front of or behind
;		the globe, rather then just behind it.
;
;	limb:	If set, hide wrt to limb, where applicable.  Assumes points lie
;		on the surface of the body.
;
;   OUTPUT: NONE
;
;
; RETURN:
;	Subscripts of the points in p that are hidden by the object.  
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale	3/2017
;-
;=============================================================================
function hide_points, bx, view_pts, hide_pts, rm=rm, limb=limb

; this needs to handle both kinds of bodies in one call.  See body_to_surface, e.g.

 if(NOT keyword_set(hide_pts)) then return, 0

 class = (cor_class(bx))[0]

 gbx = cor_select(bx, 'GLOBE', /class)
 dkx = cor_select(bx, 'DISK', /class)

 if(keyword_set(gbx)) then $
  begin
   if(keyword_set(limb)) then $
                        return, glb_hide_points_limb(gbx, view_pts, hide_pts)
   return, glb_hide_points(bx, view_pts, hide_pts, rm=rm)
  end

 if(keyword_set(dkx)) then return, dsk_hide_points(bx, view_pts, hide_pts, rm=rm)

end
;==========================================================================
