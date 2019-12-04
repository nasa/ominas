;=============================================================================
;+
; NAME:
;	dat_set_keyword_fn
;
;
; PURPOSE:
;	Replaces the keyword_fn value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_keyword_fn, dd, keyword_fn
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword_fn:	New keyword_fn value.
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
pro dat_set_keyword_fn, dd, keyword_fn, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 _dd.keyword_fn = keyword_fn

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
