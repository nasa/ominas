;=============================================================================
;+
; NAME:
;	dat_set_compress
;
;
; PURPOSE:
;	Replaces the name of the compression function in a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_compress, dd, compress
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	compress:	String giving the name of a new compression function.
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
pro dat_set_compress, dd, compress, noevent=noevent
@core.include
 data = dat_data(dd)

 _dd = cor_dereference(dd)
 (*_dd.dd0p).compress = compress

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================



;=============================================================================
pro __dat_set_compress, dd, compress
@core.include
 data = dat_data(dd)

 _dd = cor_dereference(dd)
 (*_dd.dd0p).compress = compress
 cor_rereference, dd, _dd

 dat_set_data, dd, data		; this will trigger the data event
end
;===========================================================================
