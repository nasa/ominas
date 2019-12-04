;=============================================================================
;+
; NAME:
;	pg_get_sky
;
;
; PURPOSE:
;	Obtains a globe descriptor describing the sky.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_sky()
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
;	radius:	 Radius to use for the globe.  Default is 15 billion light years.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Globe descriptor with inertial body descriptor and very large radius.
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;=============================================================================
function pg_get_sky, radius=radius
 
 if(NOT keyword_set(radius)) then radius = const_get('LY')*15d9

 gbd = glb_create_descriptors(1, $
		name='SKY', $
		bd=bod_inertial(), $
		radii=[1,1,1]*radius)
 return, gbd
end
;===========================================================================





