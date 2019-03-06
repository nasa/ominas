;=============================================================================
;+
; NAME:
;	rck_nf
;
;
; PURPOSE:
;	Returns the number of vertices associated with a ROCK object.
;
;
; CATEGORY:
;	NV/OBJ/RCK
;
;
; CALLING SEQUENCE:
;	nf = rck_nf(rkd)
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
;	The number of vertices associated with the ROCK object.
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
function rck_nf, rkd0, noevent=noevent

 nf_notify, rkd, type = 1, noevent=noevent
 _rkd = cor_dereference(rkd)

 return, _rkd.nf
end
;===========================================================================
