;===================================================================================
; men_get_decimal
;
;===================================================================================
function men_get_decimal, xs

 xp = strpos(xs, '.')

 if(xp EQ 1) then $
  begin
   if(strmid(xs, 0, 1) NE '0') then return, xp

   xss = strmid(xs, 2, strlen(xs)-2)
   xp = -strxpos(xss, '0') - 1
  end
 
 return, xp
end
;===================================================================================



;===================================================================================
; make_error_number
;
;===================================================================================
function make_error_number, x, _sig

 ;---------------------------------
 ; round sig properly
 ;---------------------------------
 sig = _sig
 sigs = strtrim(string(sig, form='(d20.10)'),2)
 sigp = double(men_get_decimal(sigs))
 if(sigp LT 0) then sig = round(sig*10^(-sigp)) * 10^(sigp) $
 else sig = round(sig*10^(-(sigp-1d)))*10^(sigp-1d)


 ;---------------------------------
 ; round the whole number
 ;---------------------------------
 xs = strtrim(string(x, form='(d20.10)'),2)
 sigs = strtrim(string(sig, form='(d20.10)'),2)

 xp = men_get_decimal(xs)
 sigp = men_get_decimal(sigs)


 nx = xp - sigp + 1
 if(nx LT xp) then xs = strtrim(round(x/10^(xp-nx))*10^(xp-nx),2) $
 else xs = strmid(xs, 0, nx)

 if(sigp LT 0) then sigs = strtrim(round(sig*10^(-sigp)),2) $
 else sigs = strtrim(fix(round(sig*10^(-(sigp-1d)))*10^(sigp-1d)),2)

 return, xs + '(' + sigs + ')'
end
;===================================================================================
