;=============================================================================
;+
; NAME:
;	dat_set_io_keyvals
;
;
; PURPOSE:
;	Replaces the I/O keyvals value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_io_keyvals, dd, keyvals
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyvals:	New io_keyvals value.
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
; 	Adapted by:	Spitale, 7/2018
;	
;-
;=============================================================================
pro dat_set_io_keyvals, dd, keyvals, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *_dd.io_keyvals_p = keyvals

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
