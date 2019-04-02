;=============================================================================
;+
; NAME:
;	write_txt_file
;
;
; PURPOSE:
;	Writes text to a file.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	write_txt_file, fname, text
;
;
; ARGUMENTS:
;  INPUT:
;	fname:	Name of file to read.
;
;	text:	Text to write to the file.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	append:	 If set, the text will be appended if the file already exists.
;
;	verbose: If set, a message is printed.
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
;	read_txt_file
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/1994
;	
;-
;=============================================================================
pro write_txt_file, fname, text, append=append, verbose=verbose

 openw, unit, fname, /get_lun, append=keyword__set(append)

 if(keyword_set(verbose)) then print, 'Writing ' + fname
 printf, unit, tr(text)

 close, unit
 free_lun, unit
end
;==========================================================================



