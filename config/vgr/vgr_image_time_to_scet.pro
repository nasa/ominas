;=============================================================================
; vgr_image_time_to_scet
;
;
;=============================================================================
function vgr_image_time_to_scet, image_time

 yyyy = strmid(image_time, 0, 4)
 mm = strmid(image_time, 5, 2)
 dd = strmid(image_time, 8, 2)
 hhmmss = strmid(image_time, 11, 8)
 yydoy = yymmdd_to_yydoy(strmid(yyyy, 2, 2) + mm + dd)
 scet = strmid(yydoy, 0, 2) + '.' + strmid(yydoy, 2, 3) + ' ' + hhmmss

 return, scet[0]
end
;=============================================================================
