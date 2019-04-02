;=============================================================================
; strcat_radec_box
;
;=============================================================================
function strcat_radec_box, ra_fov, dec_fov, dradec=dradec, radius=radius, sa=sa

 ;---------------------------------------------------
 ; convert to vectors
 ;---------------------------------------------------
 radec_fov = dblarr(4,3)
 radec_fov[*,0] = [ra_fov[0],  ra_fov[1],  ra_fov[1],  ra_fov[0]]
 radec_fov[*,1] = [dec_fov[0], dec_fov[0], dec_fov[1], dec_fov[1]]
 radec_fov[*,2] = 1

 bd = bod_inertial()
 v_fov = bod_radec_to_body(bd, radec_fov)


 ;---------------------------------------------------
 ; compute widths and center
 ;---------------------------------------------------
 radec = bod_body_to_radec(bd, transpose(total(v_fov,1)/4))
 dradec = transpose( $
     [v_angle(v_fov[0,*], v_fov[1,*]), v_angle(v_fov[0,*], v_fov[3,*]), 0])


 ;---------------------------------------------------
 ; compute radius enclosing FOV
 ;---------------------------------------------------
 radius = (v_angle(v_fov[0,*], v_fov[3,*])/2)[0]


 ;---------------------------------------------------
 ; compute solid angle of radis containing FOV
 ;---------------------------------------------------
 sa = 2d*!dpi*(1d - cos(radius))


 return, radec
end
;=============================================================================
