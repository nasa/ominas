;=============================================================================
;+
; NAME:
;	dat_set_sampling_fn
;
;
; PURPOSE:
;	Replaces the sampling function associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_sampling_fn, dd, sampling_fn
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	sampling_fn:	New sampling function.
;
;  OUTPUT:
;	dd:	Modified data descriptor.
;
;
; KEYWORDS:
;  INPUT: 
;	data 	Data to be sent to the sampling function.
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
; SEE ALSO:
;	dat_sampling_fn
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_set_sampling_fn, dd, sampling_fn, data=data, noevent=noevent
@core.include
 if(keyword_set(data)) then dat_set_sampling_data, dd, data, /noevent

 _dd = cor_dereference(dd)

 _dd.sampling_fn = sampling_fn

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================



