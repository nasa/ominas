;=============================================================================
;+
; NAME:
;	pnt_set_input
;
;
; PURPOSE:
;	Replaces the input description field in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_input, ptd, input
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	input:		New input description.
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
;	pnt_input
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_input, ptd, input, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 _ptd.input = input

 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
