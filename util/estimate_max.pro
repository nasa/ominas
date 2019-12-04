;==================================================================================
; estimate_max
;
;==================================================================================
function estimate_max, x, threshold=threshold, pad=pad, bytype=bytype

 if(NOT keyword_set(threshold)) then threshold = 0.01
 if(NOT keyword_set(pad)) then pad = 1.1

return, max(x)*pad
stop

 h = histogram(x)
 max = max(where(h GT threshold))

 if(keyword_set(pad)) then max = max*pad

 xx = x[0] & xx[0] = max
 while(abs(xx - max) GT 1) do $
  begin
   max = max - xx[0] - 1
   xx[0] = max
  end

 return, max
end
;==================================================================================