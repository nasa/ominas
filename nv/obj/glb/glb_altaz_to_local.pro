;=============================================================================
;+
; NAME:
;	glb_altaz_to_local
;
;
; PURPOSE:
;       Converts the given column vectors from the altaz coordinate
;       system to the local coordinate system. 
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	local_pts = glb_altaz_to_local(gbd, altaz_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	        Array (nt) of any subclass of GLOBE descriptors.
;
;       altaz_pts:      Array (nv,3,nt) of column vectors in the altaz
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
function glb_altaz_to_local, gbd, r
@core.include
 
 _gbd = cor_dereference(gbd)

 sv = size(r)
 nv = sv[1]
 nt = n_elements(_gbd)

 alt = r[*,0,*]
 az = r[*,1,*]
 mag = r[*,2,*]

 result = dblarr(nv,3,nt, /nozero)

 proj = mag*cos(alt)
 result[*,0,*] = -proj * sin(az)
 result[*,1,*] = proj * cos(az)
 result[*,2,*] = mag * sin(alt)

 return, result
end
;=============================================================================
