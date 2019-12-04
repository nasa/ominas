;=============================================================================
;+
; NAME:
;	dat_set_input_keyvals
;
;
; PURPOSE:
;	Replaces the input_keyvals value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_input_keyvals, dd, input_keyvals
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	input_keyvals:	New input_keyvals value.
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
pro dat_set_input_keyvals, dd, input_keyvals, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.input_keyvals_p = input_keyvals

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
