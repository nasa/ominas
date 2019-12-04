;=============================================================================
;+
; NAME:
;	dat_set_typecode
;
;
; PURPOSE:
;	Replaces the typecode value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_typecode, dd, typecode
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	typecode:	New typecode value.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
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
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_set_typecode, dd, typecode, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 (*_dd.dd0p).typecode = typecode

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
