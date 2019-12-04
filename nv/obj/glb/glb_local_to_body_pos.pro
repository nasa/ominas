;=============================================================================
;+
; NAME:
;	glb_local_to_body_pos
;
; PURPOSE:
;       Converts the given column position vectors from the local coordinate
;       system to the body coordinate system.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	body_pts = glb_local_to_body_pos(gbd, body_org, local_pts)
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
; 	Written by:	Spitale, 5/2018
;	
;-
;=============================================================================
function glb_local_to_body_pos, gbd, v, r
@core.include
 return, glb_local_to_body(gbd, v, r) + v
end
;=============================================================================
