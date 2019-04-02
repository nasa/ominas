;===========================================================================
; detect_vgr_pps.pro
;
;===========================================================================
function detect_vgr_pps, dd

 label = (dat_header(dd))[0]
 if ~isa(label,'string') then return,0
 w = where(strpos(label, 'VG1 PPS') NE -1)
 if(w[0] NE -1) then return, 'VGR_PPS'
 w = where(strpos(label, 'VG2 PPS') NE -1)
 if(w[0] NE -1) then return, 'VGR_PPS'

 return, ''
end
;===========================================================================
