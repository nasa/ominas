;=============================================================================
; timeplot
;
;
;=============================================================================
pro timeplot, x, y, _t, dt, $
      xrange=xrange, yrange=yrange, psym=psym, symsize=symsize, $
      title=title, xtitle=xtitle, ytitle=ytitle, $
      colors=colors, delay=delay, tau=tau, $
      time_rate=time_rate, time_offset=time_offset

 t = _t

 if(NOT keyword_set(xrange)) then xrange = [min(x), max(x)]
 if(NOT keyword_set(yrange)) then yrange = [min(y), max(y)]
 if(NOT keyword_set(delay)) then delay = 0
 if(NOT keyword_set(tau)) then tau = 1d100
 if(NOT keyword_set(time_rate)) then time_rate = 1
 if(NOT keyword_set(time_offset)) then time_offset = 0

 t0 = min(t)
 t1 = max(t) + tau
 nt = double(fix((t1-t0)/dt))

 wnum = !d.window
 window, /pixmap, xsize=!d.x_size, ysize=!d.y_size
 pixmap = !d.window

 for i=0, nt do $
  begin
   wset, pixmap
 plot, /nodata, [0], xrange=xrange, yrange=yrange, xst=1, yst=1, $
      title=title, xtitle=xtitle, ytitle=ytitle

   tmin = t0 + i*dt
   w = where(t LE tmin)

   if(w[0] NE -1) then $
    begin
     xx = x[w]
     yy = y[w]
     tt = t[w]

     fade = 0.75*exp(-(tmin-tt)/tau) + 0.25

     oplotc, xx, yy, psym=psym, colors=ctwhite(fade)

     xyouts, /norm, 0.1, 0.9725, 'time=' + strtrim(tmin/time_rate + time_offset,2)

     wset, wnum
     device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]
    end

   if(delay NE 0) then wait, delay
  end

end
;=============================================================================
