;=============================================================================
;+
; NAME:
;	target_altaz
;
;
; PURPOSE:
;	Computes altitude/azimuth of a target relative to a point on or near the
;	surface of a globe.
;
; CATEGORY:
;	NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;    result = target_altaz(bx, gbx, lat, lon, alt)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:	Array (nt) of any subclass of BODY giving the target.
;
;	gbx:	Array (nt) of any subclass of GLOBE.
;
;	lat:	Latitude of observer wrt gbx.
;
;	lon:	Longitude of observer wrt gbx.
;
;	alt:	Altitude of observer wrt gbx.
;
;  OUTPUT:
;        NONE
;
; KEYWORDS:
;  INPUT:
;	  cd:	Camera descriptor.
;
;         gd:   Optional generic descriptor containing cd.
;
;  OUTPUT:
;    profile:   The profile.
;
;      sigma:   Array giving the standard deviation at each point in the
;		profile.
;
;    distance:  Array giving the distance, in pixels, along the profile.
;
;
; RETURN:
;	Vector from observer to target in the altaz system.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;	
;-
;=============================================================================
function target_altaz, bx, pd, lat, lon, alt
 
; rad = glb_get_radius(pd[0], lat, lon)
; surf_pt = transpose([lat, lon, rad+alt])
 surf_pt = transpose([lat, lon, alt])

 body_pt = glb_globe_to_body(pd, surf_pt)

 altaz = glb_local_to_altaz(pd, $
           glb_body_to_local(pd, body_pt, $ 
             bod_inertial_to_body_pos(pd, bod_pos(bx))))

 return, altaz
end
;===================================================================================
