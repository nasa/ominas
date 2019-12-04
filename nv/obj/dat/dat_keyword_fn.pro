;=============================================================================
;+
; NAME:
;	dat_keyword_fn
;
;
; PURPOSE:
;	Returns the keyword_fn value associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	data = dat_keyword_fn(dd)
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
;	The keyword_fn value associated with the data descriptor.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_keyword_fn, dd, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)
 return, _dd.keyword_fn
end
;===========================================================================



