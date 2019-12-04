;=============================================================================
; strcat_radec_select
;
;=============================================================================
function strcat_radec_select, ra_fov, dec_fov, ra, dec

 n = n_elements(ra)

 ;---------------------------------------------------
 ; convert to vectors
 ;---------------------------------------------------
 radec_fov = dblarr(4,3)
 radec_fov[*,0] = [ra_fov[0], ra_fov[1], ra_fov[1], ra_fov[0]]
 radec_fov[*,1] = [dec_fov[0], dec_fov[0], dec_fov[1], dec_fov[1]]
 radec_fov[*,2] = 1

 radec = dblarr(n, 3)
 radec[*,0] = [ra]
 radec[*,1] = [dec]
 radec[*,2] = 1

 bd = bod_inertial()
 v_fov = bod_radec_to_body(bd, radec_fov)
 v = bod_radec_to_body(bd, radec)

 ;---------------------------------------------------
 ; select vectors
 ;---------------------------------------------------
 w = v_interior_convex(v_fov, v)

 return, w
end
;=============================================================================
