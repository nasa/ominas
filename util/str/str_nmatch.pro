;=============================================================================
;+
; NAME:
;       str_nmatch
;
; PURPOSE:
;       Identifies elements of one string array that match those of another.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       sub = str_nmatch(strings, tests)
;
;
; ARGUMENTS:
;  INPUT:
;	strings:	Array of strings.
;
;	tests:		Strings to search for.
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
;       Array of subsripts into the strings array.  -1 if no matches found.
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 7/2016
;
;-
;=============================================================================
function str_nmatch, strings, tests

 ns = n_elements(strings)
 nt = n_elements(tests)
 nc = max(strlen([strings, tests]))

 ;-------------------------------------------
 ; trivial cases
 ;-------------------------------------------
 if(nt EQ 1) then return, where(strings EQ tests)
 if(ns EQ 1) then return, where(strings EQ tests) EQ -1 ? -1 : 0

 ;-------------------------------------------
 ; construct nt x ns x nc matrices
 ;-------------------------------------------
 bs = byte(strings)
 bt = byte(tests)
 
 Ms = reform(transpose(bs[linegen3z(nc,ns,nt)]), /over)
 Mt = reform(transpose(bt[linegen3z(nc,nt,ns)], [1,2,0]), /over)

 ;-------------------------------------------
 ; compare 
 ;-------------------------------------------
 comp = total(Ms - Mt, 3)
 w = where(comp EQ 0)

 if(w[0] EQ -1) then return, -1
 return, transpose((w_to_xy(comp, w))[1,*])
end
;=============================================================================
