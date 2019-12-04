;===========================================================================
; tvim_compare
;
;===========================================================================
function tvim_compare, tvd1, tvd2
 
 if(NOT keyword_set(tvd1)) then return, 0
 if(NOT keyword_set(tvd2)) then return, 0

 if(tvd1.order NE tvd2.order) then return, 0
 if(tvd1.zoom[0] NE tvd2.zoom[0]) then return, 0
 if(tvd1.zoom[1] NE tvd2.zoom[1]) then return, 0
 if(tvd1.offset[0] NE tvd2.offset[0]) then return, 0
 if(tvd1.offset[1] NE tvd2.offset[1]) then return, 0
 if(tvd1.rotate NE tvd2.rotate) then return, 0

 return, 1
end
;===========================================================================


