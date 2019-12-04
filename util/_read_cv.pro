;=============================================================================
;+
; NAME:
;	read_csv
;
;
; PURPOSE:
;	Reads a CSV file.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = read_csv(filename)
;
;
; ARGUMENTS:
;  INPUT:
;	filename:	Name of file to read
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	delim:	String giving character to use to delimit columns.
;		Defaults to ','.
;
;  OUTPUT:
;	NONE
;
;
; RETURN:
;	Array (ncol, nrow) of strings.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================
function read_csv, filename, delim=_delim

 if(NOT keyword_set(_delim)) then delim = ',' $
 else delim = _delim

 tab = read_txt_table(filename, delim=delim)

 return, transpose(tab)
end
;=============================================================================
