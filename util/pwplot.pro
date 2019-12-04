;=============================================================================
; pwplot
;
;  Breaks array into contiguous segments and oplots separately
;
;=============================================================================
pro pwplot, _x, _y, psym=psym, symsize=symsize, color=color, wrap=wrap, thick=thick

 ss = sort(_x)
 x = _x[ss]
 y = _y[ss]

 iip = contiguous(x)

 n = n_elements(iip)
 for i=0, n-1 do oplot, x[*iip[i]], y[*iip[i]], $
               psym=psym, symsize=symsize, color=color, thick=thick


 nv_free, [iip]
end
;=============================================================================
