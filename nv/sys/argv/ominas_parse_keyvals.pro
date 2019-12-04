;=============================================================================
;+
; NAME:
;       ominas_parse_keyvals
;
; PURPOSE:
;       Returns a list of keywords and value strings from the OMINAS argument
;	list.
;
;	  
; CATEGORY:
;       BAT
;
;
; CALLING SEQUENCE:
;       keywords = ominas_parse_keyvals(values)
;
;
; ARGUMENTS:
;  INPUT:  NONE
;
;  OUTPUT: 
;	values:	Value string associted with eac returned keyword.
;
;
; KEYWORDS:
;  INPUT: 
;	delim:	 Delimiters(s) to use for keyword/value pairs instead of '==' 
;		 and '='.
;
;	toggle:	 Delimiters(s) to use for toggles instead of '-' and '--'.
;
;	rm:	 If set, keyword/value pairs are removed from te argument list 
;		 as they
;	
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Keywords form the keyword/value pairs.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Adapted from xidl_value by:     Spitale 6/2018
;
;-
;=============================================================================



;=============================================================================
; opk_parse
;
;=============================================================================
function opk_parse, argv, values, delim=delim

 values = ''
 keywords = ''
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
 if(NOT keyword_set(keywords)) then return, ''

 argv = rm_list_item(argv, jj)
 return, keywords
end
;=============================================================================



;=============================================================================
; opk_parse_toggles
;
;=============================================================================
pro opk_parse_toggles, argv, delim=delim, toggle=toggle

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
; ominas_parse_keyvals
;
;=============================================================================
function ominas_parse_keyvals, keywords, delim=delim, toggle=toggle, rm=rm
@ominas_argv_block.include

 if(NOT keyword_set(delim)) then delim = ['==', '=']
 if(NOT keyword_set(toggle)) then toggle = ['--', '-']
 if(n_elements(___argv) EQ 0) then return, ''
 argv = ___argv

 ;----------------------------------------------------------------
 ; get rid of -args toggle
 ;----------------------------------------------------------------
 w = where(argv NE '-args')
 if(w[0] NE -1) then argv = argv[w]

 ;----------------------------------------------------------------
 ; parse toggle characters
 ;----------------------------------------------------------------
 opk_parse_toggles, argv, delim=delim, toggle=toggle

 ;----------------------------------------------------------------
 ; parse keyword/value pairs
 ;----------------------------------------------------------------
 for i=0, n_elements(delim)-1 do $
  begin
   keys = opk_parse(argv, vals, delim=delim[i])
   if(keyword_set(keys)) then $
    begin
     keywords = append_array(keywords, keys)
     values = append_array(values, vals)
    end
  end
 if(NOT keyword_set(keywords)) then return, !null

 if(keyword_set(rm)) then ___argv = argv
 return, values
end
;===============================================================================

