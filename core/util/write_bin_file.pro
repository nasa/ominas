;=============================================================================
;+
; NAME:
;	write_bin_file
;
;
; PURPOSE:
;	Writes data to a binary file.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	write_bin_file, fname, data
;
;
; ARGUMENTS:
;  INPUT:
;	fname:	Name of file to read.
;
;	data:	Data to write to the file.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	append:	If set, the data will be appended if the file already exists.
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
; SEE ALSO:
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/1994
;	
;-
;=============================================================================
pro write_bin_file, fname, data, append=append

 openw, unit, fname, /get_lun, append=keyword__set(append)

 writeu, unit, data

 close, unit
 free_lun, unit
end
;==========================================================================



