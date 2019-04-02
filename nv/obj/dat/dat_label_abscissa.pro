;=============================================================================
;+
; NAME:
;	dat_label_abscissa
;
;
; PURPOSE:
;	Returns the abscissa label associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	label_abscissa = dat_label_abscissa(dd)
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
;	String giving the abscissa label.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 12/2016
;	
;-
;=============================================================================
function dat_label_abscissa, dd, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 return, (*_dd.dd0p).label_abscissa
end
;===========================================================================



