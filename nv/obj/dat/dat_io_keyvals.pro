;=============================================================================
;+
; NAME:
;	dat_io_keyvals
;
;
; PURPOSE:
;	Returns the I/O keyword/values associated with a data descriptor.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	data = dat_io_keyvals(dd)
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
;	The maintenance I/O keyword/values associated with the data descriptor.
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
function dat_io_keyvals, dd, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)
 return, *_dd.io_keyvals_p
end
;===========================================================================



