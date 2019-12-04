;=============================================================================
;+
; NAME:
;	dat_set_output_translators
;
;
; PURPOSE:
;	Replaces the output_translators value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_output_translators, dd, output_translators
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	output_translators:	New output_translators value.
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
pro dat_set_output_translators, dd, output_translators, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.output_translators_p = output_translators

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
