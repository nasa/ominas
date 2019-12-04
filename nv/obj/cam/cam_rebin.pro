;===========================================================================
;+
; NAME:
;	cam_rebin
;
;
; PURPOSE:
;       Modifies the camera parameters to reflect a re-binning of the pixels.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_rebin, cd, bin
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	    Array (nt) of CAMERA descriptors.
;
;       bin:        Binning factor, can be non-integer.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
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
; 	Written by:	Spitale, 1/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro cam_rebin, cd, bin, noevent=noevent
@core.include

 _cd = cor_dereference(cd)

 _cd.size = _cd.size/bin
 _cd.oaxis = _cd.oaxis/bin
 _cd.scale = _cd.scale*bin

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



