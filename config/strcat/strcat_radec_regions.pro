;=============================================================================
; strcat_radec_regions
;
;=============================================================================
function strcat_radec_regions, ra_fov, dec_fov, $
     ra1_regions, ra2_regions, dec1_regions, dec2_regions

 n = n_elements(ra1_regions)

 ;---------------------------------------------------
 ; convert to vectors
 ;---------------------------------------------------
 radec_fov = dblarr(4,3)
 radec_fov[*,0] = [ra_fov[0], ra_fov[1], ra_fov[1], ra_fov[0]]
 radec_fov[*,1] = [dec_fov[0], dec_fov[0], dec_fov[1], dec_fov[1]]
 radec_fov[*,2] = 1

 radec_regions = dblarr(4*n, 3)
 radec_regions[*,0] = [ra1_regions, ra2_regions, ra2_regions, ra1_regions]
 radec_regions[*,1] = [dec1_regions, dec1_regions, dec2_regions, dec2_regions]
 radec_regions[*,2] = 1

 bd = bod_inertial()
 v_fov = bod_radec_to_body(bd, radec_fov)
 v_regions = bod_radec_to_body(bd, radec_regions)


 ;---------------------------------------------------
 ; check for region corners within fov
 ;---------------------------------------------------
 w = v_interior_convex(v_fov, v_regions)
 if(w[0] NE -1) then return, unique(w mod n)


 ;---------------------------------------------------
 ; check for fov corners within regions
 ;---------------------------------------------------
 for i=0, n-1 do $
  begin
   ii = lindgen(4)*n + i
   w = v_interior_convex(v_regions[ii,*], v_fov)
   if(w[0] NE -1) then ww = append_array(ww, i)
  end

 return, ww
end
;=============================================================================
