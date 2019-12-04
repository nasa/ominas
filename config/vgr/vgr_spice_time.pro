;===========================================================================
; vgr_spice_time
;
;===========================================================================
function vgr_spice_time, label, dt=dt, string=close_time

 scet = vicar_vgrkey(label, 'SCET')
 p = strpos(strupcase(scet), 'UNKNOWN')
 if(p[0] NE -1) then return, -1d100

 exposure = vicar_vgrkey(label, 'EXP') / 1000d

 close_time = vgr_scet_to_image_time(scet)
 dt = -0.5d*exposure

 return, spice_str2et(close_time) + dt
end
;===========================================================================



