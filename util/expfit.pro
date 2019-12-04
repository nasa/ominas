;=============================================================================
; expf_exponential
;
;=============================================================================
function expf_exponential, x, coeff
  return, coeff[0] + coeff[1]*exp(coeff[2]*x)
end
;=============================================================================



;=============================================================================
; expf_eval
;
;=============================================================================
pro expf_eval, x, coeff, result, pder


 result = expf_exponential(x, coeff)

end
;=============================================================================



;=============================================================================
; expfit
;
;  y = a0 + a1 exp (a2 x)
;
;=============================================================================
function expfit, x, y, coeff, chisq=chisq, itmax=itmax

 if(NOT keyword_set(coeff)) then $
  begin
   sign = 1d

   ymax = max(y, ymax_x)
   ymin = min(y, ymin_x)
   xmax = max(x)

   sign = 1d
   if(ymin_x GT ymax_x) then sign = -1d 
   coeff = [ymin, ymax-ymin, sign*1d/xmax]
  end


 w = x & w[*] = 1d

 result = curvefit(x, y, w, coeff, chisq=chisq, funct='expf_eval', itmax=itmax, /noder)

 return, result
end
;=============================================================================
