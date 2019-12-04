;===============================================================================
; strcat_vizier_values_ucac5
;
;===============================================================================
function strcat_vizier_values_ucac5, recs

 nstars = n_elements(recs)
 stars = replicate({strcat_star}, nstars)

 stars.ra = recs.raj2000                    ; mean j2000 ra in deg
 stars.dec = recs.dej2000                   ; mean j2000 dec in deg
 stars.rapm = recs.pmra / 3600000d          ; mas/yr -> deg/yr
 stars.decpm = recs.pmde / 3600000d         ; mas/yr -> deg/yr
 stars.mag = recs.f_mag                      ; approximately equivalent to visual mag.
 stars.px = 0                               ; parallax is not known
 stars.num = strtrim(string(recs.srcidgaia), 2)

 return, stars
end
;===============================================================================



;===============================================================================
; strcat_vizier_constraint_ucac5
;
;===============================================================================
function strcat_vizier_constraint_ucac5, $
    faint=faint, bright=bright, names=names

 constraints=''
 
 if(defined(faint)) then $
        constraints = append_array(constraint, 'Rmag>' + strtrim(faint,2))

 if(defined(bright)) then $
        constraints = append_array(constraint, 'Rmag<' + strtrim(faint,2))


 return, str_comma_list(constraints)
end
;===============================================================================
