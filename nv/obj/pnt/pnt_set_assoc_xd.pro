;=============================================================================
;+
; NAME:
;	pnt_set_assoc_xd
;
;
; PURPOSE:
;	Replaces the assoc_xd field in a CORE object.
;
;
; CATEGORY:
;	NV/SYS/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_assoc_xd, ptd, assoc_xd
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	assoc_xd:	New assoc_xd.
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
;	pnt_assoc_xd
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_assoc_xd, ptd, assoc_xd, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 _ptd.__protect__assoc_xd = assoc_xd

 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
