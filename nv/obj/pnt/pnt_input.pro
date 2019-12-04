;=============================================================================
;+
; NAME:
;	pnt_input
;
;
; PURPOSE:
;	Returns the input description associated with a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	input = pnt_input(ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:	POINT object.
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
;	The input description associated with the POINT object.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pnt_set_input
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_input, ptd, noevent=noevent
 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)
 return, _ptd.input
end
;===========================================================================



