;=============================================================================
; pwrf_powerlaw
;
;=============================================================================
function pwrf_powerlaw, x, coeff
  return, coeff[0] + coeff[1]*x^coeff[2]
end
;=============================================================================



;=============================================================================
; pwrf_eval
;
;=============================================================================
pro pwrf_eval, x, coeff, result, pder


 result = pwrf_powerlaw(x, coeff)

end
;=============================================================================



;=============================================================================
; pwrfit
;
;  y = a0 + a1 x^a2
;
;=============================================================================
function pwrfit, x, y, coeff, chisq=chisq, itmax=itmax

 if(NOT keyword_set(coeff)) then $
  begin
   sign = 1d

   ymax = max(y, ymax_x)
   ymin = min(y, ymin_x)
   xmax = max(x)

   sign = 1d
   if(ymin_x GT ymax_x) then sign = -1d 
   coeff = [ymin, ymax-ymin, sign*1d/xmax]
;   coeff = [ymin, ymax-ymin, sign*1d]
  end


 w = x & w[*] = 1d

 result = curvefit(x, y, w, coeff, chisq=chisq, funct='pwrf_eval', itmax=itmax, /noder)

 return, result
end
;=============================================================================
