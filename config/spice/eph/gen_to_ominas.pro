;=============================================================================
; gen_to_ominas
;
;=============================================================================
function gen_to_ominas, od

 if(NOT keyword__set(od)) then return, 0

 bod_set_pos, od, bod_pos(od)*1000d           ; km --> m
 bod_set_vel, od, bod_vel(od)*1000d           ; km/s --> m/s
 glb_set_radii, od, glb_radii(od)*1000d     ; km --> m
 sld_set_gm, od, sld_gm(od)*1d9, /nosynch   ; km3/s2kg --> m3/s2kg
 glb_set_rref, od, glb_rref(od)*1000d       ; km --> m
 return, od


 return, od
end
;=============================================================================


