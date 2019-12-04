;=============================================================================
;+
; NAME:
;	dsk_set_ecc
;
;
; PURPOSE:
;	Replaces ecc in each given disk descriptor.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dsk_set_ecc, bx, ecc
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	 Array (nt) of any subclass of DISK.
;
;	ecc:	 New ecc value.
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
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dsk_set_ecc, dkd, ecc, noevent=noevent
@core.include
 
 _dkd = cor_dereference(dkd)

; _dkd.ecc[*,0]=ecc[*,0]
; _dkd.ecc[*,1]=ecc[*,1]

 _dkd.ecc = ecc

 cor_rereference, dkd, _dkd
 nv_notify, dkd, type = 0, noevent=noevent
end
;===========================================================================



