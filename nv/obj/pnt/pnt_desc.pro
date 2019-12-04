;=============================================================================
;+
; NAME:
;	pnt_desc
;
;
; PURPOSE:
;	Returns the description associated with a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	desc = pnt_desc(ptd)
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
;	The description associated with the POINT object.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pnt_set_desc
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_desc, ptd, noevent=noevent
 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)
 return, _ptd.desc
end
;===========================================================================



