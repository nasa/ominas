;===========================================================================
; orb_get_dlibdt_ap
;
;
;===========================================================================
function orb_get_dlibdt_ap, xd, frame_bd

 nt = n_elements(xd)

 dlibdt = bod_dlibdt(xd)

 dlibdt_ap = reform(dlibdt[0,*], nt, /over) 

 return, dlibdt_ap
end
;===========================================================================
