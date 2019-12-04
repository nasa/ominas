;=============================================================================
; getenvs
;
;=============================================================================
function getenvs, name, delim=delim

 if(NOT keyword_set(delim)) then delim = ':'

 val = getenv(name)
 vals = str_nsplit(val, delim)
 w = where(vals NE '')
 if(w[0] EQ -1) then return, ''

 return, vals[w]
end
;=============================================================================
