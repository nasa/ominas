;=============================================================================
; vgr_scet_to_image_time
;
;
;=============================================================================
function vgr_scet_to_image_time, scet

 yy = strmid(scet, 0, 2)
 doy = strmid(scet, 3, 3)
 hhmmss = strmid(scet, 7, 9)

 image_time = '19' + yy + '-' + doy + 'T' + hhmmss + '.000'

 return, image_time[0]
end
;=============================================================================
