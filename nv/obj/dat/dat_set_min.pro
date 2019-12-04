;=============================================================================
;+
; NAME:
;	dat_set_min
;
;
; PURPOSE:
;	Replaces the min value in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_min, dd, min
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	min:	New min value.
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
pro dat_set_min, dd, min, noevent=noevent, abscissa=abscissa
@core.include
 _dd = cor_dereference(dd)

 if(keyword_set(abscissa)) then _dd.abmin = min $
 else _dd.min = min

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
