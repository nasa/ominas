;===========================================================================
;+
; NAME:
;	bod_set_lib
;
;
; PURPOSE:
;       Replaces the phase of the libration vector at body time for
;       each given body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	bod_set_lib, bx, lib
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 Array (nt) of any subclass of BODY descriptors.
;
;	lib:	 Array (ndv,nt) of new phases of the libration vectors.
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
;===========================================================================
pro bod_set_lib, bd, lib, noevent=noevent
@core.include
 _bd = cor_dereference(bd)

 _bd.lib=lib

 cor_rereference, bd, _bd
 nv_notify, bd, type = 0, noevent=noevent
end
;===========================================================================
