;=============================================================================
;+
; NAME:
;	glb_assign
;
;
; PURPOSE:
;	Replaces fields in a GLOBE object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/GLB
;
;
; CALLING SEQUENCE:
;	glb_assign, gbd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	gbd:		GLOBE object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	GLOBE fields to set.
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
;	glb_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro glb_assign, xd, noevent=noevent, $
@glb__keywords_tree.include
end_keywords

 _xd = cor_dereference(xd)
@glb_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
