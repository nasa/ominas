;=============================================================================
; get_radperp
;
;=============================================================================
function get_radperp, cd, dkx, p0, p1, dsk_pt0

 dp = p1 - p0

 rng_orient = bod_orient(dkx)
 _dir = v_unit(bod_body_to_inertial(dkx, $
                dsk_disk_to_body(dkx, dsk_pt0)))
 dir = v_cross(_dir, rng_orient[2,*])

 cam_orient = bod_orient(cd)
 dirx = v_inner(dir, cam_orient[0,*])
 diry = v_inner(dir, cam_orient[2,*])
 u = [dirx,diry]
 u = u / sqrt(u[0]^2+u[1]^2)

 v = [-diry,dirx]
 v = v / sqrt(v[0]^2+v[1]^2)

 pp = p0 + v*(v[0]*dp[0] + v[1]*dp[1])

 return, pp
end
;=============================================================================



