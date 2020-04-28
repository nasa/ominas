;=============================================================================
;+
; NAME:
;	centric_to_graphic_lat
;
;
; PURPOSE:
;	Converts planetocentric latitudes to planetographic latitudes.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = centric_to_graphic_lat(a, b, lat)
;
;
; ARGUMENTS:
;  INPUT:
;	a:	Polar radius.
;
;	b:	Equatorial radius.
;
;	lat:	Planetographic latitudes.
;
;  OUTPUT: NONE
;
;
; KEYWORDS: NONE
;
;
; RETURN:
;	Planetocentric latitudes.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
function centric_to_graphic_lat, a, b, lat
 return, atan(b/a * tan(lat))
end
;=============================================================================
