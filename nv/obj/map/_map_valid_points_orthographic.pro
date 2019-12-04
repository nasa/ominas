;=============================================================================
; _map_valid_points_orthographic
;
;=============================================================================
function _map_valid_points_orthographic, _md, map_pts, image_pts

 nt = n_elements(_md)
 sv = size(image_pts)
 nv = 1
 if(sv[0] GT 1) then nv = sv[2]

 ii = transpose(linegen3z(2,nt,nv), [0,2,1])
 center = (_md.center)[ii]

 lat = center[0,*,*] & lon = center[1,*,*]
 sin_lat = sin(lat) & cos_lat = cos(lat)
 sin_lon = sin(lon) & cos_lon = cos(lon)
 n = dblarr(nv,3,nt)
 n[*,0,*] = cos_lat*cos_lon
 n[*,1,*] = cos_lat*sin_lon
 n[*,2,*] = sin_lat

 lats = map_pts[0,*,*] & lons = map_pts[1,*,*]
 sin_lats = sin(lats) & cos_lats = cos(lats)
 sin_lons = sin(lons) & cos_lons = cos(lons)
 v = dblarr(nv,3,nt)
 v[*,0,*] = cos_lats*cos_lons	
 v[*,1,*] = cos_lats*sin_lons
 v[*,2,*] = sin_lats

 dot = v_inner(n, v)

 valid = where(dot GT 0)
 return, valid
end
;=============================================================================
