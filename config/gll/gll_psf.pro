;==============================================================================
; gll_psf
;
;  This is made up...
;
;==============================================================================
function gll_psf, cd, x, y

 if((NOT keyword_set(x)) AND (NOT keyword_set(y))) then default = 1 $
 else if(NOT keyword_set(y)) then y = dblarr(n_elements(x))

 if(keyword_set(default)) then $
  begin
   dxy = 4
   nn = 2*dxy + 1
   xx = lindgen(nn) - dxy 
   x = xx # make_array(nn, val=1d)
   y = tr(x)
  end

 fwhm = 1.0 	; This value is a space holder.

 sig = fwhm / 2.354d

 return, gauss2d(x, y, sig)
end
;==============================================================================
