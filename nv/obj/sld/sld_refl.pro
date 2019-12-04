;=============================================================================
;+
; NAME:
;	sld_refl
;
;
; PURPOSE:
;	Computes a reflection function.
;
;
; CATEGORY:
;	NV/LIB/SLD
;
;
; CALLING SEQUENCE:
;	refl = sld_refl(sld, mu, mu0)
;
;
; ARGUMENTS:
;  INPUT:
;	sld:	 Globe descriptor.
;
;	mu:	 Cosine of the emission angle.
;
;	mu0:	 Cosine of the incidence angle.
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
;	Refletion function value for the given mu and mu0 parameters.
;
;
; PROCEDURE:
;	The function indicated by the refl_fn field of the solid descriptor
;	is called and its return value is passed through to the caller of
;	sld_phase.  
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
function sld_refl, sld, mu, mu0
@core.include

 _sld = cor_dereference(sld)
 return, call_function(_sld.refl_fn, mu, mu0, _sld.refl_parm)

end
;==================================================================================
