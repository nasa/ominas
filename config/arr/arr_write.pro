;===========================================================================
;+
; NAME:
;	arr_write
;
;
; PURPOSE:
;	Write an array file.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	arr_write, filename, array
;
;
; ARGUMENTS:
;  INPUT: 
;	filename:	 String giving the name of the file.
;
;	array:		 Array of surface points.
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
; RETURN: NONE
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
pro arr_write, filename, array

 openw, unit, filename, /get_lun

 writeu, unit, 1l

 n = n_elements(array)/3
 writeu, unit, long(n)
 writeu, unit, double(array)

 close, unit
 free_lun, unit

end
;===========================================================================



