;===========================================================================
;+
; NAME:
;	stn_write_array
;
;
; PURPOSE:
;	Write a station array file.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	stn_write_array, filename, array
;
;
; ARGUMENTS:
;  INPUT: 
;	filename:	 String giving the name of the file.
;
;	array:	 Array of points in the body frame.
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
; 	Written by:	Spitale, 3/2012
;	
;-
;===========================================================================
pro stn_write_array, filename, array

 openw, unit, filename, /get_lun

 writeu, unit, 1l

 n = n_elements(array)/3
 writeu, unit, long(n)
 writeu, unit, double(array)

 close, unit

end
;===========================================================================



