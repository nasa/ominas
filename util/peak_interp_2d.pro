;===============================================================================
; peak_interp_2d
;
;===============================================================================
function peak_interp_2d, corr

 dim = size(corr, /dim)

 w = where(corr EQ max(corr))
 p = w_to_xy(corr, w)

 x = peak_interp(lindgen(dim[0]), corr[*,p[1]])
 y = peak_interp(lindgen(dim[1]), corr[p[0],*])

 return, [x,y] + 0.5




 model = gauss2dfit(corr, coeff, /tilt)
 xy = coeff[4:5]
 return, xy
end
;===============================================================================
