;==============================================================================
; dd_renorm
;
;  See Hida et al. 2000
;==============================================================================
function dd_renorm, x0, x1, x2

 dim = size(x0, /dim)
 ndim = n_elements(dim)
 n = n_elements(x0)
 
 t = dblarr([n,3])

 s = dd_two_sum(x1, x2, e=e) & t[*,2] = e
 t[*,0] = dd_two_sum(x0, s, e=e) & t[*,1] = e

 s = t[*,0]
 k = lindgen(n)

 result = dblarr(n,2)
 for i=1,2 do $
  begin
   s = dd_two_sum(s, t[*,i], e=e)  
   w = where(e NE 0)
   if(w[0] NE -1) then $
    begin
     result[k[w]] = s[w]
     s = e
     k[w] = k[w] + n
    end
  end


 return, reform(result, [dim,2], /over)
end
;==============================================================================
