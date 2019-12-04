;=============================================================================
;+
; NAME:
;	dat_set_output_fn
;
;
; PURPOSE:
;	Replaces the output_fn value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_output_fn, dd, output_fn
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	output_fn:	New output_fn value.
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
pro dat_set_output_fn, dd, output_fn, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 _dd.output_fn = output_fn

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
