;=============================================================================
;+
; NAME:
;	dat_set_dh
;
;
; PURPOSE:
;	Replaces the dh value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_dh, dd, dh
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	dh:	New dh value.
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
pro dat_set_dh, dd, dh, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 *(*_dd.dd0p).dhp = dh

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
