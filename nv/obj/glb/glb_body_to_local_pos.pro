;=============================================================================
;+
; NAME:
;	glb_body_to_local_pos
;
;
; PURPOSE:
;       Converts the given column position vectors from the body coordinate
;       system to the local coordinate system.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	local_pts = glb_body_to_local_pos(gbd, body_org, body_pts)
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
;       Array (nv,3,nt) of column vectors in the local system representing 
;	vectors from body_org to body_pts.
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
function glb_body_to_local_pos, gbd, v, r
@core.include
 return, glb_body_to_local(gbd, v, r-v)
end
;=============================================================================
