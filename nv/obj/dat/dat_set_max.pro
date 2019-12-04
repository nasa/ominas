;=============================================================================
;+
; NAME:
;	dat_set_max
;
;
; PURPOSE:
;	Replaces the max value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_max, dd, max
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	max:	New max value.
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
pro dat_set_max, dd, max, noevent=noevent, abscissa=abscissa
@core.include
 _dd = cor_dereference(dd)

 if(keyword_set(abscissa)) then _dd.abmax = max $
 else _dd.max = max

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
