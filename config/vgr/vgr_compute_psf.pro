;==============================================================================
; vgr_psf
;
;
;==============================================================================
function vgr_psf, cd, x, y, default=default

 if(NOT keyword_set(y)) then $
  if(keyword_set(x)) then y = dblarr(n_elements(x))

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
