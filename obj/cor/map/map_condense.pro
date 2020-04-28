;===========================================================================
; map_condense
;
;  Modify md to include only the bounded region of the map.
;
;===========================================================================
pro map_condense, md, bounds
@core.include

 n = 100d

 ;------------------------------------------
 ; generate lines at constant bound coords
 ;------------------------------------------
 all_lat = dindgen(n)/n * (bounds[1]-bounds[0]) + bounds[0]
 all_lon = dindgen(n)/n * (bounds[3]-bounds[2]) + bounds[2]

 map_pts_lat0 = dblarr(2,n)
 map_pts_lat1 = dblarr(2,n)
 map_pts_lon0 = dblarr(2,n)
 map_pts_lon1 = dblarr(2,n)

 map_pts_lat0[0,*] = bounds[0]
 map_pts_lat0[1,*] = all_lon

 map_pts_lat1[0,*] = bounds[1]
 map_pts_lat1[1,*] = all_lon

 map_pts_lon0[0,*] = all_lat
 map_pts_lon0[1,*] = bounds[2]

 map_pts_lon1[0,*] = all_lat
 map_pts_lon1[1,*] = bounds[3]

 image_pts_lat0 = map_map_to_image(md, map_pts_lat0)
 image_pts_lat1 = map_map_to_image(md, map_pts_lat1)
 image_pts_lon0 = map_map_to_image(md, map_pts_lon0)
 image_pts_lon1 = map_map_to_image(md, map_pts_lon1)


 ;----------------------------------------------------------------
 ; new image boundaries are max and min extent of lat/lon lines
 ;----------------------------------------------------------------
 x_pts = [image_pts_lat0[0,*], image_pts_lat1[0,*], $
          image_pts_lon0[0,*], image_pts_lon1[0,*]]
 y_pts = [image_pts_lat0[1,*], image_pts_lat1[1,*], $
          image_pts_lon0[1,*], image_pts_lon1[1,*]]

 xmax = max(x_pts)
 xmin = min(x_pts)

 ymax = max(y_pts)
 ymin = min(y_pts)


 ;----------------------------------------------------------------
 ; modify map descriptor
 ;----------------------------------------------------------------
 new_xsize = xmax-xmin-1
 new_ysize = ymax-ymin-1

 origin = map_origin(md)
 scale = map_scale(md)
 size = map_size(md)

 map_set_size, md, [new_xsize, new_ysize]

 map_set_origin, md, [origin[0]-xmin, origin[1]-ymin]

 new_scale = max([size[0]/new_xsize, size[1]/new_ysize]) ;* scale
 map_set_scale, md, new_scale

end
;===========================================================================
