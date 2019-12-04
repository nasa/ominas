;=============================================================================
;+
; NAME:
;	dat_set_output_transforms
;
;
; PURPOSE:
;	Replaces the output_transforms value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_output_transforms, dd, output_transforms
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	output_transforms:	New output_transforms value.
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
pro dat_set_output_transforms, dd, output_transforms, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.output_transforms_p = output_transforms

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
