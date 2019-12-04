;===========================================================================
; orb_set_liba_lan
;
;===========================================================================
pro orb_set_liba_lan, xd, frame_bd, liba_lan

 nt = n_elements(xd)

 orient0 = (bod_orient(frame_bd))[linegen3z(3,3,nt)]
 libv = bod_libv(xd)

 _liba_lan = reform(liba_lan ## make_array(3, val=1), 1, 3, nt)
 libv[1,*,*] = orient0[2,*,*] * _liba_lan

 bod_set_libv, xd, libv
end
;===========================================================================
