;===============================================================================
; strcat_sao_values
;
;===============================================================================
function strcat_sao_values, recs

 nstars = n_elements(recs)
 stars = replicate({strcat_star}, nstars)

 x = recs.ra & byteorder, x, /XDRTOF & recs.ra = x
 x = recs.dec & byteorder, x, /XDRTOF & recs.dec = x
 x = recs.rapm & byteorder, x, /XDRTOF & recs.rapm = x
 x = recs.decpm & byteorder, x, /XDRTOF & recs.decpm = x
 x = recs.mag & byteorder, x, /XDRTOF & recs.mag = x

 stars.cat = 'SAO'     
 stars.ra = recs.ra * 180d/!dpi    
 stars.dec = recs.dec * 180d/!dpi    
 stars.rapm = recs.rapm / 240d
 stars.decpm = recs.decpm / 3600d  
 stars.mag = recs.mag
; stars.sp = recs.sp    
 stars.num = ''
 stars.name = string(recs.name)

 return, stars
end
;===============================================================================



