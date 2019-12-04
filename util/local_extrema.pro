;===================================================================================
; local_extrema
;
;===================================================================================
function local_extrema, x, maximum=maximum, minimum=minimum, width=width

 f = 10
 if(NOT keyword_set(width)) then width = 10
 hwidth = width/2d
 fwidth = f*width

 nx = n_elements(x)

 hpx = x - smooth(x,width)
 if(keyword_set(minimum)) then hpx = -hpx

 hpx0 = hpx>0

 done = 0
 repeat $
  begin
   w = where(hpx0 EQ max(hpx0))
   ii = lindgen(width) + w[0] - hwidth
   ww = where((ii GE 0) AND (ii LT nx))
   ii = ii[ww]

   xx = peak_interp(ii-min(ii), hpx0[ii], ymax=yy) + ii[0]
   hpx0[ii] = 0

   extrema = append_array(extrema, xx)

   ww = where(hpx0 NE 0)
   if(ww[0] EQ -1) then done = 1 $
   else if (yy LT 4d*mean(hpx0[ww])) then done = 1
  endrep until(done)


 return, extrema
end
;===================================================================================
