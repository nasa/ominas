;=============================================================================
;+
; NAME:
;	dsk_dlibmdt
;
;
; PURPOSE:
;	Returns dlibmdt for each given disk descriptor.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dlibmdt = dsk_dlibmdt(dkd)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	dkd:	 Any subclass of DISK.
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
;	dlibmdt value associated with each given disk descriptor.
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
function dsk_dlibmdt, dkd, noevent=noevent
@core.include
 
 nv_notify, dkd, type = 1, noevent=noevent
 _dkd = cor_dereference(dkd)
 return, _dkd.dlibmdt
end
;===========================================================================



