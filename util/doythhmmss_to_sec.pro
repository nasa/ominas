;=================================================================================
; doythhmmss_to_sec
;
;=================================================================================
function doythhmmss_to_sec, doythhmmss

 doy = strmid(doythhmmss, 0, 3)
 hh = strmid(doythhmmss, 4, 2)
 mm = strmid(doythhmmss, 7, 2)
 ss = strmid(doythhmmss, 10, 2)
 
 return, doy*86400d + hh*3600d + mm*60d + ss
end
;=================================================================================
