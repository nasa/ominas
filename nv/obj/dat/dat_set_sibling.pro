;=============================================================================
;+
; NAME:
;	dat_set_sibling
;
;
; PURPOSE:
;	Changes the sibling in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_sibling, dd, dd_sibling
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	dd_sibling:	Data descriptor of new sibling.
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
pro dat_set_sibling, dd, dd_sibling, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 handle_value, _dd.sibling_dd_h, dd_sibling, /set

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
