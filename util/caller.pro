;===============================================================================
; caller
;
;
;===============================================================================
function caller, n, all=all

 if(NOT keyword_set(n)) then n = 0

 help, /tr, out=s

 w = where(strmid(s, 0, 1) EQ '%')
 s = strcompress(s[w])
 junk = str_nnsplit(s, ' ', rem=rem)
 callers = str_nnsplit(rem, ' ')
 if(keyword_set(all)) then return, str_cull(callers)

 return, callers[n+2]
end
;===============================================================================
