;=============================================================================
;+
; NAME:
;	dat_set_tr_output_keyvals
;
;
; PURPOSE:
;	Replaces the tr_output_keyvals value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_tr_output_keyvals, dd, output_keyvals
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	output_keyvals:	New tr_output_keyvals value.
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
pro dat_set_tr_output_keyvals, dd, output_keyvals, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.tr_output_keyvals_p = output_keyvals

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
