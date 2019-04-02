;=============================================================================
;+
; NAME:
;       str_get_mag
;
;
; PURPOSE:
;       Calculates the apparent visual magnitude for each given star descriptor.
;
;
; CATEGORY:
;       NV/LIB/STR
;
;
; CALLING SEQUENCE:
;       result = str_get_mag(sd)
;
;
; ARGUMENTS:
;  INPUT:
;       sd:    Array (nt) of star descriptors.
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;  INPUT: 
;	od:	Observer descriptor.  If not given, the absolute magnitude is
;		returned.
;
;  OUTPUT: NONE
;
; RETURN:
;       An array (nt) of magnitues.
;
; PROCEDURE:
;       Calls str_body to get the position vector.  The position is assumed
;       to be in meters and the Luminosity (sds.lum) is in J/sec.  Absolute
;       visual magnitude is calculated by using the formula for the Sun.
;       Mv = 4.83 - 2.5 log (L/Lsun)
;       where Lsun = 3.826e+26 J/sec
;       Visual magnitude is corrected by using the distance modulus.
;       m = Mv + 5 log (dist/pc) - 5
;       where pc = 3.085678e+16 m  (parsec)
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle, 5/1998
;	Modified by:	Haemmerle, 12/2000
; 	Adapted by:	Spitale, 5/2016
;       Modified by:    Haemmerle, 7/2017
;
;
;-
;=============================================================================
function str_get_mag, sd, od=od
@core.include

 pc = const_get('parsec')
 Lsun = const_get('Lsun')

 abs = 4.83d - 2.5d*alog10(str_lum(sd)/Lsun)
 if(NOT keyword_set(od)) then return, abs

 n_str = n_elements(sd)

 dist_parsec = v_mag(bod_pos(sd)-bod_pos(make_array(n_str, val=od)))/pc
 dist_parsec = reform(dist_parsec, n_str, /overwrite)

 corr = 5.d*alog10(dist_parsec) - 5.d

 return, abs + corr
end
;===========================================================================
