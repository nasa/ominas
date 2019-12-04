;===============================================================================
; strcat_ucac4_values
;
; see http://ad.usno.navy.mil/ucac/readme_u4v5...
;
;===============================================================================
function strcat_ucac4_values, recs


 mas_deg = 3600000d

 nstars = n_elements(recs)
 stars = replicate({strcat_star}, nstars)
 stars.ra = recs.ra / mas_deg                           ; mas -> deg 
 stars.dec = (recs.spd / mas_deg) - 90d                 ; mas above south pole -> deg declination
 cosdec = cos(stars.dec * (!dpi / 180d)) * (180d / !dpi) 
 stars.rapm = recs.pmrac / (cosdec * mas_deg) /10. ; pmRA * cos(dec) [0.1 mas/yr] -> pmRA [deg/yr]
 stars.decpm = recs.pmdc / mas_deg /10.
 stars.mag = recs.apasm[1]/1000.

;;;		 stars.px = stars_px	;; look up in hipsupl.dat
;;;		 stars.sp = recs.objt	;; not in record
 stars.num = recs.pts_key		;;; zzznnnnnn for star names
 stars.name = 'UCAC4 '+strtrim(string(stars.num/1000000,format='(I03)'),2)+'-'+strtrim(string(stars.num MOD 1000000,format='(I06)'),2)
;;; stars.epochra = recs.cepra
;;; stars.epochdec = recs.cepdc


 return, stars
end
;===============================================================================



