;=============================================================================
; ominas_star::init
;
;=============================================================================
function ominas_star::init, _ii, crd=crd0, bd=bd0, sld=sld0, gbd=gbd0, sd=sd0, $
@str__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(sd0)) then struct_assign, sd0, self
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
 self.abbrev = 'STR'
 self.tag = 'SD'

 if(keyword_set(lum)) then self.lum = decrapify(lum[ii])
 if(keyword_set(sp)) then self.sp = decrapify(sp[ii])


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_star__define
;
;
; PURPOSE:
;	Class structure for the STAR class.
;
;
; CATEGORY:
;	NV/LIB/STR
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	lum:	Luminosity value.
;
;		Methods: str_lum, str_set_lum
;
;
;	sp:	Spectral class string.
;
;		Methods: str_sp, str_set_sp
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
pro ominas_star__define

 struct = $
    { ominas_star, inherits ominas_globe, $
	lum: 		 double(0), $		; Luminosity
	sp:		 '' $			; Spectral type
    }

end
;===========================================================================



