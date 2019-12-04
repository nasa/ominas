;=============================================================================
;+
; NAME:
;	rck_nv
;
;
; PURPOSE:
;	Returns the number of faces associated with a ROCK object.
;
;
; CATEGORY:
;	NV/OBJ/RCK
;
;
; CALLING SEQUENCE:
;	nv = rck_nv(rkd)
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
;	The number of faces associated with the ROCK object.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2018
;	
;-
;=============================================================================
function rck_nv, rkd0, noevent=noevent

 nv_notify, rkd, type = 1, noevent=noevent
 _rkd = cor_dereference(rkd)

 return, _rkd.nv
end
;===========================================================================
