;=============================================================================
;+
; NAME:
;	cor_assign
;
;
; PURPOSE:
;	Replaces fields in a POINT object.  This is a fast way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	cor_assign, xd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	xd:		CORE object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	CORE fields to set.
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
;	cor_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		1/2017
;	
;-
;=============================================================================
pro cor_assign, xd, noevent=noevent, $
@cor__keywords.include
end_keywords

 _xd = cor_dereference(xd)
@cor_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
