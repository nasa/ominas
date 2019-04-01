;=============================================================================
; grim_get_n_colors
;
;=============================================================================
function grim_get_n_colors, grim_data, plane=plane, type=type

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 type = dat_typecode(plane.dd)

 return, grim_n_colors(type)
end
;=============================================================================



;=============================================================================
; grim_visible_planes
;
;=============================================================================
function grim_visible_planes, grim_data, plane=plane, current=current
 
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 if(keyword_set(current)) then return, plane
 planes = grim_get_plane(grim_data, /all)

 vis = planes.visibility
 vis[plane.pn] = 1
 w = where(vis EQ 1)


 return, planes[w]
end
;=============================================================================



;=============================================================================
; grim_get_plane_by_xy
;
;=============================================================================
function grim_get_plane_by_xy, grim_data, xy

 planes = grim_visible_planes(grim_data)
 nplanes = n_elements(planes)

 dn = dblarr(nplanes)
 for i=0, nplanes-1 do dn[i] = dat_data(planes[i].dd, sample=xy, /nd)

 w = where(dn EQ max(dn))
 return, planes[w[0]]
end
;=============================================================================



;=============================================================================
; grim_get_plane_by_overlay
;
;=============================================================================
function grim_get_plane_by_overlay, grim_data, xy

 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 dist = make_array(nplanes, val=1d100)

 for i=0, nplanes-1 do $
  if((planes[i].pn EQ plane.pn) OR planes[i].visible) then $
   begin
    ptd = grim_ptd(planes[i])
    for j=0, n_elements(ptd)-1 do $
     begin
      ii = grim_nearest_overlay(plane, xy, ptd, mm=mm)
      if(ii[0] NE -1) then if(mm LT dist[i]) then dist[i] = mm
     end
   end

 w = where(dist LT 1d100)
 if(w[0] EQ -1) then return, 0

 w = min(where(dist EQ min(dist)))
 return, planes[w[0]]
end
;=============================================================================



;=============================================================================
; grim_test_single_channel
;
;=============================================================================
function grim_test_single_channel, grim_data
 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(/primary)

 planes = grim_visible_planes(grim_data)
 for i=0, n_elements(planes)-1 do $
            if(grim_test_rgb(grim_data, planes[i])) then return, 0

 rgb = planes.rgb
 return, total(rgb) EQ n_elements(planes)*3
end
;=============================================================================



;=============================================================================
; grim_toggle_image
;
;=============================================================================
pro grim_toggle_image, grim_data, plane, no_refresh=no_refresh, bm=bm

 if(NOT plane.image_visible) then $
  begin
   plane.image_visible = 1
   bm = grim_hide_image_bitmap()
   use_pixmap = 1
   tvd_save = *plane.tvd_save_p
   if(keyword_set(tvd_save)) then $
    begin
     tvim, grim_data.wnum, get=tvd, /no_coord
if(tvd.zoom[0] NE tvd_save.zoom[0]) then use_pixmap = 0
if(tvd.zoom[1] NE tvd_save.zoom[1]) then use_pixmap = 0
if(tvd.offset[0] NE tvd_save.offset[0]) then use_pixmap = 0
if(tvd.offset[1] NE tvd_save.offset[1]) then use_pixmap = 0
if(tvd.order NE tvd_save.order) then use_pixmap = 0
if(tvd.rotate NE tvd_save.rotate) then use_pixmap = 0
;     if(NOT nv_compare(tvd, tvd_save)) then use_pixmap = 0
    end
  end $
 else $
  begin
   plane.image_visible = 0
   bm = grim_unhide_image_bitmap()
   tvim, grim_data.wnum, get=tvd, /no_coord
   *plane.tvd_save_p = tvd
  end

 widget_control, grim_data.toggle_image_button, set_value=bm

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base

 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, use_pixmap=use_pixmap

end
;=============================================================================



;=============================================================================
; grim_toggle_image_overlays
;
;=============================================================================
pro grim_toggle_image_overlays, grim_data, plane, no_refresh=no_refresh

 grim_toggle_image, grim_data, plane, /no_refresh, bm=bmi
 grim_hide_overlays, grim_data, /no_refresh, bm=bmo

; widget_control, grim_data.toggle_image_overlays_button, set_value=bmi AND bmo


 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap
end
;=============================================================================



;=============================================================================
; grim_image
;
;=============================================================================
function grim_image, grim_data, plane=plane, pn=pn, colormap=colormap, $
                     channel=channel, current=current, $
                     xrange=xrange, yrange=yrange

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 ctmod, top=top

 dim = dat_dim(plane.dd)
 if(NOT keyword_set(dim)) then return, 0

;; dim = grim_redimension(dim, 2)
 dim = dim[0:1]

 ;---------------------------------------
 ; get all visible planes
 ;---------------------------------------
 planes = grim_visible_planes(grim_data, current=current, plane=plane)
 rgb = planes.rgb

 ;------------------------------------------------------
 ; determine scaling
 ;------------------------------------------------------
 max = plane.max[0]
 if(NOT keyword_set(max)) then max = max(dat_max(planes.dd))

 ;---------------------------------------
 ; get appropriate channel if specified
 ;---------------------------------------
 if(defined(channel)) then $
  begin
   w = where(rgb[channel,*] EQ 1)
   if(w[0] EQ -1) then return, 0
   planes = planes[w]
  end
 nplanes = n_elements(planes)

 ;------------------------------------------------------------------------
 ; Get output image grid 
 ;------------------------------------------------------------------------
 vp = get_viewport_indices(dim, xrange=xrange, yrange=yrange, $
              device_indices=vpi, device_size=device_size, p=data_xy, $
                                                      noclip=plane.rendering)
 if(n_elements(vp) EQ 1) then return, 0
 *grim_data.data_xy_p = data_xy


 ;----------------------------------------------------------------------
 ; construct output image by considering only unique data coords and
 ; averaging all visible planes
 ;----------------------------------------------------------------------
 im = (weight = 0)
 for i=0, nplanes-1 do $
  begin
   ; - - - - - - - - - - - - - - -
   ; get sub image
   ; - - - - - - - - - - - - - - -
   _im = grim_get_image(grim_data, plane=planes[i], $
                          channel=channel, sample=data_xy, abscissa=grid)

   ; - - - - - - - - - - - - - - -
   ; apply color map
   ; - - - - - - - - - - - - - - -
   colormap = compute_colormap(planes[i].cmd)
   _im = apply_colormap(_im, colormap, channel=channel, max=max, min=0)

   ; - - - - - - - - - - - - - - -
   ; add current image
   ; - - - - - - - - - - - - - - -
   im = im + _im
   weight = weight + fix(_im<1)

   grim_set_plane, grim_data, plane
  end


 ;----------------------------------------------------------------------
 ; weight average
 ;----------------------------------------------------------------------
 w = where(weight EQ 0)
 if(w[0] NE -1) then weight[w] = 1

 im = im / weight


 ;----------------------------------------------------------------------
 ; create final device image
 ;----------------------------------------------------------------------
 image = make_array(type=size(im, /type), dim=device_size)
 image[vpi] = im

; image = bytscl(image, max=plane.cmd.n_colors)
;image = bytscl(image, top=plane.cmd.n_colors)
;;image = bytscl(image, max=max, top=plane.cmd.n_colors)
;;;;;;;;print, min(image), max(image)

 return, image
end
;=============================================================================



;=============================================================================
; grim_scale_image
;
;=============================================================================
function grim_scale_image, grim_data, r, g, b, current=current, $
     plane=plane, no_scale=no_scale, top=top, xrange=xrange, yrange=yrange

 ;------------------------------------------------------
 ; test for single-channel
 ;------------------------------------------------------
 if(grim_test_single_channel(grim_data)) then $
   image = grim_image(grim_data, plane=plane, current=current, xrange=xrange, yrange=yrange) $

 ;------------------------------------------------------------------
 ; otherwise display according to current channel settings 
 ;------------------------------------------------------------------
 else $
  begin
   ctmod, visual=visual

   red = grim_image(grim_data, channel=0, current=current, xrange=xrange, yrange=yrange)
   grn = grim_image(grim_data, channel=1, current=current, xrange=xrange, yrange=yrange)
   blu = grim_image(grim_data, channel=2, current=current, xrange=xrange, yrange=yrange)     

   ;---------------------------------------
   ; pseudo-color (8-bit) display
   ;---------------------------------------
   if(visual EQ 8) then $
    begin
     image = color_quan(red, grn, blu, r, g, b)
     tvlct, r, g, b
     no_scale = 1
    end $
   ;---------------------------------------
   ; otherwise assume decomposed colors
   ;---------------------------------------
   else $
    begin
     sr = size(red, /dim)
     if(NOT keyword_set(red)) then sr = [0l,0l]
     sg = size(grn, /dim)
     if(NOT keyword_set(grn)) then sg = [0l,0l]
     sb = size(blu, /dim)
     if(NOT keyword_set(blu)) then sb = [0l,0l]
     
     xs = max([sr[0], sg[0], sb[0]])
     ys = max([sr[1], sg[1], sb[1]])

     if(xs EQ 0) then return, 0

     image = dblarr(xs, ys, 3)
     if(keyword_set(red)) then image[0:sr[0]-1,0:sr[1]-1,0] = red
     if(keyword_set(grn)) then image[0:sg[0]-1,0:sg[1]-1,1] = grn
     if(keyword_set(blu)) then image[0:sb[0]-1,0:sb[1]-1,2] = blu
    end

  end


 ctmod, top=top
 tvlct, r, g, b, /get

 return, image
end
;=============================================================================



;=============================================================================
; grim_display_image
;
;=============================================================================
pro grim_display_image, grim_data, plane=plane, $
       entire=entire, wnum=wnum, doffset=doffset, zoom=zoom, rotate=rotate, order=order, $
       default=default, previous=previous, flip=flip, restore=restore, $
       xsize=xsize, ysize=ysize, offset=offset, top=top, noplot=no_plot, $
       no_scale=no_scale, no_wset=no_wset, no_coord=no_coord, tvimage=tvimage, $
       home=home, draw_pixmap=draw_pixmap, current=current, no_copy=no_copy


 dim = dat_dim(plane.dd)

 ;-------------------------------
 ; set tvim coordinate system
 ;-------------------------------
 if(keyword_set(entire)) then $
  begin 
   wset, wnum
   entire_xsize = double(!d.x_size)
   entire_ysize = double(!d.y_size)
   wset, grim_data.wnum

   zoom = min([entire_xsize/dim[0], entire_ysize/dim[1]]) * 0.95
   offset = 0.5 * [dim[0]-entire_xsize/zoom, $
                     dim[1]-entire_ysize/zoom]
  end

 integer_zoom = grim_get_toggle_flag(grim_data, 'INTEGER_ZOOM')

 tvim, wnum, /silent, doffset=doffset, zoom=zoom, rotate=rotate, order=order, $
       default=default, previous=previous, flip=flip, restore=restore, $
       xsize=xsize, ysize=ysize, offset=offset, top=top, noplot=no_plot, $
       no_scale=no_scale, no_wset=no_wset, no_coord=no_coord, tvimage=tvimage, $
       home=home, draw_pixmap=draw_pixmap, no_copy=no_copy, integer_zoom=integer_zoom;, erase=erase

 if(NOT plane.image_visible) then return


 ;---------------------------------------------------------------------------
 ; if first time, compute a scaled image to get the data loaded so that
 ; the data ranges will be known.
 ;---------------------------------------------------------------------------
 if(NOT plane.prescaled) then $
  begin
   tvimage = grim_scale_image(grim_data, r, g, b, current=current, $
                                      plane=plane, no_scale=no_scale, top=top)
   plane.prescaled = 1
  end

 ;---------------------------------
 ; scale image for real
 ;---------------------------------
 tvimage = grim_scale_image(grim_data, r, g, b, current=current, $
                                      plane=plane, no_scale=no_scale, top=top)
 if(NOT keyword_set(tvimage)) then $
  begin
   erase
   return
  end

 *grim_data.tv_rp = r
 *grim_data.tv_gp = g
 *grim_data.tv_bp = b
 grim_set_data, grim_data, grim_data.base

 s = size(tvimage)
 image_xsize = s[1]
 image_ysize = s[2]


 if(((where(r-g NE 0))[0] NE -1) OR ((where(g-b NE 0))[0] NE -1)) then $
  begin
   _tvimage = dblarr(image_xsize, image_ysize, 3)
   _tvimage[*,*,0] = apply_colormap(tvimage, r)
   _tvimage[*,*,1] = apply_colormap(tvimage, g)
   _tvimage[*,*,2] = apply_colormap(tvimage, b)
   tvimage = _tvimage
   _tvimage = 0   
  end


 ;---------------------
 ; display image
 ;---------------------
 if(wnum EQ grim_data.wnum) then draw_pixmap = grim_data.redraw_pixmap

 tvim, tvimage, /tvimage, /silent, wnum, noplot=no_plot, $
     draw_pixmap=draw_pixmap, no_copy=no_copy, $
     no_scale=no_scale

 min = (max = 0)

 if(keyword_set(tvimage)) then $
  begin
   if(NOT defined(min)) then min = min(tvimage)
   if(NOT defined(max)) then max = max(tvimage)
  end

 *grim_data.min_p = min
 *grim_data.max_p = max


end
;=============================================================================



;=============================================================================
; grim_display_plot
;
;=============================================================================
pro grim_display_plot, grim_data, plane=plane, doffset=doffset, $
       wnum=wnum, xrange=xrange, yrange=yrange, no_wset=no_wset, $
       default=default, previous=previous, flip=flip, restore=restore, $
       xsize=xsize, ysize=ysize, position=position, dx=dx, dy=dy, $
       entire=entire, erase=erase, no_coord=no_coord, $
       color=color, nodraw=nodraw, current=current

 planes = grim_visible_planes(grim_data, current=current, plane=plane)
 nplanes = n_elements(planes)

 for i=0, nplanes-1 do $
  begin
   ;---------------------------------------
   ; set view unless forced
   ;---------------------------------------
   if((NOT keyword_set(default)) $
       AND (NOT keyword_set(previous)) $
       AND (NOT keyword_set(flip)) $
       AND (NOT keyword_set(restore)) ) then $
    begin
     tvgr, grim_data.wnum, get=tvd

     if(NOT keyword_set(xrange)) then $
       if((plane.xrange[0] NE 0) OR (plane.xrange[1] NE 0)) then xrange = plane.xrange $
     else xrange = [dat_min(plane.dd, /ab), dat_max(plane.dd, /ab)]

     if(NOT keyword_set(yrange)) then $
       if((plane.yrange[0] NE 0) OR (plane.yrange[1] NE 0)) then yrange = plane.yrange $
     else yrange = [dat_min(plane.dd), dat_max(plane.dd)]

     if(NOT keyword_set(position)) then $
       if((planes[i].position[0] NE 0) OR (planes[i].position[1] NE 0)) then position = planes[i].position $
     else if((tvd.position[0] NE 0) OR (tvd.position[1] NE 0)) then position = tvd.position
    end

   parm = planes[i].parm


   ;-----------------------------------------------------------------------
   ; if /entire, set ranges so that entire image is displayed
   ;-----------------------------------------------------------------------
   if(keyword_set(entire)) then $
    begin 
     xrange = [dat_min(plane.dd, /ab), dat_max(plane.dd, /ab)]
     yrange = [dat_min(plane.dd), dat_max(plane.dd)]
    end


   ;---------------------
   ; set color
   ;---------------------
   if(NOT keyword_set(no_color)) then $
    begin
     color = parm.color
;stop
;     if(keyword_set(plane.override_color) $
;               AND (strupcase(plane.override_color) NE 'NONE')) then $
;                                                   color = plane.override_color

    end

   if(keyword_set(doffset)) then $
    begin
     dx = doffset[0]
     dy = doffset[1]
    end


   ;---------------------------------------
   ; set view
   ;---------------------------------------
; need to sample here instead of getting entire array...
   if(i GT 0) then erase = 0
   tvgr, wnum, 0, 0, xrange=xrange, yrange=yrange, no_wset=no_wset, $
       default=default, previous=previous, flip=flip, restore=restore, $
       xsize=xsize, ysize=ysize, position=position, dx=dx, dy=dy, $
       entire=entire, erase=erase, no_coord=no_coord, $
       xtitle=plane.xtitle, ytitle=plane.ytitle, $
       title=plane.title, thick=parm.thick, nsum=parm.nsum


   ;---------------------------------------
   ; get data array
   ;---------------------------------------

   ;- - - - - - - - - - - - - - - - - - - - 
   ; sampling
   ;- - - - - - - - - - - - - - - - - - - - 
   xdev = lindgen(1,!d.x_size)
   nx = n_elements(xdev)
   axis = [xdev, make_array(1,nx, val=0)]
   xdat = transpose((convert_coord(/device, /to_data, axis))[0,*])

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; This causes the full array to be read rather than just the 
   ; samples needed to display it in the current view...
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   yarr = dat_data(planes[i].dd, abscissa=xarr)
   w = where((xdat GE min(xarr)) AND (xdat LE max(xarr)))
   if(w[0] NE -1) then $
    begin
     xdat = xdat[w]

     ydat = interpol(yarr, xarr, xdat)

     ;---------------------
     ; display plot(s)
     ;---------------------
     tvgr, wnum, xdat, ydat
    end
  end

 ;----------------------------
 ; save view
 ;----------------------------
 tvgr, grim_data.wnum, get=tvd
 plane.xrange = tvd.xrange
 plane.yrange = tvd.yrange

 ;-----------------------------------
 ; bind xranges of all planes
 ;-----------------------------------
 all_planes = grim_get_plane(grim_data, /all, pn=pn)
 nall = n_elements(all_planes)
 for i=0, nall-1 do if(pn[i] NE plane.pn) then $ 
  begin
   all_planes[i].xrange = plane.xrange
   grim_set_plane, grim_data, all_planes[i], pn=pn[i]
  end


 plane.position = tvd.position
 grim_set_plane, grim_data, plane, pn=plane.pn

end
;=============================================================================



;=============================================================================
; grim_display
;
;=============================================================================
pro grim_display, grim_data, plane=plane, wnum=wnum, home=home, $
       no_image=no_image, no_axes=no_axes, doffset=doffset, no_erase=no_erase, $
       zoom=zoom, rotate=rotate, order=order, xsize=xsize, ysize=ysize, offset=offset, $
       default=default, previous=previous, flip=flip, restore=restore,$
       use_pixmap=use_pixmap, pixmap_box_center=pixmap_box_center, no_copy=no_copy, $
       pixmap_box_side=pixmap_box_side, no_back=no_back, entire=entire, $
       no_wset=no_wset, no_coord=no_coord, tvimage=tvimage, no_plot=no_plot, $
       nodraw=nodraw, xrange=xrange, yrange=yrange, dx=dx, dy=dy, current=current, $
       pixmap_to_use=pixmap_to_use

 erase = 1
 if(keyword_set(no_erase)) then erase = 0
 no_scale = 1


 if(NOT keyword_set(pixmap_to_use)) then pixmap_to_use = grim_data.pixmap

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 if(NOT keyword_set(wnum)) then wnum = grim_data.wnum


 ;------------------------------------------------------
 ; if image display is off then just erase
 ;------------------------------------------------------
;;;; also need to do view settings; /entire, etc..
; if(NOT plane.image_visible) then $
;  begin
;   erase 
;   return
;  end
 if(NOT plane.image_visible) then erase


 ;------------------------------------------------------------
 ; if /use_pixmap then just copy from stored image
 ;------------------------------------------------------------
 if(keyword_set(use_pixmap)) then $
  begin
   if(plane.image_visible) then $
    begin
     x0 = 0 & y0 = 0
     xsize = !d.x_size-1 
     ysize = !d.y_size-1

     if(keyword_set(pixmap_box_center)) then $
      begin 
       x0 = (pixmap_box_center[0] - pixmap_box_side/2) > 0
       y0 = (pixmap_box_center[1] - pixmap_box_side/2) > 0
       xsize = pixmap_box_side < $
  		      abs(xsize - pixmap_box_center[0] + pixmap_box_side/2)
       ysize = pixmap_box_side < $
  		      abs(ysize - pixmap_box_center[1] + pixmap_box_side/2)
      end

     wset, wnum
     if((x0 GE 0) AND (x0 LT !d.x_size) AND $
        (y0 GE 0) AND (y0 LT !d.y_size) AND $
        (xsize GT 0) AND (ysize GT 0)) then $
 	     device, copy=[x0,y0, xsize,ysize, x0,y0, pixmap_to_use]  
    end 
  end $

 ;------------------------------------------------------
 ; otherwise generate a new image
 ;------------------------------------------------------
 else $
  begin
   if(grim_data.type NE 'PLOT') then $
     grim_display_image, grim_data, plane=plane, no_copy=no_copy, $
       entire=entire, wnum=wnum, doffset=doffset, zoom=zoom, rotate=rotate, order=order, $
       default=default, previous=previous, flip=flip, restore=restore, $
       xsize=xsize, ysize=ysize, offset=offset, top=top, noplot=no_plot, $
       no_scale=no_scale, no_wset=no_wset, no_coord=no_coord, tvimage=tvimage, $
       home=home, draw_pixmap=draw_pixmap, current=current $

   else grim_display_plot, grim_data, plane=plane, doffset=doffset, $
       wnum=wnum, xrange=xrange, yrange=yrange, no_wset=no_wset, $
       default=default, previous=previous, flip=flip, restore=restore, $
       xsize=xsize, ysize=ysize, position=position, dx=dx, dy=dy, current=current, $
       entire=entire, erase=erase, no_coord=no_coord, color=color, nodraw=nodraw
  end


 ;-------------------------------------
 ; copy to backing pixmap
 ;-------------------------------------
 if(plane.image_visible) then $
  if(NOT keyword_set(no_back)) then $
   begin
    wnum = !d.window
    wset, pixmap_to_use
    device, copy=[0,0, !d.x_size-1,!d.y_size-1, 0,0, wnum]
    wset, wnum
   end


end
;=============================================================================



;=============================================================================
; grim_show_context_image
;
;=============================================================================
pro grim_show_context_image, grim_data

 wset, grim_data.context_wnum
 device, copy=[0,0, !d.x_size-1,!d.y_size-1, 0,0, grim_data.context_pixmap]
 wset, grim_data.wnum

end
;=============================================================================



;=============================================================================
; grim_show_axes
;
;  inertial axes:	blue
;  light direction:	yellow
;  camera axes:		red
;  dir. to primary:	green
;
;  Axis source is just in front of the camera.
;
;=============================================================================
pro grim_show_axes, grim_data, plane
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 widget_control, grim_data.axes_base, xoff=0, yoff=!d.y_size-AXES_SIZE

 ;---------------------------------
 ; clear axes window
 ;---------------------------------
 wnum = !d.window
 if(wnum EQ -1) then return

 wset, grim_data.axes_wnum
 erase
 wset, wnum

 ;---------------------------------
 ; draw axis vectors
 ;---------------------------------
 cd = grim_xd(plane, /cd)
 ltd = grim_xd(plane, /ltd)
 pd = get_primary(cd, grim_xd(plane, /pd))
 if(NOT grim_test_map(grim_data)) then $
  if(grim_data.axes_flag) then $
   if(keyword_set(cd)) then $ 
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; compute source location
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     device_pt = [AXES_SIZE/2, AXES_SIZE/2]
     image_pt = (convert_coord(device_pt[0], device_pt[1], /device, /to_data))[0:1]

     dir = image_to_inertial(cd, image_pt)
     source = bod_pos(cd) + dir*100000d 

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; compute length in data units
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     device_len = AXES_SIZE/3
     device_corners = [tr([0,0]), tr([!d.x_size-1,0])]
     image_corners = (convert_coord(device_corners[0,*], device_corners[1,*], $
                                                    /device, /to_data))[0:1,*]
     len = device_len * p_mag(image_corners[*,0]-image_corners[*,1])/!d.x_size

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; draw inertial axes
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     pg_draw_vector, cd=cd, source, (bod_orient(bod_inertial())), $
         plab=['x','y','z'], col='blue', len=len, draw_wnum=grim_data.axes_wnum, $
         label_shade=0.75

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; draw camera axes
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     pg_draw_vector, cd=cd, source, (bod_orient(cd)), $
         plab=['cx','cy','cz'], col='red', len=len, draw_wnum=grim_data.axes_wnum, $
         label_shade=0.75

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; draw primary light vector
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(keyword_set(ltd)) then $
       pg_draw_vector, cd=cd, source, /noshort, /fix, $
         v_unit(bod_pos(ltd[0]) - bod_pos(cd)), $
         plab=['LIGHT'], col='yellow', len=len, draw_wnum=grim_data.axes_wnum, $
         label_shade=0.75

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; draw primary planet vector
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(keyword_set(pd)) then $
      begin
       pg_draw_vector, cd=cd, source, /noshort, /fix, $
         v_unit(bod_pos(pd) - bod_pos(cd)), $
         plab=cor_name(pd), col='green', len=len, draw_wnum=grim_data.axes_wnum, $
         label_shade=0.75
      end
    end

 ;----------------------------
 ; axes window outline
 ;----------------------------
 wset, grim_data.axes_wnum
 plots, /device, col=ctblue(), $
     [0,!d.x_size-1,!d.x_size-1,0,0], [0,0,!d.y_size-1,!d.y_size-1,0], th=4
 grim_wset, grim_data, grim_data.wnum

end
;=============================================================================



;=============================================================================
; grim_add_refresh_callback
;
;=============================================================================
pro grim_add_refresh_callback, callbacks, data_ps, top=top, no_wset=no_wset

 grim_data = grim_get_data(top, no_wset=no_wset)

 rf_callbacks = *grim_data.rf_callbacks_p
 rf_data_ps = *grim_data.rf_callbacks_data_pp

 grim_add_callback, callbacks, data_ps, rf_callbacks, rf_data_ps

 *grim_data.rf_callbacks_p = rf_callbacks
 *grim_data.rf_callbacks_data_pp = rf_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_rm_refresh_callback
;
;=============================================================================
pro grim_rm_refresh_callback, data_ps, top=top

 grim_data = grim_get_data(top)
 if(NOT grim_exists(grim_data)) then return

 rf_callbacks = *grim_data.rf_callbacks_p
 rf_data_ps = *grim_data.rf_callbacks_data_pp

 grim_rm_callback, data_ps, rf_callbacks, rf_data_ps

 *grim_data.rf_callbacks_p = rf_callbacks
 *grim_data.rf_callbacks_data_pp = rf_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_call_refresh_callbacks
;
;=============================================================================
pro grim_call_refresh_callbacks, grim_data

 grim_call_callbacks, *grim_data.rf_callbacks_p, *grim_data.rf_callbacks_data_pp

end
;=============================================================================



;=============================================================================
; grim_title
;
;=============================================================================
function grim_title, plane, primary=primary

 if(NOT keyword_set(plane)) then $
  begin
   grim_data = grim_get_data(primary=primary)
   plane = grim_get_plane(grim_data)
  end

 return, cor_name(plane.dd)
end
;=============================================================================



;=============================================================================
; grim_channel_string
;
;=============================================================================
function grim_channel_string, plane

 c = ['R', 'G', 'B']
 w = where(plane.rgb)
 c = c[w]

 return, str_comma_list(c, delim='+')
end
;=============================================================================



;=============================================================================
; grim_update_menu_sensitvity
;
;=============================================================================
pro grim_update_menu_sensitvity, grim_data, plane=plane

 menu_ids = *grim_data.menu_ids_p
 menu_desc = *grim_data.menu_desc_p
 if(grim_test_map(grim_data, plane=plane)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - -
   ; allowed menu items
   ;- - - - - - - - - - - - - - - - - - - - -
   md_items = *grim_data.map_items_p
   if(keyword_set(grim_xd(plane, /od))) then $
       md_items = append_array(md_items, *grim_data.od_map_items_p)
   mark = bytarr(n_elements(menu_ids))

   n = n_elements(md_items)
   for i=0, n-1 do $
    begin
     w = where(strpos(menu_desc, md_items[i]) NE -1)
     if(w[0] NE -1) then $
      begin
       widget_control, menu_ids[w[0]], sensitive=1
       mark[w[0]] = 1
      end
    end

   w = where(mark EQ 0)
   if(w[0] NE -1) then for i=0, n_elements(w)-1 do $
               widget_control, menu_ids[w[i]], sensitive=0
  end $
 else $
  begin
   n = n_elements(menu_ids)
   for i=0, n-1 do widget_control, menu_ids[i], sensitive=1
  end


end
;=============================================================================



;=============================================================================
; grim_update_jumpto_droplist
;
;=============================================================================
pro grim_update_jumpto_droplist, grim_data, names=names, max_planes=max_planes
if(NOT keyword_set(grim_data.jumpto_droplist)) then return

 if(NOT keyword_set(max_planes)) then max_planes = 50

 pns = lindgen(grim_data.n_planes)
 if(grim_data.n_planes GT max_planes) then $
  begin
   pns = lindgen(max_planes) + grim_data.pn - max_planes/2
   if(pns[0] LT 0) then pns = pns - pns[0] $
   else if(pns[max_planes-1] GE grim_data.n_planes) then $
           pns = pns - (pns[max_planes-1] - grim_data.n_planes)
  end

 val = strtrim(pns, 2)
 if(keyword_set(names)) then $
  begin
   planes = grim_get_plane(grim_data, pn=pns)
   val = str_pad(val + ': ', 5) + cor_name(planes.dd)
  end

 widget_control, grim_data.jumpto_droplist, set_value=val
 widget_control, grim_data.jumpto_droplist, $
                              set_droplist_select=where(val EQ grim_data.pn)

end
;=============================================================================



;=============================================================================
; grim_update_jumpto_combobox
;
;=============================================================================
pro grim_update_jumpto_combobox, grim_data, names=names, max_planes=max_planes
if(NOT keyword_set(grim_data.jumpto_combobox)) then return

 if(NOT keyword_set(max_planes)) then max_planes = 50

 pns = lindgen(grim_data.n_planes)

 val = strtrim(pns, 2)
 if(keyword_set(names)) then $
  begin
   planes = grim_get_plane(grim_data, pn=pns)
   val = str_pad(val + ': ', 5) + cor_name(planes.dd)
  end

 widget_control, grim_data.jumpto_combobox, set_value=val
 widget_control, grim_data.jumpto_combobox, $
                              set_combobox_select=where(val EQ grim_data.pn)

end
;=============================================================================



;=============================================================================
; grim_refresh
;
;=============================================================================
pro grim_refresh, grim_data, wnum=wnum, plane=plane, $
 no_image=no_image, no_objects=no_objects, no_axes=no_axes, no_grid=no_grid, $
 no_title=no_title, home=home, xrange=xrange, yrange=yrange, $
 doffset=doffset, no_erase=no_erase, zoom=zoom, rotate=rotate, order=order, $
 default=default, previous=previous, flip=flip, restore=restore, $
 xsize=xsize, ysize=ysize, offset=offset, use_pixmap=use_pixmap, $
 pixmap_box_center=pixmap_box_center, pixmap_box_side=pixmap_box_side, $
 context=context, entire=entire, noglass=noglass, no_wset=no_wset, $
 no_context=no_context, no_callback=no_callback, no_back=no_back, $
 no_coord=no_coord, tvimage=tvimage, no_plot=no_plot, just_image=just_image, $
 dx=dx, dy=dy, update=update, current=current, no_copy=no_copy, no_main=no_main, $
 no_user=no_user, overlay_color=overlay_color, disable=disable, enable=enable
@grim_block.include


 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane) 

 if(keyword_set(disable)) then $
  begin
   grim_data.enable_refresh = 0
   grim_set_data, grim_data
   return
  end
 if(keyword_set(enable)) then $
  begin
   grim_data.enable_refresh = 1
   grim_set_data, grim_data
   return
  end
 if(NOT grim_data.enable_refresh) then return


 if(NOT keyword_set(noglass)) then widget_control, grim_data.draw, /hourglass
 if(NOT keyword_set(no_wset)) then grim_wset, grim_data, grim_data.wnum


 grim_data.guideline_save_xy = [-1,-1]

 if(NOT keyword_set(plane)) then $
  begin
   plane = grim_get_plane(grim_data)
   planes = grim_get_visible_planes(grim_data)
  end $
 else planes = plane
 all_planes = grim_get_plane(grim_data, /all)

 ;-----------------------------------
 ; apply any default activations
 ;-----------------------------------
; grim_default_activations, grim_data, plane=plane


 ;-----------------------------------
 ; redraw main image
 ;-----------------------------------
 if(NOT keyword_set(no_image)) then $
  if(NOT keyword_set(no_main)) then $
   begin
    grim_display, grim_data, wnum=wnum, plane=plane, xrange=xrange, yrange=yrange, $
         no_axes=no_axes, doffset=doffset, no_wset=no_wset, no_back=no_back, $
         no_erase=no_erase, zoom=zoom, rotate=rotate, order=order, entire=entire, $
         default=default, previous=previous, flip=flip, restore=restore, $
         xsize=xsize, ysize=ysize, offset=offset, use_pixmap=use_pixmap, $
         pixmap_box_center=pixmap_box_center, pixmap_box_side=pixmap_box_side, $
         no_coord=no_coord, tvimage=tvimage, no_plot=no_plot, home=home, $
         dx=dx, dy=dy, current=current, no_copy=no_copy
   end


 ;-----------------------------------
 ; redraw context image
 ;-----------------------------------
 if(NOT keyword_set(no_context)) then $
  if(NOT keyword_set(no_image)) then $
   if(grim_data.context_mapped) then $
    begin
     tvim, grim_data.wnum, get=tvd, /no_coord

     grim_display, grim_data, wnum=grim_data.context_pixmap, plane=plane, $
;           use_pixmap=use_pixmap, pixmap_to_use=grim_data.context_pixmap, $
           /entire, order=tvd.order, nodraw=nodraw, /no_back

     grim_display, grim_data, wnum=grim_data.context_wnum, plane=plane, $
           /entire, order=tvd.order, /no_back, /no_image, /no_erase, nodraw=nodraw
     grim_wset, grim_data, grim_data.wnum
    end


 ;-----------------------------------
 ; compute any intial overlays
 ;-----------------------------------
 grim_initial_overlays, grim_data, plane=planes


 ;------------------------------------
 ; redisplay viewport overlays
 ;------------------------------------
 if(NOT keyword_set(no_grid)) then $
       if(NOT grim_data.hidden) then $
           grim_draw_vp_overlays, grim_data, plane=plane, no_wset=no_wset


 ;------------------------------------
 ; redisplay grids
 ;------------------------------------
 if(NOT keyword_set(no_axes)) then $
       if(NOT grim_data.hidden) then $
           grim_draw_grids, grim_data, plane=plane, no_wset=no_wset


 ;-----------------------------------
 ; redraw overlays
 ;-----------------------------------
 if(NOT keyword_set(no_objects)) then $
          grim_draw, grim_data, plane=planes, /all, $
                 update=update, no_user=no_user, override_color=overlay_color


 ;------------------------------------
 ; redisplay axes
 ;------------------------------------
 if(NOT keyword_set(no_axes)) then $
       if(NOT grim_data.hidden) then $
	   grim_draw_axes, grim_data, data, plane=plane, $
				   no_context=no_context, no_wset=no_wset


 ;------------------------------------------
 ; copy context image to screen if mapped
 ;------------------------------------------
 if(NOT keyword_set(no_context)) then $
        if(grim_data.context_mapped) then grim_show_context_image, grim_data


 ;-----------------------------------
 ; set base title
 ;-----------------------------------
 if(NOT keyword_set(no_title)) then $
  begin
   beta = ''
   if(grim_data.beta) then beta = ' (beta)'
   tag = ''
   if(keyword_set(grim_data.tag)) then tag = ' "' + grim_data.tag + '"'
   title = 'GRIM' + beta + ' ' + strtrim(grim_data.grn,2) + tag + ';  ' + $
           strtrim(grim_data.n_planes,2) + ' plane' + $
           (grim_data.n_planes GT 1 ? 's' : '') + $
           ';  ' + grim_title(plane)
    if(keyword_set(grim_data.def_title)) then title = title + ' -- ' + grim_data.def_title
    
    title = title + ' <' + grim_channel_string(plane) + '>'

   widget_control, grim_data.base,  tlb_set_title = title
  end


 ;-----------------------------------
 ; update plane number droplist
 ;-----------------------------------
 grim_update_jumpto_droplist, grim_data
 grim_update_jumpto_combobox, grim_data


 ;-----------------------------------
 ; update menu item sensitivity
 ;-----------------------------------
 grim_update_menu, grim_data
 grim_update_menu_sensitvity, grim_data, plane=plane


 ;-----------------------------------
 ; update undo/redo sensitivity
 ;-----------------------------------
 nhist = dat_nhist(plane.dd)
 sens = nhist GT 1
 widget_control, grim_data.undo_button, sensitive=sens
 widget_control, grim_data.undo_menu_id, sensitive=sens
 widget_control, grim_data.redo_button, sensitive=sens
 widget_control, grim_data.redo_menu_id, sensitive=sens


 ;-----------------------------------
 ; update render button
 ;-----------------------------------
 if(grim_data.type NE 'PLOT') then $
  if(NOT grim_test_map(grim_data)) then $
   begin
    bm = grim_render_bitmap()
    if(plane.rendering) then bm = grim_unrender_bitmap()
    widget_control, grim_data.render_button, set_value=bm
   end

 ;-----------------------------------
 ; update active and primary arrays
 ;-----------------------------------
 grim_update_activations, grim_data, plane=plane, /no_sync


 ;-----------------------------------
 ; cull descriptors
 ;-----------------------------------
; grim_cull_descriptors, grim_data


 ;-----------------------------------
 ; update header window
 ;-----------------------------------
 if(widget_info(grim_data.header_text, /valid)) then $
  begin
   widget_control, grim_data.header_text, set_value=dat_header(plane.dd)
   widget_control, grim_data.header_base, tlb_set_title=grim_title(plane)
  end


 ;-----------------------------------
 ; update notes window
 ;-----------------------------------
 if(widget_info(grim_data.notes_text, /valid)) then $
  begin
   widget_control, grim_data.notes_text, set_value=*plane.notes_p
   widget_control, grim_data.notes_base, tlb_set_title=grim_title(plane)
  end

 
 ;-----------------------------------
 ; update _all_tops list
 ;-----------------------------------
 w = -1
 if(keyword_set(_all_tops)) then w = where(_all_tops EQ grim_data.base)
 if(w[0] EQ -1) then _all_tops = append_array(_all_tops, grim_data.base)


 ;-----------------------------------
 ; contact refresh callbacks
 ;-----------------------------------
 if(NOT keyword_set(no_callback)) then $
  begin
   grim_call_refresh_callbacks, grim_data
   grim_call_primary_callbacks
  end

 grim_wset, grim_data, grim_data.wnum

; nv_flush
end
;=============================================================================

pro grim_image_include
a=!null
end

