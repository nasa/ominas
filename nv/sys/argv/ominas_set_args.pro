;=============================================================================
;+
; NAME:
;       ominas_set_args
;
; PURPOSE:
;       Adds arguments to the shell argument list so that they can be 
;	passed to batch files invoked from within IDL via '@'.
;
;	  
; CATEGORY:
;       NV/SYS/ARGV
;
;
; CALLING SEQUENCE:
;       ominas_set_args, keyvals
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	 keyvals: Keyword-value pairs to be added to the OMINAS argument list.
;
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; EXAMPLE:
;	To send arguments to a script that would otherwise be executed from 
;	the shell as:
;
;	% ominas script.pro key1==val1 --key2
;
;	from within IDL, use:
;
;	OMINAS> ominas_set_args, key1=val1, /key2
;	OMINAS> @script.pro
;
;	Note that OMINAS_SET_ARGS simply adds argument to the shell argument 
;	list, so any arguments provided at startup are also passed.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale 11/2018
;
;-
;=============================================================================
pro ominas_set_args, _extra=keyvals
common ominas_argv_block, ___argv
 if(NOT defined(___argv)) then ___argv = command_line_args()

 keys = tag_names(keyvals)
 n = n_elements(keys)

 for i=0, n-1 do $
    ___argv = append_array(___argv, keys[i] + '=' + strtrim(keyvals.(i),2))

end
;=============================================================================
