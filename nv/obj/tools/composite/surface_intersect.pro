;===========================================================================
;+
; NAME:
;	surface_intersect
;
;
; PURPOSE:
;	Computes the intersection of rays with surface objects.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;	int_pts = surface_intersect(bx, view_pts, ray_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:		Array (nt) of any subclass of BODY descriptors with
;			the expected surface parameters.
;
;	view_pts:	Array (nv,3,nt) giving ray origins in the BODY frame.
;
;	ray_pts:	Array (nv,3,nt) giving ray directions in the BODY frame.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	back:	If set, only the "back" points are returned.  If the observer 
;		is exterior, these are the interesections on the back side
;		of the body (if applicable); if the observer is interior, these 
;		intersections are behind the observer.
;
;  OUTPUT:
;	hit:	Array giving the indices of rays that hit objects in 
;		the forward direction.
;
;
;	back_pts:
;		Array (nv,3,nt) of "back" points in order of distance from
;		the observer.  If the observer is exterior, these are the 
;		intersections on the back side of the body, or those behind
;		the observer; if the observer is interior, these intersections 
;		are behind the observer.
;
;
; RETURN: 
;	Array (nv,3,nt) of points in the BODY frame corresponding to the
;	first intersections with the ray.  Zero vector is returned for points 
;	with no solution.
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
function surface_intersect, bx, view_pts, ray_pts, hit=hit, back_pts=back_pts

; this needs to handle both kinds of bodies in one call.  See body_to_surface, e.g.

 body_pts = !null
 back_pts = !null
 if(cor_isa(bx[0], 'GLOBE')) then $
          body_pts = glb_intersect(bx, view_pts, ray_pts, back_pts=back_pts, hit=hit) $
 else if(cor_isa(bx[0], 'DISK')) then $
          body_pts = dsk_intersect(bx, view_pts, ray_pts, hit=hit)

 return, body_pts
end
;===========================================================================



;===========================================================================
function _surface_intersect, bx, view_pts, ray_pts, hit=hit, back_pts=back_pts

 nv = (size(view_pts, /dim))[0]
 nt = n_elements(bx)
 result = dblarr(nv,3,nt)
 back_pts = dblarr(nv,3,nt)

 gbx = cor_select(bx, 'GLOBE', /class, indices=ii_gbx)
 dkx = cor_select(bx, 'DISK', /class, indices=ii_dkx)
 ii_bx = rm_list_item(lindgen(nt), [ii_gbx, ii_dkx], only=-1)

 if(keyword_set(gbx)) then $
  begin
   result[*,*,ii_gbx] = glb_intersect(gbx, view_pts[*,*,ii_gbx], ray_pts[*,*,ii_gbx], back_pts=_back_pts, hit=_hit)
   back_pts[*,*,ii_gbx] = _back_pts
   hit = append_array(hit, _hit, /pos)
  end

 if(keyword_set(dkx)) then $
  begin
   result[*,*,ii_dkx] = dsk_intersect(dkx, view_pts[*,*,ii_dkx], ray_pts[*,*,ii_dkx], hit=_hit)
   hit = append_array(hit, _hit, /pos)
  end

; if(ii_bx[0] NE -1) then $
;  begin
;   result[*,*,ii_dkx] = bod_body_to_radec(bx[ii_bx], ray_pts[*,*,ii_bx])
;   hit = append_array(hit, _hit, /pos)
;  end

 if(defined(hit)) then hit = decrapify(unique(hit))
help, hit
 return, result
end
;===========================================================================
