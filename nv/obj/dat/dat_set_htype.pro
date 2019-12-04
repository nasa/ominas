;=============================================================================
;+
; NAME:
;	dat_set_htype
;
;
; PURPOSE:
;	Changes the header type associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_htype, dd, htype
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	htype:		New header type.
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
; 	Written by:	Spitale, 9/2017
;	
;-
;=============================================================================
pro dat_set_htype, dd, htype, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 (*_dd.dd0p).htype = htype

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
