;=============================================================================
;+
; NAME:
;	pnt_set_tags
;
;
; PURPOSE:
;	Replaces the tags in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_tags, ptd, tags
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	tags:		New tags array.
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
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pnt_tags
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_tags, ptd, tags, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 if(NOT keyword_set(_ptd.tags_p)) then _ptd.tags_p = nv_ptr_new(tags) $
 else *_ptd.tags_p = tags

 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
