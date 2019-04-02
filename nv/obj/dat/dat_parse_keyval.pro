;=============================================================================
;+
; NAME:
;	dat_parse_keyval
;
;
; PURPOSE:
;	Parses a string containing a keyword=value pair.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_parse_keyval, keyval, keyword, value
;
;
; ARGUMENTS:
;  INPUT:
;	keyval:		String of the form <keyword>=<value>.
;
;  OUTPUT:
;	keyword:	String giving the keyword.
;
;	value:		String giving the value.
;
;
; KEYWORDS:
;  INPUT: NONE
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
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
pro dat_parse_keyval, _keyval, keyword, value
@core.include

 keyval = str_compress(_keyval, /remove_all)

 s = str_split(keyval, '=')

 keyword = s[0]

 if(n_elements(s) EQ 2) then value = s[1] $
 else if(strmid(keyword, 0, 1) EQ '/') then $
  begin
   keyword = strmid(keyword, 1, strlen(keyword)-1)
   value = '1'
  end $
 else nv_message, 'Keyword/value parse error: ' + keyval
 

end
;=============================================================================
