;===========================================================================
;+
; NAME:
;	bod_set_dlibdt
;
;
; PURPOSE:
;       Replaces the frequency of each libration vector for each given
;       body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	bod_set_dlibdt, bx, dlibdt
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 Array (nt) of any subclass of BODY descriptors.
;
;	dlibdt:	 Array (ndv,nt) of new frequencies.
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
pro bod_set_dlibdt, bd, dlibdt, noevent=noevent
@core.include
 _bd = cor_dereference(bd)

 _bd.dlibdt=dlibdt

 cor_rereference, bd, _bd
 nv_notify, bd, type = 0, noevent=noevent
end
;===========================================================================
