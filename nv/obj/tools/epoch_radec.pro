;===============================================================================
; epoch_radec
;
;
;===============================================================================
function epoch_radec, od, bx, epoch

 nbx = n_elements(bx)
 t = bod_time(bx)
 dt = epoch - t


 odt = objarr(nbx)
 for i=0, nbx-1 do odt[i] = bod_evolve(od, dt[i])

 bxt = objarr(nbx)
 for i=0, nbx-1 do bxt[i] = bod_evolve(bx[i], dt[i])


 return, bod_body_to_radec(odt, $
           bod_inertial_to_body_pos(odt, bod_pos(bxt)))
end
;===============================================================================
