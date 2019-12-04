;=============================================================================
;+
; NAME:
;	sld_assign
;
;
; PURPOSE:
;	Replaces fields in a SOLID object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/SLD
;
;
; CALLING SEQUENCE:
;	sld_assign, sld, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	sld:		SOLID object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	SOLID fields to set.
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
;	sld_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro sld_assign, xd, noevent=noevent, $
@sld__keywords_tree.include
end_keywords

 _xd = cor_dereference(xd)
@sld_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
