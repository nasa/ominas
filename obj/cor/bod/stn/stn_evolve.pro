;=============================================================================
;+
; NAME:
;	stn_evolve
;
;
; PURPOSE:
;	Computes new station descriptors at the given time offsets from the 
;	given station descriptors using the taylor series expansion 
;	corresponding to the derivatives contained in the given station 
;	descriptor.
;
;
; CATEGORY:
;	NV/LIB/STN
;
;
; CALLING SEQUENCE:
;	sdt = stn_evolve(stx, dt)
;
;
; ARGUMENTS:
;  INPUT: 
;	stx:	 Any subclass of STATION.
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
;	Array (nstd,ndt) of newly allocated descriptors, of class STATION,
;	evolved by time dt, where nstd is the number of stx, and ndt
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
function stn_evolve, std, dt, nodv=nodv, copy=copy
@core.include
 return, bod_evolve(std, dt, nodv=nodv, copy=copy)
end
;===========================================================================



