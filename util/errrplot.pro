;=============================================================================
; erp_wrap
;
;
;=============================================================================
pro erp_wrap, wrap, z, sigz, zz, sigzz

 if(NOT keyword_set(wrap)) then return

 min = z-sigz
 max = z+sigz
 span = wrap[1] - wrap[0]

 w = where(min LT wrap[0])
 if(w[0] NE -1) then $
  begin
   min[w] = min[w] + span
   z = [z, 0.5*(min[w]+wrap[1])]
   sigz = [sigz, 0.5*(wrap[1]-min[w])]
   zz = append_array(zz, zz[w])
   if(keyword_set(sigzz)) then sigzz = append_array(sigzz, [0])
  end

 w = where(max GT wrap[1])
 if(w[0] NE -1) then $
  begin
   max[w] = max[w] - span
   z = [z, 0.5*(wrap[0]+max[w])]
   sigz = [sigz, 0,5*(max[w]-wrap[0])]
   zz = append_array(zz, zz[w])
   if(keyword_set(sigzz)) then sigzz = append_array(sigzz, [0])
  end

end
;=============================================================================




;=============================================================================
; errrplot
;
;
;=============================================================================
pro errrplot, _x, _y, sigx=_sigx, sigy=_sigy, color=color, xwrap=xwrap, ywrap=ywrap

 x = _x & y = _y
 if(keyword_set(_sigx)) then sigx = _sigx
 if(keyword_set(_sigy)) then sigy = _sigy

 erp_wrap, xwrap, x, sigx, y, sigy
 erp_wrap, ywrap, y, sigy, x, sigx


 for i=0,  n_elements(x)-1 do $
  begin
   if(keyword_set(sigx)) then $
     oplot, [x[i]-sigx[i], x[i]+sigx[i]], [y[i], y[i]], color=color

   if(keyword_set(sigy)) then $
     oplot, [x[i], x[i]], [y[i]-sigy[i], y[i]+sigy[i]], color=color
  end


end
;=============================================================================


