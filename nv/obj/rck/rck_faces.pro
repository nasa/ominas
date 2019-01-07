;=============================================================================
;+
; NAME:
;	rck_faces
;
;
; PURPOSE:
;	Returns the faces associated with a ROCK object.
;
;
; CATEGORY:
;	NV/OBJ/RCK
;
;
; CALLING SEQUENCE:
;	faces = rck_faces(rkd)
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
;	The faces associated with the ROCK object;  0 if none exist.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	rck_set_faces
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2018
;	
;-
;=============================================================================
function rck_faces, rkd0, noevent=noevent

 nv_notify, rkd, type = 1, noevent=noevent
 _rkd = cor_dereference(rkd)

 return, *_rkd.faces_p
end
;===========================================================================
