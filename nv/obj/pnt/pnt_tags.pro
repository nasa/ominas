;=============================================================================
;+
; NAME:
;	pnt_tags
;
;
; PURPOSE:
;	Returns the tags associated with a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	tags = pnt_tags(ptd)
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
;	The tags associated with the POINT object.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pnt_set_tags
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_tags, ptd, noevent=noevent
 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)
 if(NOT ptr_valid(_ptd.tags_p)) then return, 0
 return, *_ptd.tags_p
end
;===========================================================================



