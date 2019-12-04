;===================================================================================
; degmmss_to_deg
;
;  deg:mm:ss
;
;===================================================================================
function degmmss_to_deg, degmmss

 deg = double(str_nnsplit(degmmss, ':', rem=mmss))
 mm = double(str_nnsplit(mmss, ':', rem=ss))
 ss = double(ss)

 del = ss/3600d + mm/60d
 
 sign = 1d
 if(deg LT 0) then sign = -1d

 deg = deg + sign*del

 return, deg
end
;===================================================================================
