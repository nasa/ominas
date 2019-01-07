;=============================================================================
; ominas_solid::init
;
;=============================================================================
function ominas_solid::init, _ii, crd=crd0, bd=bd0, sld=sld0, $
@sld__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(sld0)) then struct_assign, sld0, self
 void = self->ominas_body::init(ii, crd=crd0, bd=bd0, $
@bod__keywords_tree.include
end_keywords)


 ;-------------------------------------------------------------------------
 ; Handle index errors: set index to zero and try again.  This allows a 
 ; single input to be applied to multiple objects, via multiple calls to
 ; this method.  In that case, all inputs must be given as single inputs.
 ;-------------------------------------------------------------------------
 catch, error
 if(error NE 0) then $
  begin
   ii = 0
   catch, /cancel
  end

 
 ;---------------------------------------------------------------
 ; assign initial values
 ;---------------------------------------------------------------
 self.abbrev = 'SLD'
 self.tag = 'SLD'
 npht = sld_npht()

 ;----------------------------------------
 ; dynamical parameters
 ;----------------------------------------
 if(keyword_set(GM)) then self.GM = GM[ii]
 if(keyword_set(mass)) then self.mass = mass[ii]


 ;----------------------------------------
 ; photometric parameters
 ;----------------------------------------
 if(keyword_set(refl_fn)) then self.refl_fn = refl_fn[ii]
 if(keyword_set(refl_parm)) then $
       self.refl_parm[0:(n_elements(refl_parm)<npht)-1] $
               = refl_parm[0:(n_elements(refl_parm)<npht)-1,ii]

 if(keyword_set(phase_fn)) then self.phase_fn = phase_fn[ii]
 if(keyword_set(phase_parm)) then $
       self.phase_parm[0:(n_elements(phase_parm)<npht)-1] $
               = phase_parm[0:(n_elements(phase_parm)<npht)-1,ii]

 self.albedo = 1
 if(defined(albedo)) then $
  begin
   w = where(albedo EQ 0)
   if(w[0] NE -1) then albedo[w] = 1
   self.albedo = albedo[ii]
  end

; if(keyword_set(opacity)) then self.opacity = decrapify(opacity[ii]) $
; else self.opacity = 1d


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_solid__define
;
;
; PURPOSE:
;	Class structure fo the SOLID class.
;
;
; CATEGORY:
;	NV/LIB/SLD
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	opacity: Normalized opacity for ray tracing.
;
;		Methods: sld_opacity, sld_set_opacity
;
;
;	GM:	Mass x gravitational constant.
;
;		Methods: sld_gm, sld_set_gm
;
;
;	mass:	Body mass.  This field and GM are kept in sync unless
;		/nosync is used in sld_set_mass or sld_set_gm.
;
;		Methods: sld_mass, sld_set_mass
;
;
;	phase_fn: String giving the name of a phase function to be defined as 
;		  follows:
;
;		  function <name>, mu, mu0, parm
;
;		  The function should return a value corresponding to the 
;		  phase function with emission cosine mu and incidence 
;		  cosine mu0.
;
;		  Methods: sld_phase_fn, sld_set_phase_fn
;
;
;	phase_parm:	Array (npht) of parameters to pass to the phase
;			function.
;
;		  Methods: sld_phase_parm, sld_set_phase_parm
;
;
;	refl_fn:  String giving the name of a reflection function to be defined as 
;		  follows:
;
;		  function <name>, mu, mu0, parm
;
;		  The function should return a value corresponding to the 
;		  reflection function with emission cosine mu and incidence 
;		  cosine mu0.
;
;		  Methods: sld_refl_fn, sld_set_refl_fn
;
;
;	refl_parm:	Array (npht) of parameters to pass to the reflection
;			function.
;
;		  Methods: sld_refl_parm, sld_set_refl_parm
;
;
;	extn_fn:  String giving the name of a extinction function to be defined as 
;		  follows:
;
;		  function <name>, p1, p2, parm
;
;		  The function should return a value corresponding to the 
;		  degree of extinction of a light ray traveling between
;		  body vectrs p1 and p2.
;
;		  Methods: sld_extn_fn, sld_set_extn_fn
;
;
;	extn_parm:	Array (npht) of parameters to pass to the extnection
;			function.
;
;		  Methods: sld_extn_parm, sld_set_extn_parm
;
;
;	albedo:	Bond albedo.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro ominas_solid__define

 npht = sld_npht()

 struct = $
    { ominas_solid, inherits ominas_body, $

	;----------------------------------------
	; photometric parameters
	;----------------------------------------
	refl_fn:	 '', $			; Photometric functions
	refl_parm:	 dblarr(npht), $
	phase_fn:	 '', $	
	phase_parm:	 dblarr(npht), $
	extn_fn:	 '', $	
	extn_parm: 	 dblarr(npht), $

	albedo:		 0d, $			; Bond albedo

	;----------------------------------------
	; dynamical parameters
	;----------------------------------------
	GM:		0d, $			; better for dynamics
	mass:		0d $			; mass

    }

end
;===========================================================================
