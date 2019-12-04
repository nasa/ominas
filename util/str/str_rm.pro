;=============================================================================
;+
; NAME:
;       str_rm
;
; PURPOSE:
;       Removes every occurrence of the given substring from the given strings.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       return = str_rm(string, substring)
;
;
; ARGUMENTS:
;  INPUT:
;        string:        Array of input strings.
;
;        substring:     Substring to remove.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;       NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;       The input strings without the given substring.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 11/2018
;
;-
;=============================================================================
function str_rm, strings, substring

 if(NOT keyword_set(substring)) then return, strings

 s = strings
 len = strlen(substring)

 while(1) do $ 
  begin
   p = strpos(s, substring)
   w = where(p NE -1)
   if(w[0] EQ -1) then break
   s[w] = strmid_11(s[w], 0, p) + strmid_11(s[w], p+len, 128)
  end

 return, s
end
;=============================================================================
