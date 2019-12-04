;================================================================================
; parm_scan
;
;================================================================================
function parm_scan, a, t, y, scale=scale, xrange=xrange

 if(NOT keyword_set(scale)) then scale = 1d

 done = 0
 b = 0d


 while(NOT done) do $
  begin
   x = a + b*t
   if(keyword_set(xrange)) then x = reduce_angle(x, min=xrange[0], max=xrange[1])
   plot, x, y, psym=1, xrange=xrange, xstyle=1
   xyouts, /normal, 0.01, 0.01, 'b = ' + strtrim(b,2)

   kb = get_kbrd(1)
   case kb of
    'x' : done = 1
    '3' : b=b-0.001d*scale
    '9' : b=b+0.001d*scale
    '2' : b=b-0.01d*scale
    '8' : b=b+0.01d*scale
    '1' : b=b-0.1d*scale
    '7' : b=b+0.1d*scale
    else:
   endcase
  end

 return, b
end
;================================================================================
