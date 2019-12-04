;===========================================================================
;+
; NAME:
;	rng_set_primary
;
;
; PURPOSE:
;	Replaces the primary string in each given ring descriptor.
;
;
; CATEGORY:
;	NV/LIB/RNG
;
;
; CALLING SEQUENCE:
;	rng_set_primary, rd, primary
;
;
; ARGUMENTS:
;  INPUT: 
;	rd:	Array (nt) of STATION descriptor.
;
;	primary:	Array (nt) of primary strings.
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
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro rng_set_primary, rd, xd, noevent=noevent
@core.include

 _rd = cor_dereference(rd)

 _rd.__PROTECT__primary_xd=xd

 cor_rereference, rd, _rd
 nv_notify, rd, type = 0, noevent=noevent
end
;===========================================================================



