;===========================================================================
;+
; NAME:
;	rng_desc
;
;
; PURPOSE:
;	Returns the description string for each given ring descriptor.
;
;
; CATEGORY:
;	NV/LIB/RNG
;
;
; CALLING SEQUENCE:
;	desc = rng_desc(rd)
;
;
; ARGUMENTS:
;  INPUT: 
;	rd:	 Array (nt) of RING descriptors.
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
;	Description string associated with each given ring descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
function rng_desc, rd, noevent=noevent
@core.include

 nv_notify, rd, type = 1, noevent=noevent
 _rd = cor_dereference(rd)
 return, _rd.desc
end
;===========================================================================



