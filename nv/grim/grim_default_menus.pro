;=============================================================================
;+
; NAME:
;	grim_menu_core_event
;
;
; PURPOSE:
;	This option allows you extract a brightness profile at the selected
;	location for each plane in the image.  The left button selects a single 
;	point, and the right button selects a region to average over.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2016
;	
;-
;=============================================================================
pro grim_menu_core_help_event, event
 text = ''
 nv_help, 'grim_menu_core_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_core_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 if(nplanes EQ 1) then $
  begin
   grim_message, 'Multiple image planes required.'
   return
  end

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
; widget_control, /hourglass
 cd = grim_get_cameras(grim_data)

 ;------------------------------------------------
 ; select region
 ;------------------------------------------------
 device, cursor_standard=30

 cursor, px, py, /down
 button = !err
 p0 = [px,py]

 color = ctyellow()

 if(button EQ 1) then $
  begin
   outline_ptd = pnt_create_descriptors(points=p0)
   grim_add_user_points, outline_ptd, color=color, psym=1, plane=plane
  end $
 else if(button EQ 4) then $
  begin
;stop
;help, event.modifier
;   box = event.modifier EQ 1 ? 0 : 1
box = 1

   _p0 = (convert_coord(/data, /to_device, p0))[0:1]
   grim_logging, grim_data, /start
   region = pg_select_region(box=box, 0, p0=_p0, /autoclose, $
                       cancel_button=2, end_button=-1, select_button=4, $
                                                    color=color, image_pts=_p)
   grim_logging, grim_data, /stop

   pp = (convert_coord(/device, /to_data, double(_p[0,*]), double(_p[1,*])))[0:1,*]
   outline_ptd = pnt_create_descriptors(points=pp)

;   dim = dat_dim(dd)
;   sub = polyfillv(pp[0,*], pp[1,*], dim[0], dim[1])

   grim_add_user_points, outline_ptd, color=color, psym=-3, plane=plane
  end $
 else return




 ;------------------------------------------------
 ; open a new grim window with the core
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_core(planes.dd, sigma=sigma, cd=cd, outline_ptd, distance=distance)
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, dd, xtitle=dat_label_abscissa(plane.dd), $
           ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
                                    title=['Core', 'Core sigma'], /new

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_image_profile_event
;
;
; PURPOSE:
;	This option allows you extract a brightness profile in an arbitrary 
;	direction in the image.  The left button selects the region's length 
;	and then width; the right button selects a region with a width of 
;	one pixel.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2005
;	
;-
;=============================================================================
pro grim_menu_image_profile_help_event, event
 text = ''
 nv_help, 'grim_menu_image_profile_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_image_profile_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 cd = grim_get_cameras(grim_data)

 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_image_sector(col=ctred())
 grim_logging, grim_data, /stop

 w = where(~ finite(pnt_points(outline_ptd))) 
 if(w[0] NE -1) then return


 ;------------------------------------------------
 ; save the sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, color='red', psym=3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_image(plane.dd, sigma=sigma, $
                             cd=grim_xd(plane, /cd), outline_ptd, distance=distance)
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, dd, tag='Image Profile', $
             xtitle='Distance (pixels)', $
             ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
                   title=['Image profile', 'Image profile sigma'], /new
 
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_ring_box_profile_radial_event
;
;
; PURPOSE:
;  This option allows you create a radial brightness profile from a 
;  rectangular image region. 
;  
;   1) Activate the ring from which you wish to extract the profile.  
;  
;   2) Select this option and use the mouse to outline a ring sector:
;  
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2003
;	
;-
;=============================================================================
pro grim_menu_ring_box_profile_radial_help_event, event
 text = ''
 nv_help, 'grim_menu_ring_box_profile_radial_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_ring_box_profile_radial_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 rd = grim_xd(plane, /ring, /active)
 if(NOT keyword__set(rd)) then $
  begin
   grim_message, 'There are no active ring points.'
   return
  end

 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 pd = grim_get_planets(grim_data)
 if(NOT keyword__set(pd[0])) then return
 rd = grim_get_rings(grim_data)
 if(NOT keyword__set(rd[0])) then return


 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_ring_sector_box(col=ctred())
 grim_logging, grim_data, /stop

 ;------------------------------------------------
 ; save the ring sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, 'RING_BOX_PROFILE_RADIAL', color='red', psym=-3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_ring(plane.dd, sigma=sigma, w=w, nn=nn, $
                  cd=grim_xd(plane, /cd), dkx=rd[0], outline_ptd, dsk_pts=dsk_pts)
 if(NOT keyword_set(dd)) then return

 cor_set_udata, dd[0], 'DISK_PTS', dsk_pts
 cor_set_udata, dd[0], 'RING_BOX_PROFILE_RADIAL_OUTLINE', outline_ptd
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, tag='Ring Box Profile Radial', $
      dd, xtitle='Radius', ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
          title=['Radial ring profile', 'Radial ring profile sigmas'], /new
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_ring_box_profile_longitudinal_event
;
;
; PURPOSE:
;  This option allows you create a longitudinal brightness profile from a 
;  rectangular image region.
;  
;    1) Activate the ring from which you wish to extract the profile. 
;  
;    2) Select this option and use the mouse to outline a ring sector.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2003
;	
;-
;=============================================================================
pro grim_menu_ring_box_profile_longitudinal_help_event, event
 text = ''
 nv_help, 'grim_menu_ring_box_profile_longitudinal_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_ring_box_profile_longitudinal_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 rd = grim_xd(plane, /ring, /active)
 if(NOT keyword__set(rd)) then $
  begin
   grim_message, 'There are no active ring points.'
   return
  end

 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 pd = grim_get_planets(grim_data)
 if(NOT keyword__set(pd[0])) then return
 rd = grim_get_rings(grim_data)
 if(NOT keyword__set(rd[0])) then return


 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_ring_sector_box(col=ctred())
 grim_logging, grim_data, /stop

 ;------------------------------------------------
 ; save the ring sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, 'RING_BOX_PROFILE_LONGITUDINAL', color='red', psym=-3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_ring(plane.dd, sigma=sigma, $
                 cd=grim_xd(plane, /cd), dkx=rd[0], outline_ptd, dsk_pts=dsk_pts, /az)
 if(NOT keyword_set(dd)) then return

 cor_set_udata, dd[0], 'DISK_PTS', dsk_pts
 cor_set_udata, dd[0], 'RING_BOX_PROFILE_LONGITUDINAL_OUTLINE', outline_ptd
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, tag='Ring Box Profile Azimuthal', dd, /new, $
     xtitle='Longitude (deg)', ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
         title=['Longitudinal ring profile', 'Longitudinal ring profile sigmas']
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_ring_profile_radial_event
;
;
; PURPOSE:
;  This option allows you create a radial brightness profile. 
;  
;   1) Activate the ring from which you wish to extract the profile.  
;  
;   2) Select this option and use the mouse to outline a ring sector:
;  
;      Left Button:   the sector is bounded by lines of constant 
;                     longitude.', $
;      Middle Button: the sector is selected in an arbitrary direction.
;      Left Button:   the sector is bounded by lines perpendicular to 
;                     the projected longitudinal direction.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2003
;	
;-
;=============================================================================
pro grim_menu_ring_profile_radial_help_event, event
 text = ''
 nv_help, 'grim_menu_ring_profile_radial_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_ring_profile_radial_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 rd = grim_xd(plane, /ring, /active)
 if(NOT keyword__set(rd)) then $
  begin
   grim_message, 'There are no active ring points.'
   return
  end

 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 pd = grim_get_planets(grim_data)
 if(NOT keyword__set(pd[0])) then return
 rd = grim_get_rings(grim_data)
 if(NOT keyword__set(rd[0])) then return


 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_ring_sector(cd=grim_xd(plane, /cd), dkx=rd[0], col=ctred())
 grim_logging, grim_data, /stop

 p = pnt_points(outline_ptd)

 w = where(~ finite(p)) 
 if(w[0] NE -1) then return

 if(stdev(p[0,*]) EQ 0) then return
 if(stdev(p[1,*]) EQ 0) then return

 ;------------------------------------------------
 ; save the ring sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, 'RING_PROFILE_RADIAL', color='red', psym=3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_ring(plane.dd, sigma=sigma, $
                  cd=grim_xd(plane, /cd), dkx=rd[0], outline_ptd, dsk_pts=dsk_pts)
 if(NOT keyword_set(dd)) then return

 cor_set_udata, dd[0], 'DISK_PTS', dsk_pts
 cor_set_udata, dd[0], 'RING_PROFILE_RADIAL_OUTLINE', outline_ptd

 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, tag='Ring Profile Radial', $
      dd, xtitle='Radius', ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
       title=['Radial ring profile', 'Radial ring profile sigmas'], /new
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_ring_profile_longitudinal_event
;
;
; PURPOSE:
;  This option allows you create a longitudinal brightness profile.
;  
;    1) Activate the ring from which you wish to extract the profile. 
;  
;    2) Select this option and use the mouse to outline a ring sector.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2003
;	
;-
;=============================================================================
pro grim_menu_ring_profile_longitudinal_help_event, event
 text = ''
 nv_help, 'grim_menu_ring_profile_longitudinal_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_ring_profile_longitudinal_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 rd = grim_xd(plane, /ring, /active)
 if(NOT keyword__set(rd)) then $
  begin
   grim_message, 'There are no active ring points.'
   return
  end

 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 pd = grim_get_planets(grim_data)
 if(NOT keyword__set(pd[0])) then return
 rd = grim_get_rings(grim_data)
 if(NOT keyword__set(rd[0])) then return


 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_ring_sector(cd=grim_xd(plane, /cd), dkx=rd[0], lon=lon, col=ctred())
 grim_logging, grim_data, /stop

 p = pnt_points(outline_ptd)

 w = where(~ finite(p)) 
 if(w[0] NE -1) then return

 if(stdev(p[0,*]) EQ 0) then return
 if(stdev(p[1,*]) EQ 0) then return

 ;------------------------------------------------
 ; save the ring sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, 'RING_PROFILE_LONGITUDINAL', color='red', psym=3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_ring(plane.dd, sigma=sigma, $
                 cd=grim_xd(plane, /cd), dkx=rd[0], outline_ptd, dsk_pts=dsk_pts, /az)
 if(NOT keyword_set(dd)) then return

 cor_set_udata, dd[0], 'DISK_PTS', dsk_pts
 cor_set_udata, dd[0], 'RING_PROFILE_LONGITUDINAL_OUTLINE', outline_ptd
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, tag='Ring Profile Azimuthal', dd, /new, $
     xtitle='Longitude (deg)', ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
         title=['Longitudinal ring profile', 'Longitudinal ring profile sigmas']
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_limb_profile_azimuthal_event
;
;
; PURPOSE:
;  This option allows you create an azimutal brightness profile about a limb.
;  
;    1) Activate the planet from which you wish to extract the profile. 
;  
;    2) Select this option and use the mouse to outline a sector.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2006
;	
;-
;=============================================================================
pro grim_menu_limb_profile_azimuthal_help_event, event
 text = ''
 nv_help, 'grim_menu_limb_profile_azimuthal_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_limb_profile_azimuthal_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 pd = grim_xd(plane, /planet, /active)
 if(NOT keyword__set(pd)) then $
  begin
   grim_message, 'There are no active planets.'
   return
  end

 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return


 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_limb_sector(cd=grim_xd(plane, /cd), gbx=pd[0], $
                                      col=ctred(), dkd=dkd, az=scan_az)
 grim_logging, grim_data, /stop

 p = pnt_points(outline_ptd)

 w = where(~ finite(p)) 
 if(w[0] NE -1) then return

 if(stdev(p[0,*]) EQ 0) then return
 if(stdev(p[1,*]) EQ 0) then return

 ;------------------------------------------------
 ; save the ring sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, 'LIMB_PROFILE_AZIMUTHAL', color='red', psym=3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_ring(plane.dd, sigma=sigma, $
                 cd=grim_xd(plane, /cd), dkx=dkd, outline_ptd, dsk_pts=dsk_pts, /az)
 cor_set_udata, dd[0], 'DISK_PTS', dsk_pts
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, tag='Limb Profile Azimuthual', dd, /new, $
     xtitle='Azimuth (deg)',ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
         title=['Azimuthal limb profile', 'Azimuthal limb profile sigmas']
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_limb_profile_radial_event
;
;
; PURPOSE:
;  This option allows you create radial brightness profile across a limb.
;  
;    1) Activate the planet from which you wish to extract the profile. 
;  
;    2) Select this option and use the mouse to outline a sector.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2006
;	
;-
;=============================================================================
pro grim_menu_limb_profile_radial_help_event, event
 text = ''
 nv_help, 'grim_menu_limb_profile_radial_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_limb_profile_radial_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 pd = grim_xd(plane, /planet, /active)
 if(NOT keyword__set(pd)) then $
  begin
   grim_message, 'There are no active planets.'
   return
  end

 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return


 ;------------------------------------------------
 ; select the sector by dragging
 ;------------------------------------------------
 grim_logging, grim_data, /start
 outline_ptd = pg_limb_sector(cd=grim_xd(plane, /cd), gbx=pd[0], col=ctred(), dkd=dkd)
 grim_logging, grim_data, /stop

 p = pnt_points(outline_ptd)

 w = where(~ finite(p)) 
 if(w[0] NE -1) then return

 if(stdev(p[0,*]) EQ 0) then return
 if(stdev(p[1,*]) EQ 0) then return

 ;------------------------------------------------
 ; save the ring sector outline
 ;------------------------------------------------
 grim_add_user_points, outline_ptd, 'LIMB_PROFILE_RADIAL', color='red', psym=3, plane=plane

 ;------------------------------------------------
 ; open a new grim window with the profile
 ;------------------------------------------------
 grim_message, /clear
 dd = pg_profile_ring(plane.dd, sigma=sigma, $
                 cd=grim_xd(plane, /cd), dkx=dkd, outline_ptd, dsk_pts=dsk_pts)
 cor_set_udata, dd[0], 'DISK_PTS', dsk_pts
 grim_message
 if(NOT keyword_set(dd)) then return

 widget_control, /hourglass
 grim, tag='Limb Profile Radial', dd, /new, $
     xtitle='Radius (m)', ytitle=dat_label_data(plane.dd) + ['', ' Sigma'], $
         title=['Radial limb profile', 'Radial limb profile sigmas']
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_pointing_farfit_event
;
;
; PURPOSE:
;   This option produces a rough pointing correction by comparing the
;   active points with edges detected in the image using pg_edges and 
;   pg_farfit.  
;  
;    1) Activate the edges that you wish to correlate.
;  
;    2) Select this option.
;  
;   Only active limbs, terminators, and ring edges are used.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_pointing_farfit_help_event, event
 text = ''
 nv_help, 'grim_menu_pointing_farfit_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_pointing_farfit_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 widget_control, grim_data.draw, /hourglass

 ;----------------------------------------------------------------------
 ; construct the outlines to use based on currently existing points
 ;----------------------------------------------------------------------
 point_ptd = grim_ptd(plane, /active)
 if(NOT keyword_set(point_ptd)) then $
  begin
   grim_message, 'No active image points.'
   return
  end

 ;------------------------------------------------
 ; scan for edges
 ;------------------------------------------------
 np = n_elements(pnt_points(/cat, point_ptd))/2
 edge_ptd = pg_edges(plane.dd, edge=10, np=4*np)
 pg_draw, edge_ptd, col=ctgreen()

 ;------------------------------------------------
 ; find the offset
 ;------------------------------------------------
 grim_message, /clear
 dxy = pg_farfit(plane.dd, edge_ptd, [point_ptd])
 grim_message

 ;------------------------------------------------------------
 ; repoint the camera
 ;  NOTE: this will result in a data event and the handler
 ;        for that event will take it from here. 
 ;------------------------------------------------------------
 pg_repoint, dxy, 0d, cd=grim_xd(plane, /cd)
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_pointing_renderfit_event
;
;
; PURPOSE:
;   This option uses pg_renderfit to produce a pointing correction by comparing 
;   the image with a simulated image.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2017
;	
;-
;=============================================================================
pro grim_menu_pointing_renderfit_help_event, event
 text = ''
 nv_help, 'grim_menu_pointing_renderfit_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_pointing_renderfit_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 ltd = (grim_data)
 if(NOT keyword__set(ltd[0])) then return
 pd = grim_get_planets(grim_data)
 if(keyword__set(pd[0])) then bx = append_array(bx, pd)
 rd = grim_get_rings(grim_data)
 if(keyword__set(rd[0])) then bx = append_array(bx, rd)

 ;------------------------------------------------
 ; find the offset
 ;------------------------------------------------
 grim_message, /clear
 dxy = pg_renderfit(plane.dd, cd=cd, ltd=ltd, bx=bx, /show)
 grim_message

 ;------------------------------------------------------------
 ; repoint the camera
 ;  NOTE: this will result in a data event and the handler
 ;        for that event will take it from here. 
 ;------------------------------------------------------------
 pg_repoint, dxy, 0d, cd=cd
 

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_pointing_lsq_event
;
;
; PURPOSE:
;	Opens a gr_lsqtool widget.  Using the current data, camera, active
;	planet, and active ring descriptors.  See gr_lsqtool.pro for details.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_pointing_lsq_help_event, event
 text = ''
 nv_help, 'gr_lsqtool', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_pointing_lsq_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return


 ;------------------------------------------------
 ; open a gr_lsqtool
 ;------------------------------------------------
 wset, grim_data.wnum

 gr_lsqtool, event.top




end
;=============================================================================



;=============================================================================
; grim_get_shift_step
;
;=============================================================================
function grim_get_shift_step, grim_data

 step = grim_get_user_data(grim_data, 'SHIFT_STEP')
 if(NOT keyword_set(step)) then step = 1

 return, step
end
;=============================================================================



;=============================================================================
; grim_reposition
;
;=============================================================================
pro grim_reposition, grim_data, plane, cd=cd, shift

 pos = cor_udata(plane.dd, 'IMAGE_POS')
 if(NOT keyword_set(pos)) then pos = [0d,0d]
 pos = pos + shift
 cor_set_udata, plane.dd, 'IMAGE_POS', pos

 flag = grim_get_toggle_flag(grim_data, 'SHIFT_REORIGIN')
 if(keyword_set(flag)) then set_image_origin, cd, image_origin(cd) + shift
 nv_flush

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_toggle_reorigin_event
;
;
; PURPOSE:
;   This option allows the user to set whether geometry descriptors are
;   updated whenever the data array is shifted.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2016
;	
;-
;=============================================================================
pro grim_menu_toggle_reorigin_event_help_event, event
 text = ''
 nv_help, 'grim_menu_toggle_reorigin_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_toggle_reorigin_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'SHIFT_REORIGIN')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'SHIFT_REORIGIN', flag
 grim_update_menu_toggle, grim_data, $
         'grim_menu_toggle_reorigin_event', flag


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_shift_enter_step_event
;
;
; PURPOSE:
;   This option prompts the user to enter the step size for the image-shift
;   menu options.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2012
;	
;-
;=============================================================================
pro grim_menu_shift_enter_step_event_help_event, event
 text = ''
 nv_help, 'grim_menu_shift_enter_step_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_shift_enter_step_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 done = 0
 repeat $
  begin
   steps = dialog_input('New step size:')
   if(NOT keyword_set(steps)) then return
   w = str_isfloat(steps)
   if(w[0] NE -1) then done = 1
  endrep until(done)

 step = double(steps)
 grim_set_user_data, grim_data, 'SHIFT_STEP', step

 grim_set_menu_value, grim_data, 'grim_menu_shift_enter_step_event', step, len=3

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_shift_enter_offset_event
;
;
; PURPOSE:
;   This option prompts the user to shift an image by entering an offset.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2012
;	
;-
;=============================================================================
pro grim_menu_shift_enter_offset_event_help_event, event
 text = ''
 nv_help, 'grim_menu_shift_enter_offset_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_shift_enter_offset_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 done = 0
 repeat $
  begin
   offs = dialog_input('New offset [dx,dy]:', cancelled=cancelled)
   if(cancelled) then return
   if(keyword_set(offs)) then $
    begin
     s = parse_numeric_list(offs)
     if(keyword_set(s)) then $
      begin
       w = str_isfloat(s)
       if(n_elements(w) EQ 2) then done = 1
      end
    end
  endrep until(done)

 shift = double(s)
 grim_reposition, grim_data, plane, cd=grim_xd(plane, /cd), -shift


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_shift_left_event
;
;
; PURPOSE:
;   This option shifts the image left and corrects the camera pointing 
;   accordingly.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_shift_left_help_event, event
 text = ''
 nv_help, 'grim_menu_shift_left_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_shift_left_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 step = grim_get_shift_step(grim_data)
 grim_reposition, grim_data, plane, cd=grim_xd(plane, /cd), -[step,0]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_shift_right_event
;
;
; PURPOSE:
;   This option shifts the image right and corrects the camera pointing 
;   accordingly.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_shift_right_help_event, event
 text = ''
 nv_help, 'grim_menu_shift_right_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_shift_right_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 step = grim_get_shift_step(grim_data)
 grim_reposition, grim_data, plane, cd=grim_xd(plane, /cd), -[-step,0]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_shift_up_event
;
;
; PURPOSE:
;   This option shifts the image up and corrects the camera pointing 
;   accordingly.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_shift_up_help_event, event
 text = ''
 nv_help, 'grim_menu_shift_up_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_shift_up_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 step = grim_get_shift_step(grim_data)
 dy = -step
 grim_wset, grim_data, grim_data.wnum, get=tvd
 if(tvd.order) then dy = step

 grim_reposition, grim_data, plane, cd=grim_xd(plane, /cd), -[0,dy]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_shift_down_event
;
;
; PURPOSE:
;   This option shifts the image down and corrects the camera pointing 
;   accordingly.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_shift_down_help_event, event
 text = ''
 nv_help, 'grim_menu_shift_down_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_shift_down_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 step = grim_get_shift_step(grim_data)
 dy = step
 grim_wset, grim_data, grim_data.wnum, get=tvd
 if(tvd.order) then dy = -step

 grim_reposition, grim_data, plane, cd=grim_xd(plane, /cd), -[0,dy]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_corrections_photometry_event
;
;
; PURPOSE:
;	Opens a gr_phttool widget.  Using the primary data, camera, planet, and 
;	ring descriptors.  See gr_phttool.pro for details.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_corrections_photometry_help_event, event
 text = ''
 nv_help, 'gr_phttool', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_corrections_photometry_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 pd = grim_get_planets(grim_data)
 if(NOT keyword__set(pd[0])) then return
 ltd = grim_get_lights(grim_data)
 if(NOT keyword__set(ltd[0])) then return


 ;------------------------------------------------
 ; open a gr_phttool
 ;------------------------------------------------
 gr_phttool, event.top


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_project_map_event
;
;
; PURPOSE:
;	Opens a gr_maptool widget.  Using the primary data, camera, planet, and 
;	ring descriptors.  See gr_maptool.pro for details.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_project_map_help_event, event
 text = ''
 nv_help, 'gr_maptool', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_project_map_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 cd = grim_get_cameras(grim_data)
 if(NOT keyword__set(cd[0])) then return
 pd = grim_get_planets(grim_data)
 if(NOT keyword__set(pd[0])) then return
 ltd = grim_get_lights(grim_data)
 if(NOT keyword__set(ltd[0])) then return


 ;------------------------------------------------
 ; open a gr_maptool
 ;------------------------------------------------
 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 gr_maptool, order=tvd.order


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_mosaic_event
;
;
; PURPOSE:
;	Uses pg_mosaic to combine all visible image planes into a mosaic.  
;	The new mosiac is opened in a new grim instance.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_mosaic_help_event, event
 text = ''
 nv_help, 'grim_menu_mosaic_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_mosaic_event, event
;grim_message, 'Not implemented.'
;return

 ;------------------------------------------------
 ; get all visible planes
 ;------------------------------------------------
 widget_control, /hourglass

 tops = grim_get_selected()
 ntops = n_elements(tops)
 for i=0, ntops-1 do $
  begin
   grim_data = grim_get_data(tops[i])
   planes = append_array(planes, grim_visible_planes(grim_data))
  end

 if(n_elements(planes) EQ 1) then $
  begin
   grim_message, 'There is only one visible plane.'
   return
  end

 ;------------------------------------------------
 ; construct mosaic
 ;------------------------------------------------
 dd_mosaic = pg_mosaic(planes.dd, combine='mean')


 ;--------------------------------------------------------------
 ; open mosaic in new grim window
 ;--------------------------------------------------------------
 grim, /new, dd_mosaic


end
;=============================================================================



;=============================================================================
; NAME:
;	grim_menu_read_mind_event
;
;=============================================================================
pro grim_menu_read_mind_event, event

 grim_message, 'Not implemented!'

end
;=============================================================================



;=============================================================================
; grim_default_menus_init
;
;=============================================================================
pro grim_default_menus_init, grim_data, arg
 grim_update_menu_toggle, grim_data, $
         'grim_menu_toggle_reorigin_event', $
          grim_get_toggle_flag(grim_data, 'SHIFT_REORIGIN')

   grim_set_menu_value, grim_data, $
         'grim_menu_shift_enter_step_event', grim_get_shift_step(grim_data)
end
;=============================================================================



;=============================================================================
; grim_default_menus
;
;=============================================================================
function grim_default_menus

 desc = [ '*1\Extract', $
           '1\Ring sector profile' , $
            '0\Radial\grim_menu_ring_profile_radial_event', $ 
            '0\Longitudinal\grim_menu_ring_profile_longitudinal_event', $
            '2\<null>               \+*grim_menu_delim_event', $
           '1\Ring box profile' , $
            '0\Radial\grim_menu_ring_box_profile_radial_event', $ 
            '0\Longitudinal\grim_menu_ring_box_profile_longitudinal_event', $
            '2\<null>               \+*grim_menu_delim_event', $
           '1\Limb sector profile' , $
            '0\Radial\grim_menu_limb_profile_radial_event', $ 
            '0\Azimuthal\grim_menu_limb_profile_azimuthal_event', $
            '2\<null>               \+*grim_menu_delim_event', $
           '0\Image Profile    \*grim_menu_image_profile_event', $ 
           '0\Core          \*grim_menu_core_event', $ 
           '0\Read Mind\*grim_menu_read_mind_event', $ 
           '2\<null>               \+*grim_menu_delim_event', $

	  '*1\Corrections', $
           '1\Pointing' , $
            '0\Farfit\!grim_menu_pointing_farfit_event', $
;;            '?0\Renderfit\!grim_menu_pointing_renderfit_event', $
            '0\Least Squares\grim_menu_pointing_lsq_event', $
            '2\<null>               \+*grim_menu_delim_event', $
           '*1\Shift Image' , $
            '0\Re-origin      [xxx]\*grim_menu_toggle_reorigin_event', $ 
            '0\Step Size      [xxx]\*grim_menu_shift_enter_step_event', $ 
            '0\Enter Offset  \*grim_menu_shift_enter_offset_event', $ 
            '0\Left \*grim_menu_shift_left_event', $ 
            '0\Right\*grim_menu_shift_right_event', $
            '0\Up   \*grim_menu_shift_up_event', $
            '0\Down \*grim_menu_shift_down_event', $
           '2\<null>               \+*grim_menu_delim_event', $
           '0\Photometry     \grim_menu_corrections_photometry_event' , $
           '2\<null>               \+*grim_menu_delim_event', $

          '#1\Reproject' , $
           '0\Map\#grim_menu_project_map_event', $ 
           '2\<null>               \+*grim_menu_delim_event', $

          '#1\Combine' , $
           '0\Mosaic\#grim_menu_mosaic_event', $
           '2\<null>               \+*grim_menu_delim_event' ]


 return, desc
end
;=============================================================================
