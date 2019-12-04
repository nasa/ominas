;===========================================================================
;+
; NAME:
;	stn_read_array
;
;
; PURPOSE:
;	Reads an station array file.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	array = stn_read_array(filename)
;
;
; ARGUMENTS:
;  INPUT: 
;	filename:	 String giving the name of the file.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: Array of body-frame points.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2012
;	
;-
;===========================================================================
function stn_read_array, filename

 openr, unit, filename, /get_lun

 test = 0l
 readu, unit, test

 n = 0l
 readu, unit, n

 array = dblarr(n,3)
 readu, unit, array

 close, unit

 return, array
end
;===========================================================================



