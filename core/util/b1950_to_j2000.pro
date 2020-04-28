;=============================================================================
;+
; NAME:
;	b1950_to_j2000
;
;
; PURPOSE:
;	Transforms vectors from B1950 to J2000 coordinates, or visa-versa.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = b1950_to_j2000(v)
;
;
; ARGUMENTS:
;  INPUT:
;
;	      v:	An array of (n,3) column vectors in B1950
;			(or J2000 if /reverse is used)
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;
;	reverse:	If set, then J2000 to B1950 is done.
;
;  OUTPUT: NONE
;
;
; PROCEDURE:
;	Multiplies the input vector by a transformation matrix.  The
;  transformation matrix from B1950 to J2000 was defined using the
;  December 20, 1984 memo from Mert Davies (Rand) to Larry Soderblom (USGS)
;
;
; RETURN:
;	An array of vectors in the other coordinate system.
;
;
; RESTRICTIONS:
;	Output array is double precision.
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Haemmerle, 1/1999
;	
;-
;=============================================================================
function b1950_to_j2000, v, reverse=reverse

 b_to_j = [ $
   [0.999925707952362948d, -0.011178938137770019d, -0.004859003815359214d], $
   [0.011178938126427575d,  0.999937513349988764d, -0.000027162594714246d], $
   [0.004859003841454373d, -0.000027157926258510d,  0.999988194602374180d] ]

 if(keyword__set(reverse)) then vout = transpose(b_to_j)##v $
   else vout = b_to_j##v

return, vout
end
;=============================================================================
