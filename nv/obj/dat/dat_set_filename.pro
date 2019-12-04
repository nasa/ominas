;=============================================================================
;+
; NAME:
;	dat_set_filename
;
;
; PURPOSE:
;	Changes the file name associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_filename, dd, filename
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	filename:	New file name.
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
pro dat_set_filename, dd, filename, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 (*_dd.dd0p).filename = filename

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
