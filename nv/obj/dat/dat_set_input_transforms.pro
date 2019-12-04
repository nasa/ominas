;=============================================================================
;+
; NAME:
;	dat_set_input_transforms
;
;
; PURPOSE:
;	Replaces the input_transforms value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_input_transforms, dd, input_transforms
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	input_transforms:	New input_transforms value.
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
pro dat_set_input_transforms, dd, input_transforms, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.input_transforms_p = input_transforms

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
