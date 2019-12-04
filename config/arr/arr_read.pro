;===========================================================================
;+
; NAME:
;	arr_read
;
;
; PURPOSE:
;	Reads an array file.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	array = arr_read(filename)
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
; RETURN: Array of surface points.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;===========================================================================
function arr_read, filename

 openr, unit, filename, /get_lun

 test = 0l
 readu, unit, test

 n = 0l
 readu, unit, n

 array = dblarr(n,3)
 readu, unit, array

 close, unit
 free_lun, unit

 return, array
end
;===========================================================================



