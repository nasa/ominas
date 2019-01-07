;=============================================================================
; ominas_planet::init
;
;=============================================================================
function ominas_planet::init, _ii, crd=crd0, bd=bd0, sld=sld0, gbd=gbd0, pd=pd0, $
@plt__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(pd0)) then struct_assign, pd0, self
 void = self->ominas_globe::init(ii, crd=crd0, bd=bd0, sld=sld0, gbd=gbd0, $
@glb__keywords_tree.include
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
 self.abbrev = 'PLT'
 self.tag = 'PD'

 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_planet__define
;
;
; PURPOSE:
;	Class structure for the PLANET class.
;
;
; CATEGORY:
;	NV/LIB/PLT
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS: NONE
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
pro ominas_planet__define

 struct = $
    { ominas_planet, inherits ominas_globe $
    }

end
;===========================================================================



