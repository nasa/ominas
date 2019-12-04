;=============================================================================
; errfill
;
;
;=============================================================================
pro errfill, x, y, sig, color=color


 xx = reform(x)
 yy = reform(y)
 xx = [xx, rotate(xx,2)]
 yy = [yy+sig, rotate(yy-sig,2)]

 polyfill, xx, yy, color=color

 oplot, xx, yy, color=color

end
;=============================================================================
