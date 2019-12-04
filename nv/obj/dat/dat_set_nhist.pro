;=============================================================================
;+
; NAME:
;	dat_set_nhist
;
;
; PURPOSE:
;	Changes the number of past states archived in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_nhist, dd, nhist
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	nhist:	New nhist value.
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
pro dat_set_nhist, dd, nhist, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 dap = (*_dd.dd0p).data_dap
 data_archive_set, dap, nhist=nhist
 (*_dd.dd0p).data_dap = dap

 (*_dd.dd0p).dap_index = (*_dd.dd0p).dap_index < (nhist-1) > 0

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
