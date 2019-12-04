;=============================================================================
;+
; NAME:
;	sld_phase
;
;
; PURPOSE:
;	Computes a phase function.
;
;
; CATEGORY:
;	NV/LIB/SLD
;
;
; CALLING SEQUENCE:
;	phase = sld_phase(sld, mu, mu0)
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
;	Phase function value for the given mu and mu0 parameters.
;
;
; PROCEDURE:
;	The function indicated by the phase_fn field of the solid descriptor
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
function sld_phase, sld, mu, mu0
@core.include

 _sld = cor_dereference(sld)
 return, call_function(_sld.phase_fn, mu, mu0, _sld.phase_parm)

end
;==================================================================================
