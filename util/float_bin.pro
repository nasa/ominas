;=============================================================================
; float_bin
;
;  Work around for idl 5.3 problem where "plot" can't handle abscissa points
;  spaced closer than floating point precision. This routine checks xarr
;  for that condition and rebins the arrays if necessary.
;
;=============================================================================
pro float_bin, xarr, yarr, bin=bin

 eps = 1d7

 bin = 0

 d = abs((xarr - shift(xarr,1))[1:*])
 f = max(abs(xarr))/min(d) / eps

 if(f LT 1) then return
 status = 0

 ff = fix(f) + 1
 n = n_elements(xarr)

 bin = n/ff

 xarr = congrid(xarr, 1, bin)
 yarr = congrid(yarr, 1, bin)

end
;=============================================================================
