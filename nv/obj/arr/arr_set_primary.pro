;===========================================================================
;+
; NAME:
;	arr_set_primary
;
;
; PURPOSE:
;	Replaces the primary string in each given array descriptor.
;
;
; CATEGORY:
;	NV/LIB/arr
;
;
; CALLING SEQUENCE:
;	arr_set_primary, ard, primary
;
;
; ARGUMENTS:
;  INPUT: 
;	ard:	Array (nt) of ARRAY descriptors.
;
;	primary:	Array (nt) of primary descriptors.
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
pro arr_set_primary, ard, primary, noevent=noevent
@core.include

 _ard = cor_dereference(ard)

 _ard.__PROTECT__primary_xd=primary

 cor_rereference, ard, _ard
 nv_notify, ard, type = 0, noevent=noevent
end
;===========================================================================



