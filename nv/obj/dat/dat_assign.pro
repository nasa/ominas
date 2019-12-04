;=============================================================================
;+
; NAME:
;	dat_assign
;
;
; PURPOSE:
;	Replaces fields in a CAMERA object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/CAM
;
;
; CALLING SEQUENCE:
;	dat_assign, cd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	cd:		CAMERA object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	CAMERA fields to set.
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
;	dat_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro dat_assign, xd, noevent=noevent, $
@dat__keywords_tree.include
end_keywords

 _xd = cor_dereference(xd)
@dat_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
