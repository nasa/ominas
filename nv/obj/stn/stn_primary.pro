;===========================================================================
;+
; NAME:
;	stn_primary
;
;
; PURPOSE:
;	Returns the primary string for each given station descriptor.
;
;
; CATEGORY:
;	NV/LIB/STN
;
;
; CALLING SEQUENCE:
;	primary = stn_primary(std)
;
;
; ARGUMENTS:
;  INPUT: 
;	std:	 Array (nt) of STATION descriptors.
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
;	Primary descriptor associated with each given station descriptor.
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
function stn_primary, std, noevent=noevent
@core.include

 nv_notify, std, type = 1, noevent=noevent
 _std = cor_dereference(std)
 return, _std.__PROTECT__primary_xd
end
;===========================================================================



