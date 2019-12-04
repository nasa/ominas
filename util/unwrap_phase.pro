;=============================================================================
; unwrap_phase
;
;
;=============================================================================
function unwrap_phase, phi0, nsig=nsig

 if(NOT keyword_set(nsig)) then nsig = 3d

 n = n_elements(phi0)

 dphi = shift(phi0, -1) - phi0

 sig_dphi = stddev(dphi)
 mean_dphi = mean(dphi)

 phi = phi0

 w = where(dphi LT -nsig)
 ww = where(dphi GT nsig)

 nw = n_elements(w)
 nww = n_elements(ww)


 if(nw GT nww) then $
  begin
   for i=0, nw-1 do if(w[i] LT n-1) then $
                            phi[w[i]+1:*] = phi[w[i]+1:*] + 2d*!dpi
  end $
 else $
  begin
   if(ww[0] NE -1) then $
     for i=0, nww-1 do if(ww[i] LT n-1) then $
                            phi[ww[i]+1:*] = phi[ww[i]+1:*] - 2d*!dpi
  end

 return, phi
end
;=============================================================================




;=============================================================================
; unwrap_phase
;
;
;=============================================================================
function _unwrap_phase, phi0, nsig=nsig

 if(NOT keyword_set(nsig)) then nsig = 3d

 n = n_elements(phi0)

 dphi = shift(phi0, -1) - phi0

 sig_dphi = stddev(dphi)
 mean_dphi = mean(dphi)

 phi = phi0

 w = where(dphi LT -nsig)

 if(w[0] NE -1) then $
  begin
   nw = n_elements(w)
   for i=0, nw-1 do if(w[i] LT n-1) then $
                            phi[w[i]+1:*] = phi[w[i]+1:*] + 2d*!dpi
  end $
 else $
  begin
   w = where(dphi GT nsig)
   nw = n_elements(w)
   if(w[0] NE -1) then $
     for i=0, nw-1 do if(w[i] LT n-1) then $
                            phi[w[i]+1:*] = phi[w[i]+1:*] - 2d*!dpi
  end

 return, phi
end
;=============================================================================
