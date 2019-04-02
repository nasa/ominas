;=============================================================================
;+
; NAME:
;	dat_slice_convert
;
;
; PURPOSE:
;	Conerts samples in a slice to samples in the source array.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	dat_slice_convert, dd, samples
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	samples:	Samples to convert.  If none given, then all samples
;			in the dd array are used.
;
;  OUTPUT: 
;	samples:	Converted samples.
;
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		7/2018
;	
;-
;=============================================================================
pro dat_slice_convert, dd, samples, noevent=noevent

 slice = dat_slice(dd, dd0=dd0, noevent=noevent)
 if(NOT keyword_set(dd0)) then return


return
; if(NOT keyword_set(samples)) then samples = lindgen(...)

;; samples = ...
end
;===========================================================================



