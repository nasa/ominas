;=============================================================================
;+
; NAME:
;	dat_redo
;
;
; PURPOSE:
;	Decrements the data archive index in the data descriptor.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	dat_redo, dd
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
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 7/2016
;	
;-
;=============================================================================
pro dat_redo, dd, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 nhist = n_elements(*(*_dd.dd0p).data_dap)
 ii = (*_dd.dd0p).dap_index
 if(ii EQ 0) then return

 data = data_archive_get((*_dd.dd0p).data_dap, ii-1)
 if(NOT keyword_set(data)) then return
;if(NOT data_archive_test((*_dd.dd0p).data_dap, ii-1) then, return

 (*_dd.dd0p).dap_index = (*_dd.dd0p).dap_index - 1

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
