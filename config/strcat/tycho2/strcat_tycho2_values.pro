;===============================================================================
; strcat_tycho2_values
;
;===============================================================================
function strcat_tycho2_values, recs

 nstars = n_elements(recs)
 stars = replicate({strcat_star}, nstars)

 stars.cat = 'TYCHO-2'     
 stars.ra = recs.mRAdeg                     ; mean j2000 ra in deg
 stars.dec = recs.mDEdeg                    ; mean j2000 dec in deg
 stars.rapm = recs.pmRA / 3600000d          ; mas/yr -> deg/yr
 stars.decpm = recs.pmDE / 3600000d         ; mas/yr -> deg/yr
 stars.mag = recs.VT                        ; approximately equivalent to visual mag.
 stars.px = 0                               ; parallax is not known
 stars.num = strtrim(string(recs.tyc1), 2)+'-'+strtrim(string(recs.tyc2), 2)+'-'+strtrim(string(recs.tyc3), 2)
 stars.name = 'TYC ' + stars.num

 return, stars
end
;===============================================================================



