;===========================================================================
;+
; NAME:
;	sld_phase_parm
;
;
; PURPOSE:
;       Returns the phase function parameters for each given solid descriptor.
;
;
; CATEGORY:
;	NV/LIB/SLD
;
;
; CALLING SEQUENCE:
;	mass = sld_phase_parm(sld)
;
;
; ARGUMENTS:
;  INPUT:
;	sld:	 Array (nt) of any subclass of SOLID descriptors.
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
; RETURN:
;       Array (npht,nt) of phase function parameters associated with each 
;	given solid descriptor.
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
function sld_phase_parm, sld, noevent=noevent
@core.include

 nv_notify, sld, type = 1, noevent=noevent
 _sld = cor_dereference(sld)
 return, _sld.phase_parm
end
;===========================================================================
