;===========================================================================
;+
; NAME:
;	rng_primary
;
;
; PURPOSE:
;	Returns the primary string for each given ring descriptor.
;
;
; CATEGORY:
;	NV/LIB/RNG
;
;
; CALLING SEQUENCE:
;	primary = rng_primary(rd)
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
;	Primary string associated with each given ring descriptor.
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
function rng_primary, rd, noevent=noevent
@core.include

 nv_notify, rd, type = 1, noevent=noevent
 _rd = cor_dereference(rd)
 return, _rd.__PROTECT__primary_xd
end
;===========================================================================



