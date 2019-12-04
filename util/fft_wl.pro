;============================================================================
; fft_wl
;
;  Computes fft and corresponding wavelengths in pixels.
;
;============================================================================
function fft_wl, y, inf=inf, $
		wl=ll, $	; wavelength in pixels
		fr=ff		; frequency in radians / sample



 fy = fft(y)
 n = n_elements(fy)

 ii = [lindgen(n/2)+n/2, lindgen(n/2)]
 n = n_elements(ii)
 fy = fy[ii]

 ff0 = (lindgen(n) - n/2) * 1d/n		; freq; cycle/sample
 ff = 2d*!dpi * ff0				; freq; radian/sample

 w = where(ff NE 0)
 ww = where(ff EQ 0)

 ll = dblarr(n)
 ll[w] = 2d*!dpi / ff[w]				; wl; samples/cycle

 if(NOT keyword_set(inf)) then inf = 1.1*max(ll)
 ll[ww] = inf	

 return, fy
end
;============================================================================
