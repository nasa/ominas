;=============================================================================
;+
; NAME:
;       bat_value
;
; PURPOSE:
;       Returns the value associated with a specified keyword in an
;	argument list, and removes that keyword/value pair from
;	the argument list.  "-" is used instead of "/" to set
;	a keyword to one.
;
;	  
; CATEGORY:
;       BAT
;
;
; CALLING SEQUENCE:
;       value = bat_value(argv, keyword)
;
;
; ARGUMENTS:
;  INPUT: 
;	argv:	xidl argument list.
;
;	keyword:  
;		String array giving the name of the keyword for which a value 
;		is desired.  Keyword names may be abreviated as in IDL.
;
;
; RETURN:
;	Value associated with the specified keyword, or ''.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Adapted from xidl_value by:     Spitale 6/2017
;
;-
;=============================================================================
function bat_value, argv, keyword

 if(NOT keyword_set(argv[0])) then return, ''

 keywords = str_nnsplit(argv, '=', rem=values)
 w = where(keywords EQ keyword)

 if(w[0] EQ -1) then return, ''

 argv = rm_list_item(argv, w)
 return, values[w]
end
;===============================================================================
