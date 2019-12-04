; docformat = 'rst rst'
;+
;
; :Private:
;
;-


;===========================================================================
;++
; NAME:
;	_glb_get_surface_normal_body
;
;
; PURPOSE:
;	Computes the surface normals of a GLOBE object at the given 
;	body-frame positions.  This is an internal routine.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	n = _glb_get_surface_normalbody(_gbd, r)
;
;
; ARGUMENTS:
;  INPUT: 
;	_gbd:	Array (nt) of GLOBE structures.
;
;	r:	Array (nv,3) of surface positions in the BODY frame.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nonorm:	If set, the returned vectors are not normalized.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (nv, 3, nt) of surface unit normals in the BODY frame.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2016
;	
;-
;===========================================================================
function _glb_get_surface_normal_body, _gbd, r, nonorm=nonorm

 nv = (size(r))[1]
 nt = n_elements(_gbd)

 radii = (_gbd.radii)[linegen3x(nv,3,nt)]
 result = r/radii^2

 if(keyword_set(nonorm)) then return, result
 return, v_unit(result)
end
;=============================================================================
