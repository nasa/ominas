;=============================================================================
;+
; NAME:
;	rng_evolve
;
;
; PURPOSE:
;	Computes new ring descriptors at the given time offsets from the 
;	given ring descriptors using the taylor series expansion 
;	corresponding to the derivatives contained in the given ring 
;	descriptor.
;
;
; CATEGORY:
;	NV/LIB/RNG
;
;
; CALLING SEQUENCE:
;	rdt = rng_evolve(rd, dt)
;
;
; ARGUMENTS:
;  INPUT: 
;	rd:	 Any subclass of RING.
;
;	dt:	 Time offset.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nodv:	 If set, derivatives will not be evolved.
;
;	copy:	If set, the evolved descriptor is copied into the input
;		descriptor and it is freed.  The input descriptor is returned.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (nrd,ndt) of newly allocated descriptors, of class RING,
;	evolved by time dt, where nrd is the number of rd, and ndt
;	is the number of dt.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function rng_evolve, rd, dt, nodv=nodv, copy=copy
@core.include
 return, dsk_evolve(rd, dt, nodv=nodv, copy=copy)
end
;===========================================================================



