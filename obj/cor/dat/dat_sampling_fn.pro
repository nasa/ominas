;=============================================================================
;+
; NAME:
;	dat_sampling_fn
;
;
; PURPOSE:
;	Returns the sampling function associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	sampling_fn = dat_sampling_fn(dd)
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
;	The sampling_fn associated with the data descriptor.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dat_set_sampling_fn
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_sampling_fn, dd, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent

 _dd = cor_dereference(dd)

 return, _dd.sampling_fn
end
;===========================================================================



