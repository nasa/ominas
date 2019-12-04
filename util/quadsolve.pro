;===========================================================================
; qus_fn
;
;===========================================================================
function qus_fn, x
common qus_fn_block, aa, bb, cc, xx0, dir

 if(dir GT 0) then w = where(x LT xx0) $
 else w = where(x GT xx0)

 f = aa*x^2 + bb*x + cc

 if(w[0] NE -1) then f[w] = -f[w]

 return, f
end
;===========================================================================



;===========================================================================
; quadsolve
;
;  Solves ax^2 + bx + c
;
;===========================================================================
function quadsolve, a, b, c, valid=valid, noroots=noroots
common qus_fn_block, aa, bb, cc, xx0, dir

 n = n_elements(a)
 valid = make_array(n,val=1b)

 x0 = -0.5d*b/a				; extremum location
 f0 = a*x0^2 + b*x0 + c


 ;---------------------------------------------------
 ; determine which equations have no roots
 ;---------------------------------------------------
 w = where(a GT 0)
 if(w[0] NE -1) then $
  begin
   ww = where(f0[w] GT 0)
   if(ww[0] NE -1) then valid[w[ww]] = 0
  end

 w = where(a LT 0)
 if(w[0] NE -1) then $
  begin
   ww = where(f0[w] LT 0)
   if(ww[0] NE -1) then valid[w[ww]] = 0
  end


 ;---------------------------------------------------
 ; iterate to find roots for valid equations
 ;---------------------------------------------------
 result = dblarr(n,2)

 if(NOT keyword_set(noroots)) then $
  begin
   w = where(valid)
   if(w[0] EQ -1) then return, result
   nw = n_elements(w)
 
   aa = a[w]
   bb = b[w]
   cc = c[w]
   xx0 = x0[w]

   dir = 1
   result[w,0] = newton(xx0, 'qus_fn', /double)

   dir = -1
   result[w,1] = newton(xx0, 'qus_fn', /double)
  end

 
 return, result
end
;===========================================================================
