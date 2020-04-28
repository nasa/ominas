;=============================================================================
;+
; NAME:
;	dsk_set_radial_scale
;
;
; PURPOSE:
;	Replaces the radial scale in each given disk descriptor.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dsk_set_radial_scale, bx, radial_scale
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	 	Array (nt) of any subclass of DISK.
;
;	radial_scale:	 New radial_scale value.
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
pro dsk_set_radial_scale, dkd, radial_scale, noevent=noevent
@core.include
 
 _dkd = cor_dereference(dkd)

 _dkd.radial_scale = radial_scale

 cor_rereference, dkd, _dkd
 nv_notify, dkd, type = 0, noevent=noevent
end
;===========================================================================



