;=============================================================================
; smear_psf
;
;
;=============================================================================
function smear_psf, cd, bx, width

stop
s psf0 = cam_psf(cd, width)

 exp = cam_exposure(cd)

 cd_start = cam_evolve(cd, -exp/2)
 cd_end = cam_evolve(cd, exp/2)

 bx_start = bod_evolve(bx, -exp/2)
 bx_end = bod_evolve(bx, exp/2)


 p_start = inertial_to_image_pos(cd_start, bod_pos(bx_start))
 p_end = inertial_to_image_pos(cd_end, bod_pos(bx_end))


 nv_free, [cd_start, cd_end, bx_start, bx_end]

end
;=============================================================================
