;=============================================================================
; ominas_array::init
;
;=============================================================================
function ominas_array::init, _ii, crd=crd0, ard=ard0, $
@arr__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(ard0)) then struct_assign, ard0, self
 void = self->ominas_core::init(ii, crd=crd0, $
@cor__keywords.include
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
 self.abbrev = 'ARR'
 self.tag = 'ARD'

 if(keyword__set(surface_pts)) then $
           self.surface_pts_p = nv_ptr_new(decrapify(surface_pts[*,*,ii]))


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_array__define
;
;
; PURPOSE:
;	Class structure for the ARRAY class.
;
;
; CATEGORY:
;	NV/LIB/ARR
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	surface_pts:	Vector giving the surface coordinates of the 
;			array points on the primary.  
;
;			Methods: arr_surface_pts, arr_set_surface_pts
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
; 	Adapted by:	Spitale, 5/2016
;-
;=============================================================================
pro ominas_array__define

 struct = $
    { ominas_array, inherits ominas_core, $
	surface_pts_p:	 ptr_new() $		; Surface coords of location.
    }

end
;===========================================================================



