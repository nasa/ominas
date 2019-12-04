;=============================================================================
;+
; NAME:
;	dsk_apply_scale
;
;
; PURPOSE:
;	Computes scaled radii.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	scaled_radii = dsk_apply_scale(dkd, radii)
;
;
; ARGUMENTS:
;  INPUT:
;	dkd:	 A single disk descriptors.
;
;	radii:	 Array of radii to convert.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	inverse:	If set, the operation is performed in reverse.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Scaled radii based onthe scale parameters in the disk descriptor.
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
;=============================================================================
function dsk_apply_scale, dkd, radii, inverse=inverse, noevent=noevent
@core.include
 
 nv_notify, dkd, type = 1, noevent=noevent
 _dkd = cor_dereference(dkd)
 
 scale = _dkd.scale

 if(keyword_set(inverse)) then return, (radii - scale[0]) / scale[1]
 return, scale[0] + radii*scale[1]
end
;===========================================================================
