;=============================================================================
;+
; NAME:
;	rck_vertices
;
;
; PURPOSE:
;	Returns the vertices associated with a ROCK object.
;
;
; CATEGORY:
;	NV/OBJ/RCK
;
;
; CALLING SEQUENCE:
;	vertices = rck_vertices(rkd)
;
;
; ARGUMENTS:
;  INPUT:
;	rkd:	ROCK object.  
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	noevent:	If set, no event is generated.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	The vertices associated with the ROCK object;  0 if none exist.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	rck_set_vertices
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2018
;	
;-
;=============================================================================
function rck_vertices, rkd0, noevent=noevent

 nv_notify, rkd, type = 1, noevent=noevent
 _rkd = cor_dereference(rkd)

 return, *_rkd.vertices_p
end
;===========================================================================
