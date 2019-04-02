;=============================================================================
; ominas_station::init
;
;=============================================================================
function ominas_station::init, _ii, crd=crd0, bd=bd0, std=std0, $
@stn__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(bd0)) then struct_assign, bd0, self
 void = self->ominas_body::init(ii, crd=crd0, bd=bd0,  $
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
 self.abbrev = 'STN'
 self.tag = 'STD'

 if(keyword__set(surface_pt)) then self.surface_pt = decrapify(surface_pts[*,*,ii])


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_station__define
;
;
; PURPOSE:
;	Class structure for the STATION class.
;
;
; CATEGORY:
;	NV/LIB/STN
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	surface_pt:	Vector giving the surface coordinates of the 
;			stations location on the primary.  This 
;			is redundant with the location of bd, but it 
;			allows one to compute map coordinates without
;			a body descriptor present.
;
;			Methods: stn_surface_pt, stn_set_surface_pt
;
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
pro ominas_station__define

 struct = $
    { ominas_station, inherits ominas_body, $
	surface_pt:	 dblarr(1,3) $		; Surface coords of location.
    }

end
;===========================================================================



