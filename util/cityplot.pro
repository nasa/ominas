;==================================================================================
; cityplot
;
;==================================================================================
pro cityplot, x, y, xrange=xrange, yrange=yrange, ynozero=ynozero, xstyle=xstyle, ystyle=ystyle

 f = 50

 n = n_elements(x)

 if(NOT keyword_set(y))then $
  begin
   y = x
   x = lindgen(n)
  end

 nn = n*f
 m = make_array(f,val=1d)

 xx = lindgen(nn)
 yy = reform(transpose(y#m), nn)

 plot, xx, yy, xrange=xrange, yrange=yrange, ynozero=ynozero, xstyle=xstyle, ystyle=ystyle



end
;==================================================================================
