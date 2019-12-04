;===========================================================================
;+
; NAME:
;	stn_set_primary
;
;
; PURPOSE:
;	Replaces the primary string in each given station descriptor.
;
;
; CATEGORY:
;	NV/LIB/STN
;
;
; CALLING SEQUENCE:
;	stn_set_primary, std, primary
;
;
; ARGUMENTS:
;  INPUT: 
;	std:	Array (nt) of STATION descriptors.
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
pro stn_set_primary, std, primary, noevent=noevent
@core.include

 _std = cor_dereference(std)

 _std.__PROTECT__primary_xd=primary

 cor_rereference, std, _std
 nv_notify, std, type = 0, noevent=noevent
end
;===========================================================================



