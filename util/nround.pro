;=================================================================================
; nround
;
;  Rounds to n places past the decimal point, or n figures if /fig.
;
;=================================================================================
function nround, x, _n, fig=fig, string=string

 n = double(_n)

 s = strtrim(string(x, format='(d20.10)'), 2)
 p = strpos(s, '.')
 if(keyword_set(fig)) then n = n - p


 shift = 10^n
 rx = round(x*shift)/shift

 if(keyword_set(string)) then $
  begin
   s = strtrim(string(rx, format='(d20.10)'), 2)
   p = strpos(s, '.')

   nn = n
   if(n LE 0) then nn = -1

   rx = strmid(s, 0, p+nn+1)
  end

 return, rx
end
;=================================================================================
