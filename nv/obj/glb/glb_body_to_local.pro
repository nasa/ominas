;=============================================================================
;+
; NAME:
;	glb_body_to_local
;
;
; PURPOSE:
;       Converts the given column vectors from the body coordinate
;       system to the local coordinate system.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	local_pts = glb_body_to_local(gbd, body_org, body_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	        Array (nt) of any subclass of GLOBE descriptors.
;
;	body_org:	Array (nv,3,nt) of column vectors in the body
;                       frame representing coordinate system origin points.
;
;       body_pts:       Array (nv,3,nt) of column vectors in the body
;                       frame giving the vectors to transform.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Array (nv,3,nt) of column vectors in the local system.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function glb_body_to_local, gbd, v, r
@core.include
 
 _gbd = cor_dereference(gbd)

 sv = size(v)
 nv = sv[1]
 nt = n_elements(_gbd)

 z = dblarr(nv,3,nt) & z[*,2,*] = 1d

 zenith = glb_get_surface_normal(/body, gbd, v)
 east = v_unit(v_cross(z, zenith))
 north = v_cross(zenith, east)

 result = dblarr(nv,3,nt, /nozero)
 result[*,0,*] = v_inner(east, r)
 result[*,1,*] = v_inner(north, r)
 result[*,2,*] = v_inner(zenith, r)

 return, result
end
;=============================================================================
