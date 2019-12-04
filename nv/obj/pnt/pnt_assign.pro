;=============================================================================
;+
; NAME:
;	pnt_assign
;
;
; PURPOSE:
;	Replaces fields in a POINT object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_assign, ptd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	POINT fields to set.
;
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
;	pnt_assign_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		12/2015
;	
;-
;=============================================================================
pro pnt_assign, xd, noevent=noevent, $
@pnt__keywords_tree.include
end_keywords
;timer, t=_t

 _xd = cor_dereference(xd)
@pnt_assign.include
 cor_rereference, xd, _xd
;timer, 'aa', t=_t

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
;timer, 'bb', t=_t
end
;===========================================================================
