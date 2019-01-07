;=============================================================================
; ominas_map::init
;
;=============================================================================
function ominas_map::init, _ii, crd=crd0, md=md0, $
@map__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(md0)) then struct_assign, md0, self
 void = self->ominas_core::init(ii, crd=crd0,  $
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
 self.abbrev = 'MAP'
 self.tag = 'MD'

 ;----------------------------------------------------------------------
 ; default size and projection are [0,0] and 'NONE' respectively
 ;----------------------------------------------------------------------
 if(keyword_set(size)) then self.size = size[*,ii] $
 else size = lonarr(2)

 if(keyword_set(projection)) then map_set_projection, self, decrapify(projection[ii]) $
 else map_set_projection, self, 'NONE'

; if(keyword_set(projection)) then self.projection = decrapify(projection[ii]) $
; else projection = 'NONE'


 if(keyword_set(units)) then self.units = units[*,ii] $
 else self.units = [1d,1d]

 ;----------------------------------------------------------------------
 ; other defaults depend on projection 
 ;----------------------------------------------------------------------
 _md0 = map_lookup_defaults(self)

 origin = decrapify(origin)
 if(keyword_set(origin)) then self.origin = origin[*,ii] $
 else self.origin = _md0.origin

 center = decrapify(center)
 if(keyword_set(center)) then self.center = center[*,ii] $
 else self.center = _md0.center

 range = decrapify(range)
 if(keyword_set(range)) then self.range = range[*,*,ii] $
 else self.range = [[-1d100,1d100], [-1,1]*!dpi]

 radii = decrapify(radii)
 if(n_elements(radii) NE 0) then self.radii = radii[*,ii] $ 
 else self.radii[*] = 1d

 if(keyword_set(scale)) then self.scale = decrapify(scale[*,ii]) $
 else self.scale = _md0.scale

 if(keyword_set(pole)) then self.pole = decrapify(pole[ii]) $
 else self.pole = _md0.pole

;;; if(keyword_set(fn_data)) then map_set_fn_data, md0, fn_data

 if(keyword_set(graphic)) then self.graphic = decrapify(graphic[ii])

 if(keyword_set(west)) then self.west = decrapify(west[ii])

 if(keyword_set(rotate)) then self.rotate = decrapify(rotate[ii])
 
 



 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_map__define
;
;
; PURPOSE:
;	Class structure fo the MAP class.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	projection:	
;		String giving the map projection, e.g., RECTANGULAR, 
;		ORTHOGRAPHIC.  Map transformation functions are named
;		map_image_to_map_<projection> and map_map_to_image_<projection>.
;
;		Methods: map_projection, map_set_projection
;
;
;	units:	2-element array (lat,lon) to converts map radians to other
;  		units (map radians/unit).  
;
;		Methods: map_units, map_set_units
;
;
;	size:	2-element array giving the map size in pixels.
;
;		Methods: map_size, map_set_size
;
;
;	scale:	Map scale (units/angle) at the center of the map.
;
;		Methods: map_scale, map_set_scale
;
;
;	center:	2-element array giving the map coordinates of the
;		center of the map.
;
;		Methods: map_center, map_set_center
;
;
;	origin:	2-element array giving the image coordinates corresponding
;		to the center of the map.
;
;		Methods: map_origin, map_set_origin
;
;
;	range:	2x2-element array giving the map coordinates of the
;		lat/lon ranges of the map.
;
;		Methods: map_range, map_set_range
;
;
;	rotate:	Code specifying a rotation to be applied to the map, as in the
;		IDL 'rotate' function.
;
;
;	graphic:
;		Flag indicating whether latitudes are represented
;		using the planetocrntric or planetographic convention.
;
;	west:	Flag indicating that longitudes are measured to the west.  
;
;	radii:	3-element array giving ellipsoid radii to use in projections.  
;		Only the relative ratios are important.  All elements are 
;		set to 1 by default.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
pro ominas_map__define

 pole = {ominas_map_pole, lon:0d0, lat:0d0, rot:0d0}

 struct = $
    { ominas_map, inherits ominas_core, $
	projection:		  '', $		; Name of map projection 
	units:	 	  [1d,1d],$		; Converts map radians to other
						;  units (map radians/unit).
	size:		  lonarr(2), $		; [x,y] size of map in pixels
	scale:		  0d, $			; map 'scale'; Actually zoom.
	origin:		  dblarr(2), $		; image coords of map center
	center:		  dblarr(2), $		; lat,lon of map center
	pole:		  pole, $		; location of the map projection's pole
	range:		  dblarr(2,2), $	; lat,lon map ranges
	radii:		  dblarr(3), $		; ref. radii of triaxial ellipsoid

	graphic:	  0b, $			; If set, planetographic 
						;  lats are used.
	west:		  0b, $			; If set, west longitudes 
						;  are used.

	rotate:		  0b, $			; Rotate value as in idl 'rotate'

	fn_data_p:	   nv_ptr_new()}	; data for user functions

end
;===========================================================================



