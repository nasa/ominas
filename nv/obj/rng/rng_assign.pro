;=============================================================================
;+
; NAME:
;	rng_assign
;
;
; PURPOSE:
;	Replaces fields in a RING object.  This is a convenient way of
;	setting multiple fields in one call, and only a single event is 
;	generated.
;
;
; CATEGORY:
;	NV/OBJ/RNG
;
;
; CALLING SEQUENCE:
;	rng_assign, rd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	rd:		RING object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	RING fields to set.
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
;	rng_set_*
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro rng_assign, xd, noevent=noevent, $
@rng__keywords_tree.include
end_keywords

 _xd = cor_dereference(xd)
@rng_assign.include
 cor_rereference, xd, _xd

 nv_notify, xd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
