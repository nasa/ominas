;===============================================================================
; strcat_ucac5_constraint
;
;===============================================================================
function strcat_ucac5_constraint, $
    faint=faint, bright=bright, names=names

 constraints=''
 
 if(defined(faint)) then $
        constraints = append_array(constraint, 'Rmag>' + strtrim(faint,2))

 if(defined(bright)) then $
        constraints = append_array(constraint, 'Rmag<' + strtrim(faint,2))


 return, str_comma_list(constraints)
end
;===============================================================================



;===============================================================================
; strcat_ucac5_values
;
;===============================================================================
function strcat_ucac5_values, recs

 nstars = n_elements(recs)
 stars = replicate({strcat_star}, nstars)

 stars.cat = 'UCAC5'     
 stars.ra = recs.raj2000                    ; mean j2000 ra in deg
 stars.dec = recs.dej2000                   ; mean j2000 dec in deg
 stars.rapm = recs.pmra / 3600000d          ; mas/yr -> deg/yr
 stars.decpm = recs.pmde / 3600000d         ; mas/yr -> deg/yr
 stars.mag = recs.f_mag                      ; approximately equivalent to visual mag.
 stars.px = 0                               ; parallax is not known
 stars.num = strtrim(string(recs.srcidgaia), 2)
 stars.name = strupcase(stars.cat) + ' ' + stars.num

 return, stars
end
;===============================================================================



