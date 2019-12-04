;============================================================================
; rectify_angles
;
;
;============================================================================
function rectify_angles, _theta
 theta = _theta

 done = 0
 repeat $
  begin
   dtheta = deriv(theta)
   sig = stdev(dtheta)
   w = where(abs(dtheta) GT 10*sig)
   if(w[0] EQ -1) then done = 1 $
   else $
    begin
     ww = w[0]+1
     theta[ww:*] = theta[ww:*] - sign(dtheta[ww])*2d*!dpi
    end
 endrep until(done)

 return, theta
end
;============================================================================
