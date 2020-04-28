;=============================================================================
;+
; NAME:
;	pg_get_celestial_sphere
;
;
; PURPOSE:
;	Obtains a globe descriptor describing the celestial sphere.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_celestial_sphere()
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	radius:	 Radius to use for the globe.  Default is 1d30.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Globe descriptor with inertial body descriptor and very large radii.
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;=============================================================================
function pg_get_celestial_sphere, radius=radius

 if(NOT keyword_set(radius)) then radius = 1d30

 gbd = glb_create_descriptors(1, $
		name='CELESTIAL SPHERE', $
		bd=bod_inertial(), $
		radii=[1,1,1]*radius)

 return, gbd
end
;===========================================================================





