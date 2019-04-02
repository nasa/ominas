;=============================================================================
;+
; NAME:
;	glb_local_to_body
;
; PURPOSE:
;       Converts the given column vectors from the local coordinate
;       system to the body coordinate system.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	body_pts = glb_local_to_body(gbd, body_org, local_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	        Array (nt) of any subclass of GLOBE descriptors.
;
;	body_org:	Array (nv,3,nt) of column vectors in the body
;                       frame representing coordinate systm origin points.
;
;       local_pts:      Array (nv,3,nt) of column vectors in the local
;                       system giving the vectors to transform.
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
;       Array (nv,3,nt) of column vectors in the body frame.
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
function glb_local_to_body, gbd, v, r
@core.include
 
 _gbd = cor_dereference(gbd)

 sv = size(v)
 nv = sv[1]
 nt = n_elements(_gbd)

 z = dblarr(nv,3,nt) & z[*,2,*] = 1d

 zenith = glb_get_surface_normal(/body, gbd, v)
 east = v_unit(v_cross(z, zenith))
 north = v_cross(zenith, east)

 M = dblarr(nv,3,3,nt)
 M[*,0,*,*] = east
 M[*,1,*,*] = north
 M[*,2,*,*] = zenith


 result = dblarr(nv,3,nt, /nozero)
 result[*,0,*] = v_inner(M[*,*,0,*],r)
 result[*,1,*] = v_inner(M[*,*,1,*],r)
 result[*,2,*] = v_inner(M[*,*,2,*],r)

 return, result
end
;=============================================================================
