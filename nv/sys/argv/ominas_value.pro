;=============================================================================
;+
; NAME:
;       ominas_value
;
; PURPOSE:
;       Returns the value associated with a specified keyword in an
;	argument list.  Either "=" or "==" my be used to denote a 
;	keyword/value pair.  The first instance of that delim is
;	taken as the delimiter.  "-" and "--" are used instead 
;	of "/" to set a keyword to one.  Array values are delimited 
;	by commas.
;
;	  
; CATEGORY:
;       NV/SYS/ARGV
;
;
; CALLING SEQUENCE:
;       value = ominas_value(keyword)
;
;
; ARGUMENTS:
;  INPUT: 
;	keyword: String giving the name of the keyword for which a value 
;		 is desired.  If not given, all keywords are identified and
;		 returned in the 'keywords' output, and all values are returned
;		 as raw strings (i.e., no array parsing or type conversion 
;		 performed).
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	set:	If set, the returned value is 0 unless the keyword exists and is
;		not '0'.
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
;	null:	Null return value to use instead of !null 
;
;	delim:	 Delimiters(s) to use instead of '==' and '='.
;
;	toggle:	 Toggle character(s) to use instead of '--' and '-'.
;
;	keywords:
;		 Names of all keywords, if no keyword input given.
;
;
;  OUTPUT: 
;	argv0:	 Argument list with keyword/value pairs removed.
;
;
; RETURN:
;	Value(s) associated with the specified keyword, or !null.
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



;=============================================================================
; ov_parse
;
;=============================================================================
function ov_parse, argv, values, delim=delim

 values = !null
 for i=0, n_elements(argv)-1 do $
  begin
   keyval = str_split(argv[i], delim)
   if(n_elements(keyval) EQ 2) then $
    begin
     jj = append_array(jj, i, /def)
     keywords = append_array(keywords, keyval[0], /def)
     values = append_array(values, keyval[1], /def)
    end
  end
;; if(NOT keyword_set(values)) then return, ''
 if(NOT defined(jj)) then return, ''

 argv = rm_list_item(argv, jj, only='')
 return, keywords
end
;=============================================================================



;=============================================================================
; ov_parse_toggles
;
;=============================================================================
pro ov_parse_toggles, argv, delim=delim, toggle=toggle

 for i=0, n_elements(toggle)-1 do $
  begin
   len = strlen(toggle[i])
   first = strmid(argv, 0, len)
   arg = strmid(argv,len,1024)
   w = where(first EQ toggle[i])
   if(w[0] NE -1) then argv[w] = arg[w] + delim[0] + '1'
  end

end
;=============================================================================



;=============================================================================
; ov_parse_keyvals
;
;=============================================================================
function ov_parse_keyvals, keywords, delim=delim, toggle=toggle, argv0=argv0, rm=rm
common ominas_argv_block, ___argv

 if(NOT keyword_set(delim)) then delim = ['==', '=']
 if(NOT keyword_set(toggle)) then toggle = ['--', '-']

 ;----------------------------------------------------------------
 ; get argument list
 ;----------------------------------------------------------------
 if(NOT defined(___argv)) then ___argv = command_line_args()
 if(NOT defined(___argv)) then return, ''
 w = where(___argv NE '-args')
 if(w[0] NE -1) then ___argv = ___argv[w]
;;; argv = strlowcase(___argv)
argv = ___argv

 argv0 = ''

 ;----------------------------------------------------------------
 ; parse toggle characters
 ;----------------------------------------------------------------
 ov_parse_toggles, argv, delim=delim, toggle=toggle

 ;----------------------------------------------------------------
 ; parse keyword/value pairs
 ;----------------------------------------------------------------
 for i=0, n_elements(delim)-1 do $
  begin
   keys = ov_parse(argv, vals, delim=delim[i])
   if(keyword_set(keys) OR keyword_set(vals)) then $
    begin
     keywords = append_array(keywords, keys, /def)
     values = append_array(values, vals, /def)
    end
  end
 argv0 = argv
 if(NOT defined(values)) then return, !null

 if(keyword_set(rm)) then ___argv = argv
 return, values
end
;===============================================================================



;=============================================================================
; ominas_parse_array
;
;=============================================================================
function ominas_parse_array, arg
 return, str_nsplit(arg, ',')
end
;=============================================================================



;=============================================================================
; ominas_value
;
;=============================================================================
function ominas_value, keyword, delim=delim, toggle=toggle, keywords=keywords, $
          set=set, byte=byte, int=int, long=long, float=float, double=double, $
          null=null, argv0=argv0, rm=rm
 
 if(keyword_set(set)) then null = 0
;;; if(keyword_set(keyword)) then keyword = strlowcase(keyword)

 ;----------------------------------------------------------------
 ; get all keyword/value pairs
 ;----------------------------------------------------------------
 values = ov_parse_keyvals(delim=delim, toggle=toggle, keywords, argv0=argv0, rm=rm)
 if(NOT keyword_set(keyword)) then return, values
 if(NOT keyword_set(keywords)) then return, nv_null(null=null)

 ;----------------------------------------------------------------
 ; match specified keyword
 ;----------------------------------------------------------------
 w = where(keywords EQ keyword)
 if(w[0] EQ -1) then return, nv_null(null=null)
 value = values[w]

 ;----------------------------------------------------------------
 ; parse array
 ;----------------------------------------------------------------
 val = ominas_parse_array(value)

 ;----------------------------------------------------------------
 ; distinguish set vs. unset
 ;----------------------------------------------------------------
 if(keyword_set(set)) then $
  begin
   if(n_elements(val) GT 1) then return, 1
   if(val[0] EQ '0') then return, 0
   return, 1
  end

 ;----------------------------------------------------------------
 ; convert type
 ;----------------------------------------------------------------
 val = decrapify(val)
 if(keyword_set(byte)) then return, byte(val)
 if(keyword_set(int)) then return, fix(val)
 if(keyword_set(long)) then return, long(val)
 if(keyword_set(float)) then return, float(val)
 if(keyword_set(double)) then return, double(val)

 return, val
end
;===============================================================================

