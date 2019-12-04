;=============================================================================
;+
; NAME:
;	dat_set_maintain
;
;
; PURPOSE:
;	Replaces the maintain flag in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_maintain, dd, maintain
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	maintain:	New maintain flag.
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
pro dat_set_maintain, dd, maintain, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 (*_dd.dd0p).maintain = maintain

 if(maintain EQ 2) then dat_unload_data, _dd

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
