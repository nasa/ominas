;=============================================================================
;+
; NAME:
;	bod_assign
;
;
; PURPOSE:
;	Replaces fields in a BODY object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/BOD
;
;
; CALLING SEQUENCE:
;	bod_assign, bd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	bd:		BODY object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	BODY fields to set.
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
;	bod_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro bod_assign, xd, noevent=noevent, $
@bod__keywords_tree.include
end_keywords

 _xd = cor_dereference(xd)
@bod_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
