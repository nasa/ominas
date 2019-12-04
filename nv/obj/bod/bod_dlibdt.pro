;===========================================================================
;+
; NAME:
;	bod_dlibdt
;
;
; PURPOSE:
;       Returns the frequency of each libration vector for each given
;       body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	dlibdt = bod_dlibdt(bx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	bx:	 Array (nt) of any subclass of BODY descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Values of the frequency of each libration vector associated
;       with each given body descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;===========================================================================
function bod_dlibdt, bd, noevent=noevent
@core.include
 nv_notify, bd, type = 1, noevent=noevent
 _bd = cor_dereference(bd)
 return, _bd.dlibdt
end
;===========================================================================
