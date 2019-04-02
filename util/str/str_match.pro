;=============================================================================
;+
; NAME:
;       str_match
;
; PURPOSE:
;       Determines whether a pattern appears in a string.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       sub = str_match(string, pattern)
;
;
; ARGUMENTS:
;  INPUT:
;	string:		Strings to test.
;
;	pattern:	Pattern to search for.
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;       NONE
;
;
; RETURN:
;       1 if the pattern is found, 0 otherwise.
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 6/2018
;
;-
;=============================================================================
function str_match, string, pattern
 return, strpos(string, pattern) NE -1
end
;=============================================================================
