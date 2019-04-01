;==============================================================================
; radec_grid 
;
;  
;
;==============================================================================
pro radec_grid, cd, n=n, np=np, color=color, label=label

 if(NOT keyword_set(n)) then n = 15
 if(NOT keyword_set(np)) then np = 150

 radec_corner = dblarr(4,3)
 c0 = (convert_coord(0d,0d, /device, /to_data))[0:1]
 c1 = (convert_coord(double(!d.x_size-1), double(!d.y_size-1), /device, /to_data))[0:1]
 c2 = (convert_coord(double(!d.x_size-1), 0d, /device, /to_data))[0:1]
 c3 = (convert_coord(0d, double(!d.y_size-1), /device, /to_data))[0:1]
 radec_corner[0,*] = image_to_radec(cd, c0)
 radec_corner[1,*] = image_to_radec(cd, c1)
 radec_corner[2,*] = image_to_radec(cd, c2)
 radec_corner[3,*] = image_to_radec(cd, c3)


 ra0 = min(radec_corner[*,0]) & ra1 = max(radec_corner[*,0])
 dec0 = min(radec_corner[*,1]) & dec1 = max(radec_corner[*,1])
 if((abs(ra1-ra0) GE !dpi) OR (abs(ra1-ra0) GE !dpi/2d)) then $
  begin
   ra0 = -!dpi
   ra1 = !dpi
   dec0 = -!dpi/2d
   dec1 = !dpi/2d
  end

 ra = dindgen(np) * (ra1-ra0)/double(np-1) + ra0
 dec = dindgen(np) * (dec1-dec0)/double(np-1) + dec0


 grid_radec1 = dblarr(np,n,3)
 grid_radec1[*,*,0] = ra # make_array(n, val=1d)
 grid_radec1[*,*,1] = dec[lindgen(n)*(np/n)] ## make_array(np, val=1d)
 grid_radec1[*,*,2] = 1d
 grid_radec1 = reform(grid_radec1, np*n,3, /over)

 grid_radec2 = dblarr(np,n,3)
 grid_radec2[*,*,0] = ra[lindgen(n)*(np/n)] ## make_array(np, val=1d)
 grid_radec2[*,*,1] = dec # make_array(n, val=1d)
 grid_radec2[*,*,2] = 1d
 grid_radec2 = reform(grid_radec2, np*n,3, /over)

 grid_radec = dblarr(2*np*n,3)
 grid_radec[0:np*n-1,*] = grid_radec1
 grid_radec[np*n:*,*] = grid_radec2


 grid_pts = (radec_to_image(cd, grid_radec))[*,*,0]

; plots, image_pts[*,*,0], psym=1

 plots, grid_pts, psym=3, color=color

end
;==============================================================================
