;=================================================================================
; sinfit_fn
;
;=================================================================================
pro sinfit_fn, x, a, f, df
common sinfit_block, fix, a0

 nx = n_elements(x)

 f = a[0] + a[1]*sin(a[2] + a[3]*x)

; df = dblarr(nx, 4)
; if((where(fix EQ 0))[0] NE -1) then df[*,0] = 1
; if((where(fix EQ 1))[0] NE -1) then df[*,1] = sin(a[2] + a[3]*x)
; if((where(fix EQ 2))[0] NE -1) then df[*,2] = a[1]*cos(a[2] + a[3]*x)
; if((where(fix EQ 3))[0] NE -1) then df[*,2] = a[1]*cos(a[2] + a[3]*x) * x

 if(fix[0] NE -1) then a[fix] = a0[fix]

; if((where(fix EQ 0))[0] NE -1) then a[0] = a0[0]
; if((where(fix EQ 1))[0] NE -1) then a[1] = a0[1]
; if((where(fix EQ 2))[0] NE -1) then a[2] = a0[2]
; if((where(fix EQ 3))[0] NE -1) then a[3] = a0[3]

end
;=================================================================================



;=================================================================================
; sinfit
;
;  y = a[0] + a[1]*sin(a[2] + a[3]*x)
;
;=================================================================================
function sinfit, x, y, a0, dy=dy, chisq=chisq, sig=sig, fix=fix, yfit=yfit, rms=rms
common sinfit_block, _fix, _a0
 if(NOT keyword__set(fix)) then fix = -1
 _fix = fix
 _a0 = a0

 n = n_elements(x)

 if(NOT keyword_set(dy)) then dy = make_array(n, val=1d/n)


 a = a0
 yfit = curvefit(x, y, dy, a, sig, chisq=chisq, fun='sinfit_fn', /noder)
 if(a[1] LT 0) then a[2] = a[2] + !dpi
 a[1] = abs(a[1])


 res2 = (yfit-y)^2

 rms = sqrt(mean(res2))

 return, a
end
;=================================================================================
