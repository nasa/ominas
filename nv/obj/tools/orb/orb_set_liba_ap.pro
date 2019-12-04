;===========================================================================
; orb_set_liba_ap
;
;===========================================================================
pro orb_set_liba_ap, xd, frame_bd, liba_ap

 nt = n_elements(xd)

 orient = bod_orient(xd)
 libv = bod_libv(xd)

 _liba_ap = reform(liba_ap ## make_array(3, val=1), 1, 3, nt)
 libv[0,*,*] = orient[2,*,*] * _liba_ap

 bod_set_libv, xd, libv
end
;===========================================================================
