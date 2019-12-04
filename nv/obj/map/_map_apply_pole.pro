;===============================================================================
; _map_apply_pole
;
;===============================================================================
function _map_apply_pole, _md, map_pts, inverse=inverse

 nt = n_elements(_md)
 nv = n_elements(map_pts)/2/nt

 pole_lat = _md.pole.lat				      ;nt
 pole_lon = -_md.pole.lon				      ;nt
 pole_rot = _md.pole.rot				      ;nt
 lons = reform(map_pts[1,*,*])  			      ; 1,nv,nt
 lats = reform(map_pts[0,*,*])  			      ; 1,nv,nt

 p1 = make_array(nt, val=ominas_body())
 bod_rotate, p1, pole_lon, axis = 2
 bod_rotate, p1, (0.5d0*!dpi-pole_lat), axis = 1
 bod_rotate, p1, pole_rot, axis = 2
 tr = [1,0]
 if(nt GT 1) then tr = [tr, 2]
 if(NOT keyword_set(inverse)) then $
                       bod_set_orient, p1, transpose(bod_orient(p1), tr)

 z = sin(lats)  					      ; 1,nv,nt
 x = cos(lats)*cos(lons)				      ; 1,nv,nt
 y = cos(lats)*sin(lons)				      ; 1,nv,nt
 xyz = dblarr(nv,3,nt)
 xyz[*,0,*] = x & xyz[*,1,*] = y & xyz[*,2,*] = z 
 xyz = bod_body_to_inertial(p1, xyz)			      ; nv,3,nt
 lat1 = asin(xyz[*,2,*])				      ; nv,1,nt
 lon1 = atan(xyz[*,1,*], xyz[*,0,*])			      ; nv,1,nt
 
 nmap_pts = dblarr(2,nv,nt)
 nmap_pts[1,*,*] = lon1
 nmap_pts[0,*,*] = lat1

 nv_free, p1

 return, nmap_pts
end
;===============================================================================
