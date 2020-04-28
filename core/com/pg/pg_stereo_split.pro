;=============================================================================
;+
; NAME:
;	pg_stereo_split
;
;
; PURPOSE:
;	Produces two camera descriptors whose positions are offset
;	in the +/-x image directions for computing stereo overlays.
;	
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	cds = pg_stereo_split(cd=cd)
;
;
; ARGUMENTS:
;  NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:		Camera descriptor to be split.
;
;	separation:	stereo separation for the new camera descriptors.
;
;  OUTPUT:
;	NONE
;
;
; RETURN:
;	Array containing two camera descriptors.
;
;
; STATUS:
;	xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; 7/29/2005
;	
;-
;=============================================================================
function pg_stereo_split, cd=cd, separation=separation

 cds = stereo_split(cd, sep=separation)

 return, cds
end
;=============================================================================
