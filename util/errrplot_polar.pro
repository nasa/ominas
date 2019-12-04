;=============================================================================
; errrplot_polar
;
;
;=============================================================================
pro errrplot_polar, r, q, sigr=sigr, sigq=sigq, color=color

 p = [transpose(r*cos(q)), transpose(r*sin(q))]
 ru = p_unit(p)
 qu = p_rotate(ru, 1d, 0d)

 n = n_elements(r)

 pp = dblarr(2,2)
 for i=0, n-1 do $
  begin
   if(keyword_set(sigr)) then $
    begin
     pp[*,0] = p[*,i] + ru[*,i]*sigr[i]/2d
     pp[*,1] = p[*,i] - ru[*,i]*sigr[i]/2d
     plots, pp, psym=-3
    end

   if(keyword_set(sigq)) then $
    begin
     pp[*,0] = p[*,i] + qu[*,i]*sigq[i]/2d*r[i]
     pp[*,1] = p[*,i] - qu[*,i]*sigq[i]/2d*r[i]
     plots, pp, psym=-3
    end

  end


end
;=============================================================================
