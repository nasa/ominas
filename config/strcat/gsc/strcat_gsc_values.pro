;===============================================================================
; strcat_gsc_values
;
;===============================================================================
function strcat_gsc_values, recs

 nstars = n_elements(recs)
 stars = replicate({strcat_star}, nstars)

 stars.cat = 'GSC'     
 stars.ra = recs.ra_deg                     ; mean j2000 ra in deg
 stars.dec = recs.dec_deg                    ; mean j2000 dec in deg
 stars.rapm = 0				; no proper motion info for GSC
 stars.decpm = 0			; no proper motion info for GSC
 stars.mag = recs.mag                        ; approximately equivalent to visual mag.
 stars.px = 0                               ; parallax is not known
 stars.num = strtrim(recs.gsc_id, 2)
 stars.name = 'GSC ' + stars.num

 return, stars
end
;===============================================================================



