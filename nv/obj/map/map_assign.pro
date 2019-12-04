;=============================================================================
;+
; NAME:
;	map_assign
;
;
; PURPOSE:
;	Replaces fields in a MAP object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/MAP
;
;
; CALLING SEQUENCE:
;	map_assign, md, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	md:		MAP object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	MAP fields to set.
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
;	map_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro map_assign, xd, noevent=noevent, $
@map__keywords_tree.include
end_keywords

 _xd = cor_dereference(xd)
@map_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
