;===========================================================================
; orb_get_dlibdt_lan
;
;
;===========================================================================
function orb_get_dlibdt_lan, xd, frame_bd

 nt = n_elements(xd)

 dlibdt = bod_dlibdt(xd)

 dlibdt_lan = reform(dlibdt[1,*], nt, /over)

 return, dlibdt_lan
end
;===========================================================================
