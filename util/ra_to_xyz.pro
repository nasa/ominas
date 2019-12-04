;=============================================================================
;+
; NAME:
;       ra_to_xyz
;
;
; PURPOSE:
;	Convert array of RA and DEC to an array of 1x3 position vectors 
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       ra_to_xyz, ra, dec, pos
;
;
; ARGUMENTS:
;  INPUT:
;        ra:	Array of Right Ascensions (in degrees)
;
;       dec:	Array of Declinations (in degrees)
;
;  OUTPUT:
;       pos:	An array of 1x3 column vectors dimensioned (1,3,n)
;
; KEYWORDS:
;
;       NONE
;
; RETURN:
;        An array of n 1x3 column vectors.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle 6/2000 
;                       
;-
;=============================================================================
pro ra_to_xyz, ra, dec, pos

 n = n_elements(ra)
 if(n_elements(dec) ne n) then $
                   nv_message, 'RA and DEC do not have same number of elements'

 ra_rad = ra*!dpi/180d
 dec_rad = dec*!dpi/180d

 pos = make_array(3,n,value=0d)
 pos[0,*] = cos(ra_rad)*cos(dec_rad)
 pos[1,*] = sin(ra_rad)*cos(dec_rad)
 pos[2,*] = sin(dec_rad)
 pos = reform(pos,1,3,n)

 end
