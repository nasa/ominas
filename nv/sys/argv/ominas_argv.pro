;=============================================================================
;+
; NAME:
;       ominas_argv
;
; PURPOSE:
;       Returns the shell argument list.  Arguments are expanded according 
;       to standard shell rules.  Arrays are specified as comma-delineated 
;       lists with no white space.  
;
;
; CATEGORY:
;       NV/SYS/ARGV
;
;
; CALLING SEQUENCE:
;       arg = ominas_argv(i)
;
;
; ARGUMENTS:
;  INPUT: 
;	i:	Index of positional argument to return.  If there are no 
;		positional arguments, or if i is invalid, then !null is returned.  
;		If i is not specified, then all arguments are returned and 
;		all values are returned as raw strings (i.e., no array parsing 
;		or type conversion performed).
;
;  OUTPUT: NONE
;
;
; KEYWORDS: 
;  INPUT: 
;	delim:	 Delimiters(s) to use for identifying keyword/value pairs 
;		 instead of '==' and '='.
;
;	toggle:	 Toggle character(s) to use for identifying toggles instead 
;		 of '--' and '-'.
;
;	null:	Null return value to use instea of !null 
;
;	byte:	If set, result is converted to byte.
;
;	int:	If set, result is converted to int.
;
;	long:	If set, result is converted to long.
;
;	float:	If set, result is converted to float.
;
;	double:	If set, result is converted to double.
;
;
;  OUTPUT: NONE
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
function ominas_argv, i, delim=delim, toggle=toggle, null=null, $
                  byte=byte, int=int, long=long, float=float, double=double

 if(NOT defined(null)) then null = !null
 if(keyword_set(set)) then null = 0

 ;----------------------------------------------------------------
 ; strip out keyword/value pairs
 ;----------------------------------------------------------------
 values = ominas_value(delim=delim, toggle=toggle, keywords, argv0=argv)

 ;----------------------------------------------------------------
 ; return desired arguments
 ;----------------------------------------------------------------
 if(NOT keyword_set(argv)) then return, nv_null(null=null)
 if(NOT defined(i)) then return, argv
 if(i GE n_elements(argv)) then return, nv_null(null=null)

 ;----------------------------------------------------------------
 ; parse array
 ;----------------------------------------------------------------
 val = ominas_parse_array(argv[i])

 ;----------------------------------------------------------------
 ; convert type
 ;----------------------------------------------------------------
 val = decrapify(val)
 if(keyword_set(byte)) then return, fix(byte)
 if(keyword_set(int)) then return, fix(val)
 if(keyword_set(long)) then return, long(val)
 if(keyword_set(float)) then return, float(val)
 if(keyword_set(double)) then return, double(val)

 return, val
end
;=========================================================================

