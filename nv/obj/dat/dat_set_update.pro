;=============================================================================
;+
; NAME:
;	dat_set_update
;
;
; PURPOSE:
;	Changes the update flag in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_update, dd, update
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	update:	New update flag.
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
pro dat_set_update, dd, update, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 (*_dd.dd0p).update = update

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
