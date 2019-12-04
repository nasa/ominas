;=============================================================================
;+
; NAME:
;       bat_argv
;
; PURPOSE:
;       Returns a shell argument list. Arguments are expanded
;	according to standard shell rules.  "-" is used instead of "/" to set
;	a keyword to one.  Arrays are specified as comma-dilineated lists
;	with no white space.
;
;
; CATEGORY:
;       BAT
;
;
; CALLING SEQUENCE:
;       arg = bat_argv(i)
;
;
; ARGUMENTS:
;  INPUT: 
;	i:	Index of the argument to return.  If there are no arguments,
;		or if i is invalid, then '' is returned.  If i is not 
;		specified, then all arguments are returned.  
;
;  OUTPUT: NONE
;
;
; KEYWORDS: NONE
;
;
; RETURN:
;       The requested argument.  Note all arguments are returned as strings.
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Adapted from xidl_argv by:     Spitale 6/2017
;
;-
;=============================================================================
function bat_argv, i

 argv = command_line_args()

 if(n_elements(argv) EQ 0) then return, ''

 first = strmid(argv, 0, 1)
 w = where(first EQ '-')
 if(w[0] NE -1) then argv[w] = strmid(argv[w],1,1024) + '=1'

 if(n_elements(i) EQ 0) then return, argv
 if(i GE n_elements(argv)) then return, ''

 return, argv[i]
end
;=========================================================================



