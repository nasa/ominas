;=============================================================================
; get_lonperp
;
;=============================================================================
function get_lonperp, cd, rd, p0, p1

 dp = p1 - p0
 dsk_pt0 = image_to_disk(cd, rd, p0)

 rng_orient = bod_orient(rd)
 _dir = v_unit(bod_body_to_inertial(rd, $
                dsk_disk_to_body(rd, dsk_pt0)))
 dir = v_cross(_dir, rng_orient[2,*])

 cam_orient = bod_orient(cd)
 dirx = v_inner(dir, cam_orient[0,*])
 diry = v_inner(dir, cam_orient[2,*])
 u = [dirx,diry]
 u = u / sqrt(u[0]^2+u[1]^2)

 v = [-diry,dirx]
 v = v / sqrt(v[0]^2+v[1]^2)

 pp = p0 + u*(u[0]*dp[0] + u[1]*dp[1])

 return, pp
end
;=============================================================================



