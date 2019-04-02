;=============================================================================
;+
; NAME:
;	dat_set_tf_keyvals
;
;
; PURPOSE:
;	Replaces the transform keyvals value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_tf_keyvals, dd, keyvals
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyvals:	New keyvals.
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
pro dat_set_tf_keyvals, dd, keyvals, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.tf_keyvals_p = keyvals

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
