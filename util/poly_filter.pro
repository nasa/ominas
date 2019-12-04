;============================================================================
; poly_filter
;
;  Fit polynomial to data and subtract.
;
;============================================================================
function poly_filter, f, x, degree, poly=yfit

 coeff = poly_fit(x, f, degree, yfit=yfit)
 return, f-yfit
end
;============================================================================
