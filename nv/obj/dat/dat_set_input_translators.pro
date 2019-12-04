;=============================================================================
;+
; NAME:
;	dat_set_input_translators
;
;
; PURPOSE:
;	Replaces the input_translators value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_input_translators, dd, input_translators
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	input_translators:	New input_translators value.
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
pro dat_set_input_translators, dd, input_translators, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.input_translators_p = input_translators

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
