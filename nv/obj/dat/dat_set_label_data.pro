;=============================================================================
;+
; NAME:
;	dat_set_label_data
;
;
; PURPOSE:
;	Changes the data label associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_label_data, dd, label_data
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	label_data:	New data label.
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
; 	Adapted by:	Spitale, 9/2018
;	
;-
;=============================================================================
pro dat_set_label_data, dd, label_data, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 (*_dd.dd0p).label_data = label_data

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
