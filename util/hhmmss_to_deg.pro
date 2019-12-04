;===================================================================================
; hhmmss_to_deg
;
;  hh:mm:ss
;
;===================================================================================
function hhmmss_to_deg, hhmmss

 hh = double(str_nnsplit(hhmmss, ':', rem=mmss))
 mm = double(str_nnsplit(mmss, ':', rem=ss))
 ss = double(ss)

 deg = hh/24d * 360d + mm/60d + ss/3600d

 return, deg
end
;===================================================================================
