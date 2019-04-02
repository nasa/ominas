;=============================================================================
;+
; NAME:
;       bat_parse_argv
;
; PURPOSE:
;       Parses a given idl argument list.
;
;	  
; CATEGORY:
;       BAT
;
;
; CALLING SEQUENCE:
;       argv = bat_parse_argv(argv, keys, val_ps)
;
;
; ARGUMENTS:
;  INPUT: 
;	argv:	idl argument list.
;
;  OUTPUT: 
;	keys:	String array giving the names of keywords from any
;		keyword=value pairs.  Also, any argument containing a single
;		'-' as its first character is considered to be a keyword
;		whose value is set to '1'.
;
;	val_ps:	Array of pointers, one for each keyword, giving the values
;		from each keyword=value pair.  Array values are delimited
;		by commas.
;
;
; KEYWORDS: 
;  INPUT: NONE
;
;  OUTPUT: 
;	list:		Returns the names of any arguments starting or ending 
;			with '@'.  Those arguments are removed from the argument 
;			list.  Those names will be used as file lists.
;
;	path:		Returns an optional path for the file list.
;
;	sample:		Returns the bat_sample value (see below).
;
;	select:		Returns the bat_select value (see below).
;
;
; GLOBAL SHELL KEYWORDS: 
;	bat_path:	Sets file list path.
;
;	bat_sample:	Sets file list sampling; see read_txt_file.
;
;	bat_select:	Sets file selection criterion; see read_txt_file.
;
;
; RETURN:
;	The trimmed argument list, with all keywords=value pairs and 
;	special argument removed.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Adapted from xidl_parse_argv by:     Spitale 6/2017
;
;-
;=============================================================================
function bat_parse_argv, keys, val_ps, $
           list=list, path=path, sample=sample, select=select

 ;----------------------------------------------------------------
 ; get global keyword/value pairs
 ;----------------------------------------------------------------
 path = decrapify(ominas_value('bat_path', null=''))
 sample = decrapify(ominas_value('bat_sample', null=''))
 select = decrapify(ominas_value('bat_select', null=''))

 ;--------------------------------------------
 ; get keywords / values
 ;--------------------------------------------
 values = ominas_value(keywords=keywords)
 if(keyword_set(keywords)) then $
  for i=0, n_elements(keywords)-1 do $
   begin
    keys = append_array(keys, keywords[i])
    val_ps = append_array(val_ps, ptr_new(ominas_value(keywords[i])))
   end

 ;---------------------------------------------------------
 ; Special args start or end with '@' and are removed from
 ; argv and returned via the list output
 ;---------------------------------------------------------
 list = ominas_value(key=alt, delim='@', /rm)
 if(keyword_set(alt)) then list = alt

 ;--------------------------------------
 ; return positional args
 ;--------------------------------------
  return, ominas_argv()
end
;===============================================================================





