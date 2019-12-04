;=============================================================================
;+
; NAME:
;	dat_tr_keyvals
;
;
; PURPOSE:
;	Returns the translator keywords/values associated with a data descriptor.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	data = dat_tr_keyvals(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
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
; RETURN:
;	The translator keywords/values associated with the data descriptor.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2008
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_tr_keyvals, dd, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)
 return, *_dd.tr_keyvals_p
end
;===========================================================================



