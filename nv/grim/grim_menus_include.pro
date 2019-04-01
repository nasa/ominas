;=============================================================================
; grim_test_motion_event
;
;=============================================================================
function grim_test_motion_event, event

 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then return, 1

 if(struct EQ 'WIDGET_DRAW') then if(event.type EQ 2) then return, 1

 return, 0
end
;=============================================================================



;=============================================================================
; grim_write_ps
;
;=============================================================================
pro grim_write_ps, grim_data, filename

 xoff = 0.5
 yoff = 2.0
 bits_per_pixel = 8

 ;--------------------------------------------------------------
 ; set coord. sys and get clipped, scaled image
 ;--------------------------------------------------------------
 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 grim_refresh, grim_data, tvimage=_tvimage, /no_back, /no_context, /no_callback

 ;--------------------------------------------------------------
 ; find device coords of image corners
 ;--------------------------------------------------------------
 s = size(grim_image(grim_data, plane=plane))
 xsize = s[1]
 ysize = s[2]

 p = fix(convert_coord(0d,0d, /data, /to_device, /double))
 q = fix(convert_coord(double(xsize-1),double(ysize-1), /data, /to_device)) - 1

 x0 = min([p[0], q[0]])
 x1 = max([p[0], q[0]])
 y0 = min([p[1], q[1]])
 y1 = max([p[1], q[1]])

 if(tvd.order) then $
  begin
   yy0 = y0
   yy1 = y1
   y0 = !d.y_size-1 - yy1
   y1 = !d.y_size-1 - yy0
  end

 x0 = x0 > 0
 x1 = x1 < !d.x_size-1
 y0 = y0 > 0
 y1 = y1 < !d.y_size-1

 ;--------------------------------------------------------------
 ; trim image, allowing a bit of safety
 ;--------------------------------------------------------------
 xs = x1-x0-2
 ys = y1-y0-2
 _tvimage = _tvimage[0:xs, 0:ys]

 x1 = x0 + xs
 y1 = y0 + ys

 ;--------------------------------------------------------------
 ; insert into image to plot
 ;--------------------------------------------------------------
 type = size(_tvimage, /type)
 tvimage = make_array(!d.x_size, !d.y_size, type=type)
 tvimage[x0:x1, y0:y1] = _tvimage

 ;--------------------------------------------------------------
 ; determine aspect ratio --
 ;  Currently, the overlays are not properly drawn if any edge
 ;  of the image is visible in the graphics window.
 ;--------------------------------------------------------------
 aspect = double(!d.x_size)/double(!d.y_size)
 if(aspect GE 1.0) then $
  begin
   xsize = 7.5
   ysize = xsize / aspect
  end $
 else $
  begin
   ysize = 7.5
   xsize = ysize * aspect
  end

 ;--------------------------------------------------------------
 ; Without this step, the overlays may be drawn incorrectly
 ; the first time in a session.  I don't know why.
 ;--------------------------------------------------------------
; set_plot, 'PS'
; device, /color, filename=filename, bits_per_pixel=bits_per_pixel, $
;         xsize=xsize, ysize=ysize, /inches, xoffset=xoff, yoffset=yoff
; device, /close
; set_plot, 'X'


 ;--------------------------------------------------------------
 ; write the PS file 
 ;--------------------------------------------------------------
 set_plot, 'PS'
 device, /color, filename=filename, bits_per_pixel=bits_per_pixel, $
         xsize=xsize, ysize=ysize, /inches, xoffset=xoff, yoffset=yoff

 ctmod, top=top
 tv, tvimage, order=tvd.order, top=top
 grim_refresh, grim_data, tvimage=tvimage, $
           /no_image, /no_callback, /no_wset, /no_coord, /no_context, /no_back

 device, /close
 set_plot, 'X'

end
;=============================================================================



;=============================================================================
; grim_write
;
;=============================================================================
pro grim_write, grim_data, filename, filetype=filetype

 widget_control, /hourglass
 plane = grim_get_plane(grim_data)

 if(NOT keyword_set(filename)) then return

 split_filename, filename, dir, name
 if(NOT keyword_set(name)) then return

 ;---------------------------------------------
 ; prompt before overwriting existing file
 ;---------------------------------------------
 ff = file_search(filename)
 if(keyword_set(ff)) then $
  begin
   ans = dialog_message('Overwrite ' + filename + '?', /question)
   if(ans NE 'Yes') then return
  end


 grim_suspend_events

 ;---------------------------------------------
 ; output descriptors
 ;---------------------------------------------
 cd = grim_xd(plane, /cd)
 pd = grim_xd(plane, /pd)
 rd = grim_xd(plane, /rd)
 sd = grim_xd(plane, /sd)
 ltd = grim_xd(plane, /ltd)
 std = grim_xd(plane, /std)
 ard = grim_xd(plane, /ard)

 if(keyword_set(cd)) then $
  case grim_test_map(grim_data) of
    0 : $
	begin
	 pg_put_cameras, plane.dd, cd=cd
	 od = cd
	end
    1 : $
	begin
	 pg_put_maps, plane.dd, md=cd
	 od = grim_xd(plane, /od)
	end
  endcase

 if(keyword_set(pd)) then pg_put_planets, plane.dd, pd=pd, od=od
 if(keyword_set(rd)) then pg_put_rings, plane.dd, rd=rd, od=od
 if(keyword_set(sd)) then pg_put_stars, plane.dd, sd=sd, od=od
; if(keyword_set(std)) then pg_put_stations, plane.dd, std=std, od=od ;no such function
 if(keyword_set(ard)) then pg_put_arrays, plane.dd, ard=ard, od=od
 if(keyword_set(ltd)) then pg_put_stars, plane.dd, sd=ltd, od=od

 grim_resume_events

 ;---------------------------------------------
 ; write data
 ;---------------------------------------------
 dat_write, filename, plane.dd, filetype=filetype

end
;=============================================================================



;=============================================================================
; grim_get_save_filename
;
;=============================================================================
function grim_get_save_filename, grim_data, filetype=filetype

 plane = grim_get_plane(grim_data)
 name = dat_filename(plane.dd)
 split_filename, name, dir, _name

 if(keyword_set(plane.save_path)) then path = plane.save_path
 if(NOT keyword_set(path)) then path = dir
 if(NOT keyword_set(path)) then path = './'


 types = strupcase(dat_detect_filetype(/all))
 w = where(strupcase(dat_filetype(plane.dd)) EQ types)

 if(w[0] NE -1) then $
   types = [types[w[0]], rm_list_item(types, w[0], only='')]

 filename = pickfiles(/one, get_path=get_path, $
               title='Select filename for saving', path=path, default=name, $
               options=['Filetype:',types], sel=filetype)

 return, filename
end
;=============================================================================



;=============================================================================
; grim_load_files
;
;=============================================================================
pro grim_load_files, grim_data, filenames, load_path=load_path, norefresh=norefresh

 plane = grim_get_plane(grim_data)
 filter = plane.filter

 ;------------------------------------
 ; load each file onto a new plane
 ;------------------------------------
 dd = dat_read(filenames, nhist=grim_data.nhist, $
            maintain=grim_data.maintain, compress=grim_data.compress, extensions=grim_data.extensions)
 if(NOT keyword_set(dd)) then return

 grim_add_planes, grim_data, dd, pn=pn, filter=filter
 grim_data.pn = pn[0]
 plane = grim_get_plane(grim_data, pn=pn)
 plane.load_path = load_path
 grim_set_plane, grim_data, plane, pn=pn

 nv_notify_register, dd, 'grim_descriptor_notify', scalar_data=grim_data.base

 grim_set_data, grim_data, grim_data.base


 ;------------------------------------
 ; set initial zoom and display image
 ;------------------------------------
 dim = dat_dim(dd[0])
 geom = widget_info(grim_data.draw, /geom)

 zoom = double(geom.xsize) / double(dim[0])
 offset = [0d,0d]

 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 if(NOT keyword_set(norefresh)) then $
         grim_refresh, grim_data, zoom=zoom, offset=offset, order=tvd.order
 grim_wset, grim_data, /save

end
;=============================================================================



;=============================================================================
; grim_deactivate_all
;
;=============================================================================
pro grim_deactivate_all, grim_data, plane

 grim_activate_all_overlays, grim_data, plane, /deactivate

end
;=============================================================================



;=============================================================================
; grim_activate_all
;
;=============================================================================
pro grim_activate_all, grim_data, plane

 grim_activate_all_overlays, grim_data, plane

end
;=============================================================================



;=============================================================================
; grim_modify_colors
;
;=============================================================================
pro grim_modify_colors, grim_data

 ctmod, top=top
 gr_colortool

end
;=============================================================================



;=============================================================================
; grim_edit_header
;
;=============================================================================
pro grim_edit_header, grim_data

 plane = grim_get_plane(grim_data)
 widget_control, grim_data.draw, /hourglass

 if(NOT widget_info(grim_data.header_text, /valid)) then $
  begin
   header = dat_header(plane.dd)   
   if(NOT keyword_set(header)) then return
   grim_data.header_text = $
               textedit(header, base=base, resource='grim_header', ysize=40)
   grim_data.header_base = base
   grim_set_data, grim_data
   grim_refresh, grim_data, /no_image, /no_objects
  end $
 else widget_control, grim_data.header_base, /map

; hide button

end
;=============================================================================



;=============================================================================
; grim_notes_callback
;
;=============================================================================
pro grim_notes_callback, id, dd

 widget_control, id, get_value = text
 cor_set_notes, dd, text

end
;=============================================================================



;=============================================================================
; grim_edit_notes
;
;=============================================================================
function grim_edit_notes, xd, base=base

 text = 0

 if(NOT widget_info(base, /valid)) then $
  begin
   class = cor_class(xd)
   title = 'NOTES: ' + class
   if(class EQ 'POINT') then title = title + '(' + pnt_desc(xd) + ')'
   title = title + '; ' + cor_name(xd)
   text = $
     textedit(cor_notes(xd), base=base, resource='grim_notes', $
                  title=title, callback='grim_notes_callback', data=xd)
  end $
 else widget_control, base, /map

 return, text
end
;=============================================================================



;=============================================================================
; grim_frame_current_overlays
;
;=============================================================================
pro grim_frame_current_overlays, grim_data

 plane = grim_get_plane(grim_data)

 widget_control, grim_data.draw, /hourglass

 active_ptd = grim_ptd(plane, /active)
 if(NOT keyword_set(ptd)) then ptd = grim_ptd(plane)
 if(NOT keyword_set(ptd)) then return

 grim_frame_overlays, grim_data, plane, ptd

 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
; grim_edit_dd_notes
;
;=============================================================================
pro grim_edit_dd_notes, grim_data, plane=plane

 base = grim_data.notes_base

 if(widget_info(base, /valid)) then $
  begin
   widget_control, base, /map
   return
  end

 grim_data.notes_text = grim_edit_notes(plane.dd, base=base)
 grim_data.notes_base = base
 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_user_ptd_fname
;
;=============================================================================
function grim_user_ptd_fname, grim_data, plane, basename=basename

 if(NOT keyword_set(basename)) then $
  begin
   basename = cor_name(plane.dd)
   if(NOT keyword_set(basename)) then basename = 'grim-' + strtrim(plane.pn,2)
  end

 return, grim_data.workdir + path_sep() + basename + '.user_ptd'
end
;=============================================================================



;=============================================================================
; grim_write_user_points
;
;=============================================================================
pro grim_write_user_points, grim_data, plane, fname=_fname

 if(NOT keyword_set(_fname)) then $
             fname = grim_user_ptd_fname(grim_data, plane) $
 else fname = _fname

 user_ptd = grim_get_user_ptd(plane=plane)

 w = where(pnt_valid(user_ptd))
 if(w[0] NE -1) then pnt_write, fname, user_ptd $
 else $
  begin
   ff = file_search(fname)
   if(keyword_set(ff)) then file_delete, fname, /quiet
  end

end
;=============================================================================



;=============================================================================
; grim_write_detached_header
;
;=============================================================================
pro grim_write_detached_header, grim_data, plane, fname=_fname

 if(NOT keyword_set(_fname)) then fname = 'auto' $
 else fname = _fname

 grim_print, grim_data, 'Writing ' + fname[0]

 dd = plane.dd
 cd = grim_xd(plane, /cd)
 if(grim_test_map(grim_data)) then pg_put_maps, dd, md=cd, 'dh_out=' + fname $
 else $
  begin
   pg_put_planets, dd, od=cd, pd=grim_xd(plane, /pd)
   pg_put_arrays, dd, od=cd, ard=grim_xd(plane, /ard)
   pg_put_stations, dd, od=cd, std=grim_xd(plane, /std)
   pg_put_rings, dd, od=cd, rd=grim_xd(plane, /rd)
   pg_put_stars, dd, od=cd, sd=grim_xd(plane, /sd)
   pg_put_cameras, dd, cd=cd, 'dh_out=' + fname
  end

end
;=============================================================================



;=============================================================================
; grim_mask_fname
;
;=============================================================================
function grim_mask_fname, grim_data, plane, basename=basename
 if(NOT keyword_set(basename)) then basename = cor_name(plane.dd)
 return, grim_data.workdir + path_sep() + basename + '.mask'
end
;=============================================================================



;=============================================================================
; grim_write_mask
;
;=============================================================================
pro grim_write_mask, grim_data, plane, fname=fname

 if(NOT keyword_set(fname)) then $
                fname = grim_mask_fname(grim_data, plane)

 mask = *plane.mask_p
 if(mask[0] EQ -1) then return

 if(mask[0] NE -1) then write_mask, fname, mask, dim=dat_dim(plane.dd) $
 else $
  begin
   ff = file_search(fname)
   if(keyword_set(ff)) then file_delete, fname, /quiet
  end

end
;=============================================================================



;=============================================================================
; grim_read_user_points
;
;=============================================================================
pro grim_read_user_points, grim_data, plane

 fname = grim_user_ptd_fname(grim_data, plane)

 ff = (file_search(fname))[0]
 if(keyword_set(ff)) then user_ptd = pnt_read(ff) $
 else user_ptd = 0

 w = where(pnt_valid(user_ptd))
 if(w[0] NE -1) then $
  begin
   n = n_elements(user_ptd)
   tags = strarr(n)

   for i=0, n-1 do $
    begin
     tag = cor_name(user_ptd[i])
     tags[i] = tag
    end

   for i=0, n-1 do $
    begin
     w = where(tags EQ tags[i])
     if(w[0] NE -1) then $
      begin
       grim_add_user_points, user_ptd[w], [tags[i]], plane=plane, /no_refresh
       tags[w] = ''
      end
    end


  end

end
;=============================================================================



;=============================================================================
; grim_read_mask
;
;=============================================================================
pro grim_read_mask, grim_data, plane, fname=fname

 if(NOT keyword_set(fname)) then fname = grim_mask_fname(grim_data, plane)

 ff = (file_search(fname))[0]
 if(keyword_set(ff)) then mask = read_mask(ff, sub=sub) $
 else mask = -1

 if(mask[0] NE -1) then grim_add_mask, grim_data, sub, plane=plane, /replace, /sub

end
;=============================================================================



;=============================================================================
; grim_jumpto
;
;=============================================================================
function grim_jumpto, grim_data, pn

 if(NOT keyword_set(pn)) then $
  begin
   done = 0
   repeat $
    begin
     pns = dialog_input('Plane number:')
     if(NOT keyword_set(pns)) then return, 0
     w = str_isnum(pns)
     if(w[0] NE -1) then done = 1
    endrep until(done)
   pn = (long(pns))[0]
  end

 grim_jump_to_plane, grim_data, pn, valid=valid

 return, valid
end
;=============================================================================



;=============================================================================
; grim_recenter
;
;=============================================================================
pro grim_recenter, grim_data, p

 cx = !d.x_size/2
 cy = !d.y_size/2
 q = convert_coord(double(cx), double(cy), /device, /to_data)

 grim_refresh, grim_data, doffset=(p-q)[0:1]

end
;=============================================================================



;=============================================================================
; grim_zoom
;
;=============================================================================
function grim_zoom, grim_data

 done = 0
 repeat $
  begin
   zs = dialog_input('New zoom:')
   if(NOT keyword_set(zs)) then return, 0
   w = str_isfloat(zs)
   if(w[0] NE -1) then done = 1
  endrep until(done)

 zoom = double(zs)
 return, zoom
end
;=============================================================================



;=============================================================================
; grim_zoom_to_cursor
;
;=============================================================================
function grim_zoom_to_cursor, grim_data, zz, relative=relative, zoom=zoom

 tvim, grim_data.wnum, get_info=tvd, /silent
 if(keyword_set(relative)) then zoom = tvd.zoom*zz $
 else zoom = zz

 zf = zoom / tvd.zoom

 cursor, x, y, /nowait, /data
 device_cc = transpose([transpose([0,0]), transpose([!d.x_size-1, !d.y_size-1])])
 data_cc = (convert_coord(double(device_cc[0,*]), double(device_cc[1,*]), /device, /to_data))[0:1,*]
 data_size = abs(data_cc[*,0] - data_cc[*,1])

 new_data_size = data_size/zf

 ff = [(x-tvd.offset[0])/(data_size[0]-1), (y-tvd.offset[1])/(data_size[1]-1)]
 offset = [x-new_data_size[0]*ff[0], y-new_data_size[1]*ff[1]] + 1

 return, offset
end
;=============================================================================



;=============================================================================
; grim_toggle_context
;
;=============================================================================
pro grim_toggle_context, grim_data

 ;----------------------------
 ; toggle the mapping state
 ;----------------------------
 if(grim_data.context_mapped) then grim_data.context_mapped = 0 $
 else grim_data.context_mapped = 1
 grim_set_data, grim_data, grim_data.base

 ;------------------------------------------------------
 ; if mapped, copy the image onto the window
 ;------------------------------------------------------
 if(grim_data.context_mapped) then $
  begin
   grim_refresh, grim_data, /no_main
   grim_show_context_image, grim_data
  end

 ;----------------------------
 ; set the new mapping state
 ;----------------------------
 widget_control, grim_data.context_base, map=grim_data.context_mapped

end
;=============================================================================



;=============================================================================
; grim_toggle_axes
;
;=============================================================================
pro grim_toggle_axes, grim_data

 ;---------------------------------------------------------
 ; toggle axes flag
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_data.axes_flag = NOT grim_data.axes_flag

 ;----------------------------
 ; set the new mapping state
 ;----------------------------
 widget_control, grim_data.axes_base, map=grim_data.axes_flag

 grim_set_data, grim_data, grim_data.base

 ;------------------------------------------------------
 ; if mapped, copy the image onto the window
 ;------------------------------------------------------
 if(grim_data.axes_flag) then grim_show_axes, grim_data

end
;=============================================================================



;=============================================================================
; grim_render_image
;
;=============================================================================
pro grim_render_image, grim_data, plane=plane, image_pts=image_pts

 if(NOT plane.image_visible) then return

 ;-----------------------------------------
 ; get settings
 ;-----------------------------------------
 sky = plane.render_sky
 numbra = plane.render_numbra
 sample = plane.render_sampling
 minimum = plane.render_minimum/100.

 ;-----------------------------------------
 ; load relevant descriptors
 ;-----------------------------------------
 grim_suspend_events
 cd = grim_get_cameras(grim_data, plane=plane)
 ltd = grim_get_lights(grim_data, plane=plane)
 grim_resume_events

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; Get bodies to render: exclude background stars by angular size
 ; and treat sky separately.
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _bx = cor_select(grim_xd(plane), 'SOLID', /class, exclude_name='SKY')
 sel = pg_select_bodies(_bx, od=cd, pix=0.1)
 if(sel[0] NE -1) then bx= _bx[sel]

 if(sky) then skd = cor_select(grim_xd(plane), 'SKY')

 ;-----------------------------------------------
 ; load maps; for now use only rectangular maps
 ;-----------------------------------------------
 md = plane.render_cd
 dd_map = plane.render_dd
 if(NOT keyword_set(dd_map)) then $
     dd_map = pg_load_maps(md=md, bx=append_array(bx, skd), projection='RECTANGULAR')

 if(cor_class(plane.render_cd) EQ 'CAMERA') then no_pht = 1

 ;-----------------------------------------
 ; render
 ;-----------------------------------------
 stat = pg_render(/psf, /nodd, /no_mask, show=grim_data.render_show, $
                    cd=cd, bx=bx, skd=skd, ltd=ltd, md=md, ddmap=dd_map, map=map, $
                    pht=minimum, sample=sample, numbra=numbra, $
                    image_ptd=image_pts, no_pht=no_pht)
 dim = size(map, /dim)
 nz = 1
 if(n_elements(dim) EQ 3) then nz = dim[2]

 image_pts = reform(image_pts, 2, n_elements(map)/nz, /over)

 dat_set_data, plane.dd, map, /noevent
 if(nz EQ 3) then dat_set_dim_fn, plane.dd, 'grim_rgb_dim_fn', /noevent
end
;=============================================================================



;=============================================================================
; grim_render
;
;=============================================================================
pro grim_render, grim_data, plane=plane

 if(grim_data.type EQ 'PLOT') then return

 if(plane.render_auto) then plane.render_spawn = 0

 ;---------------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;---------------------------------------------------------
; grim_load_descriptors, grim_data, name, plane=plane, $
;       cd=cd, pd=pd, rd=rd, ltd=ltd, sd=sd, ard=ard, std=std, od=od, $
;       gd=gd
 grim_load_descriptors, grim_data, 'LIMB', plane=plane


 ;---------------------------------------------------------
 ; render
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, /hourglass


 ;------------------------------------------------------------
 ; Create new plane unless no spawning. The new plane will 
 ; include a transformation that allows the rendering to 
 ; appear in the correct location in the display relative 
 ; to the data coordinate system.
 ;------------------------------------------------------------
 if(NOT plane.render_spawn) then new_plane = plane $
 else new_plane = grim_clone_plane(grim_data, plane=plane)

 new_plane.rendering = 1
 new_plane.render_spawn = 0

 dat_set_sampling_fn, new_plane.dd, 'grim_render_sampling_fn', /noevent

 dat_set_dim_fn, new_plane.dd, 'grim_render_dim_fn', /noevent
 dat_set_dim_data, new_plane.dd, dat_dim(plane.dd), /noevent

 grim_set_plane, grim_data, new_plane

 grim_jump_to_plane, grim_data, new_plane.pn


 ;---------------------------------------------------------
 ; set up grid
 ;---------------------------------------------------------
 nv_suspend_events

 device_pts = gridgen([!d.x_size,!d.y_size])
 image_pts = (convert_coord(device_pts, /device, /to_data))[0:1,*]
 image_pts = reform(image_pts, 2, !d.x_size,!d.y_size, /over)

 dat_set_sampling_data, new_plane.dd, image_pts

 grim_set_plane, grim_data, new_plane
 grim_set_data, grim_data, grim_data.base


 ;---------------------------------------------------------
 ; perform rendering
 ;---------------------------------------------------------
 grim_print, grim_data, 'Rendering plane ' + strtrim(plane.pn,2)
 grim_render_image, grim_data, plane=new_plane, image_pts=image_pts

 nv_resume_events

 grim_refresh, grim_data
 grim_print, grim_data, 'Done.'

end
;=============================================================================



;=============================================================================
; grim_repeat
;
;=============================================================================
pro grim_repeat, grim_data

 if(keyword_set(grim_data.repeat_fn)) then $
             call_procedure, grim_data.repeat_fn, *grim_data.repeat_event_p

end
;=============================================================================



;=============================================================================
; grim_exit
;
;=============================================================================
pro grim_exit, grim_data, grn=grn

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data()
 if(NOT defined(grn)) then grn = grim_data.grn

 for i=0, n_elements(grn)-1 do $
  begin
   grim_data = grim_get_data(grn=grn[i])
   if(keyword_set(grim_data)) then widget_control, grim_data.base, /destroy
  end
end
;=============================================================================



;=============================================================================
; grim_undo
;
;=============================================================================
pro grim_undo, grim_data, plane
 dat_undo, plane.dd
end
;=============================================================================



;=============================================================================
; grim_redo
;
;=============================================================================
pro grim_redo, grim_data, plane
 dat_redo, plane.dd
end
;=============================================================================



;=============================================================================
;
; FILE MENU
;	
;
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_event
;
;
; PURPOSE:
;	Allows user to load images into new image planes.  The user is 
;	prompted for filenames and DAT_READ is used to read each image.
;	Multiple images may be selected and a new plane is created for
;	each image.  On X-windows systems, multiple files may be selected 
;	either by dragging across the filenames or by holding down the 
;	control key to toggle the selected files.
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
pro grim_menu_file_load_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_message, /clear
 
 widget_control, grim_data.base, /hourglass

 ;--------------------------
 ; select file
 ;--------------------------
 if(keyword__set(plane.load_path)) then path = plane.load_path
 filenames = pickfiles(get_path=get_path, path=path, $
                        filter=plane.filter, title='Select file to load')
 if(NOT keyword__set(filenames[0])) then return

 ;----------------------------------
 ; load each file into a new plane
 ;----------------------------------
 widget_control, grim_data.base, /hourglass
 grim_load_files, grim_data, filenames, load_path=get_path

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_browse_event
;
;
; PURPOSE:
;	Allows user to load images into new image planes using the BRIM 
;	browser.  Images are selected using the left mouse button and
;	each image is loaded on a new plane after the browse window is closed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================
pro grim_menu_file_browse_help_event, event
 text = ''
 nv_help, 'grim_menu_file_browse_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_browse_file_left_event, brim_data, base, i, dd, status=status

 status = -1
 grim_data = grim_get_data(base)


 status = 0
end
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pro grim_menu_file_browse_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 widget_control, grim_data.base, /hourglass

 ;----------------------------------
 ; load images into brim
 ;----------------------------------
 if(keyword__set(plane.load_path)) then path = plane.load_path
 grim_wset, grim_data, grim_data.wnum, get_info=tvd

 brim, path=plane.load_path, get_path=get_path, /modal, order=tvd.order, $
      title='Select files to load', picktitle='Select files to browse', $
      filter=plane.filter, select=select
 if(NOT keyword_set(select)) then return

 ;----------------------------------
 ; load each file into a new plane
 ;----------------------------------
 widget_control, grim_data.base, /hourglass
 grim_load_files, grim_data, select, load_path=get_path, /norefresh
 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_event
;
;
; PURPOSE:
;	Allows user to save the current image plane and geometry.  If there 
;	is no current filename for the current plane, then the user is 
;	prompted for one.  All descriptors are written through the translators
;	and then DAT_WRITE is used to write the data file.  Specific behavior 
;	is governed by OMINAS' configuration.
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
pro grim_menu_file_save_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; prompt for filename if necessary
 ;------------------------------------------------------
 filename = dat_filename(plane.dd)
 if(NOT keyword_set(filename)) then $
        filename = grim_get_save_filename(grim_data, filetype=filetype)
 if(NOT keyword_set(filename)) then return


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write, grim_data, filename, filetype=filetype

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_as_event
;
;
; PURPOSE:
;	Same as 'Save' above, except always prompts for a filename. 
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
pro grim_menu_file_save_as_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_as_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_as_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; prompt for filename 
 ;------------------------------------------------------
 filename = grim_get_save_filename(grim_data, filetype=filetype)
 if(NOT keyword_set(filename)) then return

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write, grim_data, filename, filetype=filetype

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_open_as_rgb_event
;
;
; PURPOSE:
;	Opens a new GRIM window with the current channal configuration 
;	reduced to a 3-channel RGB cube.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2016
;	
;-
;=============================================================================
pro grim_menu_open_as_rgb_help_event, event
 text = ''
 nv_help, 'grim_menu_open_as_rgb_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_open_as_rgb_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, /hourglass
 grim_wset, grim_data, grim_data.wnum, get_info=tvd

 dim = dat_dim(plane.dd)
 cube = grim_scale_image(grim_data, r, g, b, plane=plane, $
                                 xrange=[0,dim[0]-1], yrange=[0,dim[1]-1])

; look at render event to transfer overlays, etc
; dd = nv_clone(plane.dd)
; dat_set_data, dd, cube
 dd = dat_create_descriptors(1, data=cube)
 dat_set_filetype, dd, dat_filetype(plane.dd)

 grim, /new, /rgb, dd, order=tvd.order, zoom=tvd.zoom[0], offset=tvd.offset, $
       xsize=!d.x_size, ysize=!d.y_size

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_user_ptd_event
;
;
; PURPOSE:
;	Writes user points for the current plane to a file called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_user_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_user_ptd_fname(grim_data, plane), $
                            title='Select filename for saving', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_user_points, grim_data, plane, fname=fname
 grim_print, grim_data, 'User points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_user_ptd_event
;
;
; PURPOSE:
;	Writes user points for all planes to files called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_all_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_user_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_user_points, grim_data, planes[i], fname=fname
 grim_print, grim_data, 'All user points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_detached_header_event
;
;
; PURPOSE:
;	Saves a detached header for the current plane.  User is prompted
;	to select the location, and name.  Default name is [image name].dh.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2017
;	
;-
;=============================================================================
pro grim_menu_file_save_detached_header_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_detached_header_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_detached_header_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 dd = plane.dd

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=dh_fname(cor_name(dd), /write), $
                                title='Select filename for saving', /one)
 if(NOT keyword_set(fname)) then return


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 nv_suspend_events
 grim_write_detached_header, grim_data, plane, fname=fname
 nv_resume_events

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_detached_headers_event
;
;
; PURPOSE:
;	Writes detached headers for all planes to files called [image name].dh
;	User is prompted for the directory name.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2017
;	
;-
;=============================================================================
pro grim_menu_file_save_all_detached_headers_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_detached_headers_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_detached_headers_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; get directory
 ;------------------------------------------------------
 dir = pickfiles(default=dh_fname(cor_name(dd), /write), /nofile, $
                                title='Select directory for saving', /one)
 if(NOT keyword_set(dir)) then return

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 nv_suspend_events
 for i=0, n_elements(planes)-1 do $
          grim_write_detached_header, grim_data, planes[i], fname=dir + '/auto'
 nv_resume_events

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_user_ptd_event
;
;
; PURPOSE:
;	loads user points for the current plane from a file called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_user_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_read_user_points, grim_data, plane
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_user_ptd_event
;
;
; PURPOSE:
;	Loads user points for all planes from files called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_all_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_user_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_user_points, grim_data, planes[i]
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_tie_ptd_event
;
;
; PURPOSE:
;	Writes tie points for the current plane to a file called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_tie_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'TIEPOINT'), $
                                            title='Select filename for saving', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_indexed_arrays, grim_data, plane, 'TIEPOINT', fname=fname
 grim_print, grim_data, 'Tie points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_tie_ptd_event
;
;
; PURPOSE:
;	Writes tie points for all planes to files called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_all_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_tie_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_indexed_arrays, grim_data, planes[i], 'TIEPOINT'
 grim_print, grim_data, 'All tie points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_tie_ptd_event
;
;
; PURPOSE:
;	loads tie points for the current plane from a file called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_tie_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'TIEPOINT'), $
                                         title='Select filename to load')
 if(NOT keyword_set(fname)) then return

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(fname)-1 do $
       grim_read_indexed_arrays, grim_data, plane, 'TIEPOINT', fname=fname[i]
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_tie_ptd_event
;
;
; PURPOSE:
;	Loads tie points for all planes from files called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_all_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_tie_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_indexed_arrays, grim_data, planes[i], 'TIEPOINT'
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_curves_event
;
;
; PURPOSE:
;	Writes curves for the current plane to a file called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_save_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_curves_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'CURVE'), $
                                         title='Select filename for saving', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_indexed_arrays, grim_data, plane, 'CURVE', fname=fname
 grim_print, grim_data, 'Curves saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_curves_event
;
;
; PURPOSE:
;	Writes curves for all planes to files called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_save_all_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_curves_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_indexed_arrays, grim_data, planes[i], 'CURVE'
 grim_print, grim_data, 'All curves saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_curves_event
;
;
; PURPOSE:
;	loads curves for the current plane from a file called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_load_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_curves_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'CURVE'), $
                                                 title='Select filename to load')
 if(NOT keyword_set(fname)) then return

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(fname)-1 do $
       grim_read_indexed_arrays, grim_data, plane, 'CURVE', fname=fname[i]
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_curves_event
;
;
; PURPOSE:
;	Loads curves for all planes from files called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_load_all_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_curves_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_indexed_arrays, grim_data, planes[i], 'CURVE'
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_mask_event
;
;
; PURPOSE:
;	Writes mask points for the current plane to a file called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_save_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_mask_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_mask_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_mask, grim_data, plane
 grim_print, grim_data, 'Mask saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_masks_event
;
;
; PURPOSE:
;	Writes mask points for all planes to files called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_save_all_masks_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_masks_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_masks_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_mask, grim_data, planes[i]
 grim_print, grim_data, 'All masks saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_mask_event
;
;
; PURPOSE:
;	loads mask points for the current plane from a file called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_load_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_mask_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_mask_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_read_mask, grim_data, plane
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_masks_event
;
;
; PURPOSE:
;	Loads mask points for all planes from files called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_load_all_masks_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_masks_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_masks_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_mask, grim_data, planes[i]
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_ps_event
;
;
; PURPOSE:
;	Saves the current view as a postscript file. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2002
;	
;-
;=============================================================================
pro grim_menu_file_save_ps_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_ps_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base

 ;------------------------------------------------------
 ; prompt for filename 
 ;------------------------------------------------------
 catch, error
 if(error NE 0) then ans = dialog_message('Invalid response', /info)
 set_plot, 'X'

 filename = pickfiles(get_path=get_path, $
                         title='Select filename for saving', path=path, /one)
 if(NOT keyword__set(filename)) then return

 ;------------------------------------------------------
 ; write postscript file
 ;------------------------------------------------------
 widget_control, grim_data.draw, /hourglass
 grim_write_ps, grim_data, filename[0]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_png_event
;
;
; PURPOSE:
;	Saves the current view as a PNG image. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2018
;	
;-
;=============================================================================
pro grim_menu_file_save_png_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_ptd_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_png_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_set_primary, grim_data.base

 ;------------------------------------------------------
 ; prompt for filename 
 ;------------------------------------------------------
 catch, error
 if(error NE 0) then ans = dialog_message('Invalid response', /info)

 filename = pickfiles(get_path=get_path, $
               options=['', 'Color', 'B/W'], selected_option=selected_option, $
               title='Enter filename for saving', path=path, /one, $
               def=ext_rep(grim_title(plane), 'png'))
 if(NOT keyword__set(filename)) then return

 ;------------------------------------------------------
 ; write postscript file
 ;------------------------------------------------------
 widget_control, grim_data.draw, /hourglass

 if(selected_option EQ 'B/W') then mono = 1
 png_image, filename[0], mono=mono

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_repeat_event
;
;
; PURPOSE:
;	Repeats the last menu option.
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
pro grim_menu_repeat_help_event, event
 text = ''
 nv_help, 'grim_menu_file_repeat_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_repeat_event, event

 grim_data = grim_get_data(event.top)
 grim_repeat, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_undo_event
;
;
; PURPOSE:
;	Undoes the last data modification.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2006
;	
;-
;=============================================================================
pro grim_menu_undo_help_event, event
 text = ''
 nv_help, 'grim_menu_file_undo_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_undo_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_undo, grim_data, plane
 
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_redo_event
;
;
; PURPOSE:
;	Redoes the last data modification.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2006
;	
;-
;=============================================================================
pro grim_menu_redo_help_event, event
 text = ''
 nv_help, 'grim_menu_file_redo_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_redo_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_redo, grim_data, plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_select_event
;
;
; PURPOSE:
;	Selects or unselects a grim window.  This functionality is for use
;	with functions that require input from more than one grim instance. 
;	The selected state is red; unselected is gray.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	This option toggles a given grim instance between selected 
;	and unselected states, for use with functions that require 
;	input from more than one grim instance.  When a given instance 
;	is selected, this button displays an asterisk.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_select_help_event, event
 text = ''
 nv_help, 'grim_menu_select_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_select_event, event

 grim_data = grim_get_data(event.top)

 grim_select, grim_data
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_identify_event
;
;
; PURPOSE:
;	Causes grim to identify itself on the IDL command line.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	This option causes grim to print a message on the IDL command line.
;	It is useful in cases where multiple grim instances are running in
;	multiple IDL sessions.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2009
;	
;-
;=============================================================================
pro grim_menu_identify_help_event, event
 text = ''
 nv_help, 'grim_menu_identify_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_identify_event, event

 grim_data = grim_get_data(event.top)
 grim_identify, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_close_event
;
;
; PURPOSE:
;	Closes the current image plane.  All other image plane numbers 
;	remain the same.  If there is only one image plane, the grim exits. 
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
pro grim_menu_file_close_help_event, event
 text = ''
 nv_help, 'grim_menu_file_close_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_close_event, event

 grim_data = grim_get_data(event.top)
 grim_rm_plane, grim_data, grim_data.pn

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_settings_event
;
;
; PURPOSE:
;	Open the miscellaeous settings dialog. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2019
;	
;-
;=============================================================================
pro grim_menu_settings_help_event, event
 text = ''
 nv_help, 'grim_menu_settings_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_settings_event, event

 grim_data = grim_get_data(event.top)
 grim_settings, grim_data

end
;=============================================================================



;=============================================================================
;
; PLANE MENU
;	
;
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_first_event
;
;
; PURPOSE:
;	Changes to the first image plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2018
;	
;-
;=============================================================================
pro grim_menu_plane_first_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_first_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_first_event, event

 grim_data = grim_get_data(event.top)

 grim_change_plane, grim_data, /first
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_last_event
;
;
; PURPOSE:
;	Changes to the last image plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2018
;	
;-
;=============================================================================
pro grim_menu_plane_last_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_last_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_last_event, event

 grim_data = grim_get_data(event.top)

 grim_change_plane, grim_data, /last
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_next_event
;
;
; PURPOSE:
;	Changes to the next-numbered image plane. 
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
pro grim_menu_plane_next_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_next_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_next_event, event

 grim_data = grim_get_data(event.top)

 grim_change_plane, grim_data, /next
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_previous_event
;
;
; PURPOSE:
;	Changes to the previous-numbered image plane. 
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
pro grim_menu_plane_previous_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_previous_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_previous_event, event

 grim_data = grim_get_data(event.top)

 grim_change_plane, grim_data, /previous
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_jump_event
;
;
; PURPOSE:
;	Prompts the user and jumps to a new plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_menu_plane_jump_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_jump_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_jump_event, event

 grim_data = grim_get_data(event.top)

 valid = grim_jumpto(grim_data)
 if(valid) then grim_refresh, grim_data, /no_erase

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_browse_event
;
;
; PURPOSE:
;	Opens a brim browser showing all planes.  The left mouse button 
;	may be used to jump among planes.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================
pro grim_menu_plane_browse_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_browse_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_browse_plane_left_event, brim_data, base, pn, dd, status=status

 status = -1
 grim_data = grim_get_data(base)
 if(NOT grim_exists(grim_data)) then return

 grim_jump_to_plane, grim_data, pn, valid=valid
 if(valid) then $
  begin
   grim_refresh, grim_data, /no_erase
   status = 1
  end

 brim_select, brim_data, /clear
 brim_select, brim_data, pn, /select
end
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pro grim_menu_plane_browse_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all, pn=pns)

 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 brim, planes.dd, $
      left_fn='grim_browse_plane_left_event', fn_data=event.top, $
      order=tvd.order, base=base

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_open_event
;
;
; PURPOSE:
;	Opens the image of the current plane in a new grim window.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
pro grim_menu_plane_open_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_open_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_open_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, /hourglass
 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 grim, /new, plane.dd, order=tvd.order, zoom=tvd.zoom[0], offset=tvd.offset, $
       xsize=!d.x_size, ysize=!d.y_size

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_evolve_event
;
;
; PURPOSE:
;	Evolves the selected objects onto all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_plane_evolve_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_evolve_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_evolve_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, /hourglass

grim_print, grim_data, 'Not implemented!'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_crop_event
;
;
; PURPOSE:
;	Crops the data to the current viewing parameters.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2013
;	
;-
;=============================================================================
pro grim_menu_plane_crop_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_crop_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_crop_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_crop_plane, grim_data, plane
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_reorder_time_event
;
;
; PURPOSE:
;	Rearranges all planes in time order.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_plane_reorder_time_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_reorder_time_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_reorder_time_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 times = dblarr(n)
 for i=0, n-1 do $
  begin
   cd = *planes[i].cd_p
   if(NOT keyword__set(cd)) then grim_message, $
                   'You must first load camera descriptors for each plane.'
   times[i] = bod_time(cd)
  end

 s = sort(times)

 planes = planes[s]
 for i=0, n-1 do $
  begin
   planes[i].pn = i
   grim_set_plane, grim_data, planes[i], pn=i
  end

 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_sequence_event
;
;
; PURPOSE:
;	Displays all planes in sequence using xinteranimate.  This option is
;	useful or blinking as well.
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
pro grim_menu_plane_sequence_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_sequence_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_sequence_event, event

 grim_data = grim_get_data(event.top)

 ;--------------------------------------------
 ; get valid planes
 ;--------------------------------------------
 planes = grim_get_plane(grim_data, /all)
 n = n_elements(planes)
 if(n LE 1) then return
 
 ;--------------------------------------------
 ; set up images
 ;--------------------------------------------
 widget_control, /hourglass

 geom = widget_info(grim_data.draw, /geom)
 xinteranimate, set=[geom.xsize, geom.ysize, n]
 tvim, /noplot, /silent, $
           /new, /inherit, xsize=geom.xsize, ysize=geom.ysize, /pixmap
 pixmap = !d.window

; for i=0, n-1 do $
;  begin
;grim_refresh, grim_data, plane=planes[i], wnum=pixmap, /no_title
;im = tvrd()
;write_gif, /mult, '~/test.gif', im
;  end
;write_gif, /close
;stop

 for i=0, n-1 do $
  begin
   grim_print, grim_data, $
     'Loading plane ' + strtrim(i,2) + ' of ' + strtrim(n,2) + '...'

   wset, pixmap & erase & wset, grim_data.wnum

   grim_refresh, grim_data, plane=planes[i], wnum=pixmap, /no_title

   xinteranimate, frame=i, window=pixmap, /show
  end

 grim_print, grim_data, ''

 ;--------------------------------------------
 ; run the movie
 ;--------------------------------------------
 wdelete, pixmap
 grim_wset, grim_data, grim_data.wnum

 xinteranimate
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_dump_event
;
;
; PURPOSE:
;	Dumps all planes to png files entitled [filename].png.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2004
;	
;-
;=============================================================================
pro grim_menu_plane_dump_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_dump_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_dump_event, event

 grim_data = grim_get_data(event.top)

 ;--------------------------------------------
 ; get valid planes
 ;--------------------------------------------
 planes = grim_get_plane(grim_data, /all)
 n = n_elements(planes)
 if(n LE 1) then return
 
 ;--------------------------------------------
 ; set up images
 ;--------------------------------------------
 widget_control, /hourglass

 geom = widget_info(grim_data.draw, /geom)
 xinteranimate, set=[geom.xsize, geom.ysize, n]
 tvim, /noplot, /silent, $
           /new, /inherit, xsize=geom.xsize, ysize=geom.ysize, /pixmap
 pixmap = !d.window


 for i=0, n-1 do $
  begin
   filename = cor_name(planes[i].dd)
   grim_refresh, grim_data, plane=planes[i], wnum=pixmap, /no_title
   wset, pixmap
   write_png, filename + '.png', tvrd()
  end

 wdelete, pixmap
 grim_wset, grim_data, grim_data.wnum

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_coregister_event 
;
;
; PURPOSE:
;	Shifts the images on each plane so as to center the active object 
;	at the same pixel on each plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
pro grim_menu_plane_coregister_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_coregister_event ', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_coregister_event, event

 grim_data = grim_get_data(event.top)
 planes = grim_get_plane(grim_data, /all)
 n = n_elements(planes)

 widget_control, grim_data.draw, /hourglass


 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 for i=0, n-1 do $
   grim_load_descriptors, grim_data, class='CAMERA', plane=planes[i], cd=cd
 if(NOT keyword_set(cd[0])) then return 


 ;------------------------------------------------
 ; build descriptor arrays
 ;------------------------------------------------
 cd = objarr(n)
 bx = objarr(n)
 dd = objarr(n)

 for i=0, n-1 do $
  begin
   active_xds = grim_xd(planes[i], /active)
   if(keyword_set(active_xds)) then $
    begin
     dd[i] = planes[i].dd
     cd[i] = *planes[i].cd_p
     bx[i] = active_xds[0]		; Is this a good assumption?
    end
  end

 w = where(obj_valid(dd))
 if(n_elements(w) LT 2) then $
  begin
   grim_message, 'There must be active overlays on at least two planes.'
   return
  end

 dd = dd[w]
 cd = cd[w]
 bx = bx[w]

 ;------------------------------------------------
 ; recenter image
 ;------------------------------------------------
 grim_refresh, /disable
 pg_coregister, dd, cd=cd, bx=bx
 grim_refresh, /enable

 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_coadd_event 
;
;
; PURPOSE:
;	Averages all planes.  Not implemented.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2004
;	
;-
;=============================================================================
pro grim_menu_plane_coadd_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_coadd_event ', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_coadd_event, event

 grim_data = grim_get_data(event.top)
 planes = grim_get_plane(grim_data, /all)
 widget_control, grim_data.draw, /hourglass

 
; grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_plane_syncing_event
;
;
; PURPOSE:
;	Toggles plane syncing on/off.  
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
pro grim_menu_plane_toggle_plane_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_plane_syncing_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_plane_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'PLANE_SYNCING')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'PLANE_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_plane_toggle_plane_syncing_event', flag


; grim_sync_planes, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_highlight_event 
;
;
; PURPOSE:
;	Toggles highlighting of the current plane image.  Useful when 
;	multiple planes are visible simultaneously.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2008
;	
;-
;=============================================================================
pro grim_menu_plane_highlight_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_highlight_event ', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_highlight_event, event

 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'PLANE_HIGHLIGHT')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'PLANE_HIGHLIGHT', flag
 grim_update_menu_toggle, grim_data, 'grim_menu_plane_highlight_event', flag


; widget_control, grim_data.draw, /hourglass
 
 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_force_integer_event
;
;
; PURPOSE:
;	Toggles integer zoom on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2018
;	
;-
;=============================================================================
pro grim_menu_view_zoom_force_integer_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_force_integer_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_force_integer_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'INTEGER_ZOOM')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'INTEGER_ZOOM', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_view_zoom_force_integer_event', flag


 if(flag) then grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_copy_tiepoints_event
;
;
; PURPOSE:
;	Copies tie points from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
pro grim_menu_plane_copy_tiepoints_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_copy_tiepoints_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_copy_tiepoints_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 pn = plane.pn

 for i=0, n-1 do if(i NE pn) then $
                        grim_copy_tiepoint, grim_data, plane, planes[i]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_propagate_tiepoints_event
;
;
; PURPOSE:
;	Copies all tieppoints from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
pro grim_menu_plane_propagate_tiepoints_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_propagate_tiepoints_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_propagate_tiepoints_event, event

 widget_control, /hourglass


 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 nplanes = n_elements(planes)
 pn = plane.pn


 tie_pts = pnt_points(plane.tiepoints_ptd)
 if(NOT keyword_set(tie_pts)) then return
 npts = n_elements(tie_pts)/2
 ii = grim_get_tiepoint_indices(grim_data, plane=plane)

 grim_load_descriptors, grim_data, class='CAMERA', plane=plane, cd=cd
 if(NOT keyword_set(cd[0])) then $ 
  begin
   grim_message, 'No camera descriptor!'
   return
  end
 grim_load_descriptors, grim_data, class='PLANET', plane=plane, pd=pd
 if(NOT keyword_set(pd[0])) then return

 cd = cd[0]

 pd0 = get_primary(cd, pd)
 name = cor_name(pd0)

 tie_pts = reform(tie_pts, 2, 1, npts, /over)

 dkd = make_array(npts, $
           val=orb_construct_descriptor(pd0, sma=1d8, GG=const_G))
 for i=0, npts-1 do $ 
   dkd[i] = image_to_orbit(cd, pd0, dkd[i], tie_pts[*,0,i], GG=const_G)
;orb_set_ma, dkd, orb_anom_to_lon(dkd, orb_get_ma(dkd), pd0)
; for i=0, npts-1 do orb_print_elements_mks, dkd[i], pd0

 for i=0, nplanes-1 do $
  if(planes[i].pn NE pn) then $
   begin
    grim_load_descriptors, grim_data, class='CAMERA', plane=planes[i]
    cdi = (*planes[i].cd_p)[0]
    if(keyword_set(cdi)) then $
     begin
      grim_load_descriptors, grim_data, class='PLANET', plane=planes[i]
      w = where(cor_name(pd) EQ name)
      if(w[0] NE -1) then $
       begin
        pdi = (pd)[w[0]]

        dt = bod_time(pdi) - bod_time(pd0)
        dkdt = objarr(npts)
        r = dblarr(1,3,npts)
        for j=0, npts-1 do $
         begin
          dkdt[j] = orb_evolve(dkd[j], dt)
          bod_set_pos, dkdt[j], bod_pos(pdi)
          r[*,*,j] = orb_to_cartesian(dkdt[j], v=_v)
;          r[*,*,j] = orb_to_cartesian_lt(cdi, dkdt[j], c=const_c, v=_v)
         end

        if(npts GT 1) then r = transpose(r)
        p = reform(inertial_to_image_pos(cdi, r))
plots, p, psym=1, col=ctgreen()

        grim_copy_tiepoint, grim_data, plane, planes[i]
        planes[i] = grim_get_plane(grim_data, pn=planes[i].pn) 

        grim_replace_tiepoints, grim_data, ii, p, plane=planes[i]

        nv_free, dkdt
       end
     end

   end

 nv_free, dkd

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_tiepoint_syncing_event
;
;
; PURPOSE:
;	Toggles tiepoint syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_tiepoint_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_tiepoint_syncing_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_tiepoint_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'TIEPOINT_SYNCING')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'TIEPOINT_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
               'grim_menu_plane_toggle_tiepoint_syncing_event', flag


; grim_sync_tiepoints, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_clear_tiepoints_event
;
;
; PURPOSE:
;	Clears all tiepoints from the current plane.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2004
;	
;-
;=============================================================================
pro grim_menu_plane_clear_tiepoints_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_clear_tiepoints_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_clear_tiepoints_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_rm_tiepoint, grim_data, plane=plane, /all
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_copy_curves_event
;
;
; PURPOSE:
;	Copies all curves from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
pro grim_menu_plane_copy_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_copy_curves_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_copy_curves_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 pn = plane.pn

 for i=0, n-1 do if(i NE pn) then grim_copy_curve, grim_data, plane, planes[i]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_curve_syncing_event
;
;
; PURPOSE:
;	Toggles curve syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_curve_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_curve_syncing_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_curve_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)
 
 flag = grim_get_toggle_flag(grim_data, 'CURVE_SYNCING')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'CURVE_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
                      'grim_menu_plane_toggle_curve_syncing_event', flag

; grim_sync_curves, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_activation_syncing_event
;
;
; PURPOSE:
;	Toggles activation syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2018
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_activation_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_activation_syncing_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_activation_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)
 
 flag = grim_get_toggle_flag(grim_data, 'ACTIVATION_SYNCING')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'ACTIVATION_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
                      'grim_menu_plane_toggle_activation_syncing_event', flag

; grim_sync_activations, grim_data
grim_copy_activations, grim_data, plane=plane
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_action_syncing_event
;
;
; PURPOSE:
;	Toggles action syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2018
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_action_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_action_syncing_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_action_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)
 
 flag = grim_get_toggle_flag(grim_data, 'ACTION_SYNCING')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'ACTION_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
                      'grim_menu_plane_toggle_action_syncing_event', flag

; grim_sync_actions, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_clear_curves_event
;
;
; PURPOSE:
;	Clears all curves from the current plane.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2004
;	
;-
;=============================================================================
pro grim_menu_plane_clear_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_clear_curves_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_clear_curves_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_rm_curve, grim_data, plane=plane, /all
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_copy_mask_event
;
;
; PURPOSE:
;	Copies mask from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_plane_copy_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_copy_mask_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_copy_mask_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 pn = plane.pn

 for i=0, n-1 do if(i NE pn) then grim_copy_mask, grim_data, plane, planes[i]
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_clear_mask_event
;
;
; PURPOSE:
;	Clears the mask from the current plane.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_plane_clear_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_clear_mask_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_clear_mask_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_rm_mask, grim_data, plane=plane, /all
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_settings_event
;
;
; PURPOSE:
;	Allows the user modify settings for the loaded image planes.  
;	Each plane may displayed in any combination of the three color
;	channels.  Also, a plane may be made visible even when it is not
;	the current plane, instead of the default behavior, which is to 
;	display the plane only whenit is current.
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
pro grim_menu_plane_settings_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_settings_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_settings_event, event

 grim_data = grim_get_data(event.top)
 grim_plane_settings, grim_data

end
;=============================================================================



;=============================================================================
;
; DATA MENU
;	
;
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_data_adjust_event
;
;
; PURPOSE:
;	This option allows the user to adjust data values.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2014
;	
;-
;=============================================================================
pro grim_menu_data_adjust_help_event, event
 text = ''
 nv_help, 'grim_menu_data_adjust_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_data_adjust_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; adjust the data
 ;------------------------------------------------
 grim_logging, grim_data, /start
 pg_data_adjust, plane.dd
 grim_logging, grim_data, /stop

 
end
;=============================================================================



;=============================================================================
;
; VIEW MENU
;	
;
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_refresh_event
;
;
; PURPOSE:
;	Redraws the overlays on the graphics display. 
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
pro grim_menu_view_refresh_help_event, event
 text = ''
 nv_help, 'grim_menu_view_refresh_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_refresh_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_event
;
;
; PURPOSE:
;	Prompts the user for a new zoom factor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_menu_view_zoom_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_event, event

 grim_data = grim_get_data(event.top)
 zoom = grim_zoom(grim_data)
 if(zoom NE 0) then grim_refresh, grim_data, zoom=zoom

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_double_event
;
;
; PURPOSE:
;	Doubles the current zoom, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_double_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_double_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 2d, /relative, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_half_event
;
;
; PURPOSE:
;	Halves the current zoom, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_half_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_half_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 0.5d, /relative, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_event
;
;
; PURPOSE:
;	Sets the current zoom to 1, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_2_event
;
;
; PURPOSE:
;	Sets the current zoom to 2, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_2_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_2_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 2d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_3_event
;
;
; PURPOSE:
;	Sets the current zoom to 3, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_3_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_3_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 3d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_4_event
;
;
; PURPOSE:
;	Sets the current zoom to 4, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_4_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_4_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 4d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_5_event
;
;
; PURPOSE:
;	Sets the current zoom to 5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_5_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 5d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_6_event
;
;
; PURPOSE:
;	Sets the current zoom to 6, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_6_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_6_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 6d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_7_event
;
;
; PURPOSE:
;	Sets the current zoom to 7, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_7_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_7_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 7d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_8_event
;
;
; PURPOSE:
;	Sets the current zoom to 8, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_8_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_8_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 8d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_9_event
;
;
; PURPOSE:
;	Sets the current zoom to 9, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_9_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_9_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 9d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_10_event
;
;
; PURPOSE:
;	Sets the current zoom to 10, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_10_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_10_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 10d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_2_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/2, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_2_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_2_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/2d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_3_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/3, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_3_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_3_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/3d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_4_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/4, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_4_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_4_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/4d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_5_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_5_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/5d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_5_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_5_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/5d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_6_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/6, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_6_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_6_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/6d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_7_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/7, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_7_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_7_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/7d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_8_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/8, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_8_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_8_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/8d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_9_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/9, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_9_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_9_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/9d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_10_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/10, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_10_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_10_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(grim_data, 1d/10d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_0_event
;
;
; PURPOSE:
;	Sets the current rotate to 0, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_0_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_0_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=0

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_1_event
;
;
; PURPOSE:
;	Sets the current rotate to 1, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_1_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_1_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=1

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_2_event
;
;
; PURPOSE:
;	Sets the current rotate to 2, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_2_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_2_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=2

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_3_event
;
;
; PURPOSE:
;	Sets the current rotate to 3, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_3_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_3_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=3

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_4_event
;
;
; PURPOSE:
;	Sets the current rotate to 4, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_4_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_4_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=4

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_5_event
;
;
; PURPOSE:
;	Sets the current rotate to 5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_5_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=5

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_6_event
;
;
; PURPOSE:
;	Sets the current rotate to 6, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_6_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_6_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=6

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_7_event
;
;
; PURPOSE:
;	Sets the current rotate to 7, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_7_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_7_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=7

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_recenter_event
;
;
; PURPOSE:
;	Recenters the view at the cursor position. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_recenter_help_event, event
 text = ''
 nv_help, 'grim_menu_view_recenter_help_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_recenter_event, event

 grim_data = grim_get_data(event.top)

 cursor, x, y, /device, /nowait

 p = convert_coord(double(x), double(y), /device, /to_data)
 grim_recenter, grim_data, p

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_apply_event
;
;
; PURPOSE:
;	Applys the current view to all planes. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2016
;	
;-
;=============================================================================
pro grim_menu_view_apply_help_event, event
 text = ''
 nv_help, 'grim_menu_view_apply_help_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_apply_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 for i=0, nplanes-1 do if(planes[i].pn NE plane.pn) then $
  begin
   planes[i].xrange = plane.xrange
   planes[i].yrange = plane.yrange
   planes[i].position = plane.position
  end

 grim_set_data, grim_data, event.top

 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /home

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_home_event
;
;
; PURPOSE:
;	Sets the tvim home view settings. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_menu_view_home_help_event, event
 text = ''
 nv_help, 'grim_menu_view_home_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_home_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /home

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_save_event
;
;
; PURPOSE:
;	Saves the current view settings. 
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
pro grim_menu_view_save_help_event, event
 text = ''
 nv_help, 'grim_menu_view_save_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_save_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_wset, grim_data, /noplot, /save

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_restore_event
;
;
; PURPOSE:
;	Restores the last-saved view settings. 
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
pro grim_menu_view_restore_help_event, event
 text = ''
 nv_help, 'grim_menu_view_restore_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_restore_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /restore

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_previous_event
;
;
; PURPOSE:
;	Restores the previous view settings. 
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
pro grim_menu_view_previous_help_event, event
 text = ''
 nv_help, 'grim_menu_view_previous_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_previous_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /previous

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_entire_event
;
;
; PURPOSE:
;	Applies the 'entire' display parameters, as given in tvim. 
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
pro grim_menu_view_entire_help_event, event
 text = ''
 nv_help, 'grim_menu_view_entire_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_entire_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /entire

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_initial_event
;
;
; PURPOSE:
;	Reverts to the initial view parameters for this grim widget. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2007
;	
;-
;=============================================================================
pro grim_menu_view_initial_help_event, event
 text = ''
 nv_help, 'grim_menu_view_entire_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_initial_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 tvd = *grim_data.tvd_init_p
 tvim, /inherit, /silent, zoom=tvd.zoom, order=tvd.order, offset=tvd.offset

 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_flip_event
;
;
; PURPOSE:
;	Reverses the curent display order. 
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
pro grim_menu_view_flip_help_event, event
 text = ''
 nv_help, 'grim_menu_view_flip_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_flip_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /flip

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_frame_event
;
;
; PURPOSE:
;	Modifies view settings so as to display the either all overlays
;	or those that are active. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2007
;	
;-
;=============================================================================
pro grim_menu_view_frame_help_event, event
 text = ''
 nv_help, 'grim_menu_view_frame_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_frame_event, event

 grim_data = grim_get_data(event.top)
 grim_frame_current_overlays, grim_data

; plane = grim_get_plane(grim_data)

; widget_control, grim_data.draw, /hourglass

; active_ptd = grim_ptd(plane, /active)
; if(NOT keyword_set(ptd)) then ptd = grim_ptd(plane)
; if(NOT keyword_set(ptd)) then return

; grim_frame_overlays, grim_data, plane, ptd

; grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_header_event
;
;
; PURPOSE:
;	Opens a text window showing the image header. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2003
;	
;-
;=============================================================================
pro grim_menu_view_header_help_event, event
 text = ''
 nv_help, 'grim_menu_view_header_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_header_event, event

 grim_data = grim_get_data(event.top)
 grim_edit_header, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_notes_event
;
;
; PURPOSE:
;	Opens a text window allowing the user to enter notes for each plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2003
;	
;-
;=============================================================================
pro grim_menu_notes_help_event, event
 text = ''
 nv_help, 'grim_menu_notes_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_notes_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 
 grim_edit_dd_notes, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_toggle_image_event
;
;
; PURPOSE:
;	Toggles the image On/Off. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================
pro grim_menu_image_help_event, event
 text = ''
 nv_help, 'grim_menu_toggle_image_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_toggle_image_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_toggle_image, grim_data, plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_toggle_image_overlays_event
;
;
; PURPOSE:
;	Toggles the image and overlays On/Off. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================
pro grim_menu_image_overlays_help_event, event
 text = ''
 nv_help, 'grim_menu_toggle_image_overlays_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_toggle_image_overlays_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_toggle_image_overlays, grim_data, plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_context_event
;
;
; PURPOSE:
;	Toggles the context window On/Off. 
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2005
;	
;-
;=============================================================================
pro grim_menu_context_help_event, event
 text = ''
 nv_help, 'grim_menu_context_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_context_event, event

 grim_data = grim_get_data(event.top)
 grim_toggle_context, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_axes_event
;
;
; PURPOSE:
;	Toggles the axes window On/Off.  The colors are as follows:
;
;	 Blue	- Inertial axes.
;	 Red	- Camera axes.
;	 Green	- Direction to primary planet, not foreshortened.
;	 Yellow	- Direction to primary light source, not foreshortened.
;
;	Vectors pointing away from the camera are dotted.  The vectors are 
;	rooted at a point 1d5 distance units in front of the camera .  
;	In the direction corresponding to the image position of the drawn 
;	axes.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2005
;	
;-
;=============================================================================
pro grim_menu_axes_help_event, event
 text = ''
 nv_help, 'grim_menu_axes_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_axes_event, event

 grim_data = grim_get_data(event.top)
 grim_toggle_axes, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_toggle_rgb_event
;
;
; PURPOSE:
;	Toggles RGB rendering on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_toggle_rgb_help_event, event
 text = ''
 nv_help, 'grim_menu_render_toggle_rgb_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_toggle_rgb_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'RENDER_RGB')
 flag = 1 - flag

 
 grim_set_toggle_flag, grim_data, 'RENDER_RGB', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_render_toggle_rgb_event', flag


 plane.render_rgb = flag
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_enter_numbra_event
;
;
; PURPOSE:
;   This option prompts the user to enter a numbra value for rendering.  Numbra
;   specifies the number of samples to compute on a light source to produce
;   accurate shadows.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_enter_numbra_help_event, event
 text = ''
 nv_help, 'grim_menu_render_enter_numbra_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_enter_numbra_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 done = 0
 repeat $
  begin
   response = dialog_input('New Numbra:', cancelled=cancelled)
   if(cancelled) then return
   if(keyword_set(response)) then $
    begin
     w = str_isfloat(response)
     if((n_elements(w) EQ 1) AND (w[0] NE -1)) then done = 1
    end
  endrep until(done)

; grim_set_menu_value, grim_data, 'grim_menu_render_enter_numbra_event', response

 plane.render_numbra = long(response)
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_enter_sampling_event
;
;
; PURPOSE:
;   This option prompts the user to enter a sampling value for rendering.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_enter_sampling_help_event, event
 text = ''
 nv_help, 'grim_menu_render_enter_sampling_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_enter_sampling_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 done = 0
 repeat $
  begin
   response = dialog_input('New Sampling:', cancelled=cancelled)
   if(cancelled) then return
   if(keyword_set(response)) then $
    begin
     w = str_isfloat(response)
     if((n_elements(w) EQ 1) AND (w[0] NE -1)) then done = 1
    end
  endrep until(done)

 grim_set_menu_value, grim_data, 'grim_menu_render_enter_sampling_event', response

 plane.render_sampling = long(response)
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_enter_minimum_event
;
;
; PURPOSE:
;   This option prompts the user to enter a minimum data value (0-1) for 
;   renderings.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_enter_minimum_help_event, event
 text = ''
 nv_help, 'grim_menu_render_enter_minimum_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_enter_minimum_event, event
@grim_block.include
 grim_set_primary, event.top

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 done = 0
 repeat $
  begin
   response = dialog_input('New Minimum %:', cancelled=cancelled)
   if(cancelled) then return
   if(keyword_set(response)) then $
    begin
     w = str_isfloat(response)
     if((n_elements(w) EQ 1) AND (w[0] NE -1)) then done = 1
    end
  endrep until(done)

 grim_set_menu_value, $
           grim_data, 'grim_menu_render_enter_minimum_event', response, suffix='%'

 plane.render_minimum = double(response)
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_toggle_current_plane_event
;
;
; PURPOSE:
;	Toggles rednering from the current plane on/off.  If off, rendering
;	data are taken from any map projections found by PG_LOAD_MAPS. When 
;	toggled on, the current data descriptor and camera descriptor are 
;	cloned and saved for use as the rendering source.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_toggle_current_plane_help_event, event
 text = ''
 nv_help, 'grim_menu_render_toggle_current_plane_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_toggle_current_plane_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'RENDER_CURRENT')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'RENDER_CURRENT', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_render_toggle_current_plane_event', flag

 plane.render_current = flag


 if(flag EQ 0) then $
  begin
   nv_free, [plane.render_dd, plane.render_cd]
   plane.render_dd = obj_new()
   plane.render_cd = obj_new()
   grim_set_plane, grim_data, plane
   return
  end

 plane.render_dd = nv_clone(plane.dd)
 plane.render_cd = nv_clone(grim_xd(plane, /cd))
 grim_set_plane, grim_data, plane


 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_toggle_spawn_event
;
;
; PURPOSE:
;	Toggles spawning of a new plane for each rendering on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_toggle_spawn_help_event, event
 text = ''
 nv_help, 'grim_menu_render_toggle_spawn_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_toggle_spawn_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'RENDER_SPAWN')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'RENDER_SPAWN', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_render_toggle_spawn_event', flag

 plane.render_spawn = flag
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_toggle_sky_event
;
;
; PURPOSE:
;	Toggles sky rendering on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2017
;	
;-
;=============================================================================
pro grim_menu_render_toggle_sky_help_event, event
 text = ''
 nv_help, 'grim_menu_render_toggle_sky_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_toggle_sky_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'RENDER_SKY')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'RENDER_SKY', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_render_toggle_sky_event', flag

 plane.render_sky = flag
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_toggle_auto_event
;
;
; PURPOSE:
;	Toggles automatic rendering on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_menu_render_toggle_auto_help_event, event
 text = ''
 nv_help, 'grim_menu_render_toggle_auto_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_toggle_auto_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'RENDER_AUTO')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'RENDER_AUTO', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_render_toggle_auto_event', flag

 if(grim_get_toggle_flag(grim_data, 'RENDER_AUTO')) then $
                                grim_render, grim_data, plane=plane

 plane.render_auto = flag
 grim_set_plane, grim_data, plane

 grim_update_menu, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_event
;
;
; PURPOSE:
;	Renders the visible scene and places it in a new plane unless
;	the current plane is already a rendering. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;=============================================================================
pro grim_menu_render_help_event, event
 text = ''
 nv_help, 'grim_menu_render_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_render, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_colors_event
;
;
; PURPOSE:
;	Opens gr_colortool. 
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
pro grim_menu_view_colors_help_event, event
 text = ''
 nv_help, 'grim_menu_view_colors_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_colors_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 grim_modify_colors, grim_data

end
;=============================================================================



;=============================================================================
;
; OVERLAYS MENU
;	
;
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_centers_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	center positions using pg_center for all active globes.  If no
;	active objects, then all centers are computed.
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
pro grim_menu_points_centers_help_event, event
 text = ''
 nv_help, 'grim_menu_points_centers_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_centers_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute centers
 ;------------------------------------------------
 grim_overlay, grim_data, 'CENTER'
; grim_centers, grim_data

 ;------------------------------------------------
 ; draw centers
 ;------------------------------------------------
; grim_draw, grim_data, /center, /label
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_limbs_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	limbs using pg_limbs for all active objects.  If no active objects, 
;	then all limbs are computed.
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
pro grim_menu_points_limbs_help_event, event
 text = ''
 nv_help, 'grim_menu_points_limbs_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_limbs_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute limbs
 ;------------------------------------------------
 grim_overlay, grim_data, 'LIMB'
; grim_limbs, grim_data

 ;------------------------------------------------
 ; draw limbs
 ;------------------------------------------------
; grim_draw, grim_data, /limb
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_terminators_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	terminators using pg_limb with the lights as the observer for all active
;	objects.  If no active objects, then all terminators are computed.
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
pro grim_menu_points_terminators_help_event, event
 text = ''
 nv_help, 'grim_menu_points_terminators_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_terminators_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute terminators
 ;------------------------------------------------
 grim_overlay, grim_data, 'TERMINATOR'
; grim_terminators, grim_data

 ;------------------------------------------------
 ; draw terminators
 ;------------------------------------------------
; grim_draw, grim_data, /term
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_planet_grids_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	planet grids using pg_grid for all active objects.  If no active
;	objects, then all grids are computed.
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
pro grim_menu_points_planet_grids_help_event, event
 text = ''
 nv_help, 'grim_menu_points_planet_grids_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_planet_grids_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'PLANET_GRID'
; grim_planet_grids, grim_data

 ;------------------------------------------------
 ; draw planet grids
 ;------------------------------------------------
; grim_draw, grim_data, /plgrid
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_rings_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	ring outlines using pg_disk. 
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
pro grim_menu_points_rings_help_event, event
 text = ''
 nv_help, 'grim_menu_points_rings_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_rings_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute rings
 ;------------------------------------------------
 grim_overlay, grim_data, 'RING'
;grim_rings, grim_data

 ;------------------------------------------------
 ; draw rings
 ;------------------------------------------------
; grim_draw, grim_data, /ring
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_ring_grids_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	ring grids using pg_grid for all active objects.  If no active
;	objects, then all grids are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2004
;	
;-
;=============================================================================
pro grim_menu_points_ring_grids_help_event, event
 text = ''
 nv_help, 'grim_menu_points_ring_grids_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_ring_grids_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

; grim_interrupt_begin, grim_data

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'RING_GRID'

 ;------------------------------------------------
 ; draw planet grids
 ;------------------------------------------------
 grim_refresh, grim_data, /use_pixmap

; grim_interrupt_end, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_stations_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	planet stations for all active objects.  If no active objects, then 
;	all stations are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2009
;	
;-
;=============================================================================
pro grim_menu_points_stations_help_event, event
 text = ''
 nv_help, 'grim_menu_points_stations_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_stations_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'STATION'

 ;------------------------------------------------
 ; draw stations
 ;------------------------------------------------
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_arrays_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	arrays for all active objects.  If no active objects, then 
;	all arrays are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2012
;	
;-
;=============================================================================
pro grim_menu_points_arrays_help_event, event
 text = ''
 nv_help, 'grim_menu_points_arrays_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_arrays_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'ARRAY'

 ;------------------------------------------------
 ; draw arrays
 ;------------------------------------------------
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_stars_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	star positions using pg_center. 
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
pro grim_menu_points_stars_help_event, event
 text = ''
 nv_help, 'grim_menu_points_stars_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_stars_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute stars
 ;------------------------------------------------
 grim_overlay, grim_data, 'STAR'

 ;------------------------------------------------
 ; draw stars
 ;------------------------------------------------
; grim_draw, grim_data, /star, /label
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_shadows_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	shadows of the currently active overlay points on all other objects. 
;	Note that you may have to disable overlay hiding in order to compute
;	and activate all of the appropriate source points for the shadows
;	since many point that are not visible to the observer may still have
;	a line of sight to the lights.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2003
;	
;-
;=============================================================================
pro grim_menu_points_shadows_help_event, event
 text = ''
 nv_help, 'grim_menu_points_shadows_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_shadows_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute shadows
 ;------------------------------------------------
 grim_overlay, grim_data, 'SHADOW'
;grim_shadows, grim_data

 ;------------------------------------------------
 ; draw shadow
 ;------------------------------------------------
; grim_draw, grim_data, /shadow
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_reflections_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	reflections of the currently active overlay points on all other objects. 
;	Note that you may have to disable overlay hiding in order to compute
;	and activate all of the appropriate source points for the reflections
;	since many point that are not visible to the observer may still have
;	a line of sight to the lights.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2003
;	
;-
;=============================================================================
pro grim_menu_points_reflections_help_event, event
 text = ''
 nv_help, 'grim_menu_points_reflections_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_reflections_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute reflections
 ;------------------------------------------------
 grim_overlay, grim_data, 'REFLECTION'
;grim_reflections, grim_data

 ;------------------------------------------------
 ; draw reflection
 ;------------------------------------------------
; grim_draw, grim_data, /reflection
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_hide_all_event
;
;
; PURPOSE:
;	 Hides/unhides all overlay objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2003
;	
;-
;=============================================================================
pro grim_menu_hide_all_help_event, event
 text = ''
 nv_help, 'grim_menu_hide_all_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_hide_all_event, event

 grim_data = grim_get_data(event.top)

 grim_set_primary, grim_data.base
 grim_hide_overlays, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_clear_all_event
;
;
; PURPOSE:
;	 Clears all objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_clear_all_help_event, event
 text = ''
 nv_help, 'grim_menu_clear_all_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_clear_all_event, event

 grim_message, /question, result=result, $
           ['Are you sure you want to clear all overlays?']
 if(result NE 'Yes') then return


 grim_data = grim_get_data(event.top)
 grim_clear_objects, grim_data, /all

 grim_refresh, grim_data, /use_pixmap
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_clear_active_event
;
;
; PURPOSE:
;	 Clears all active objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_clear_active_help_event, event
 text = ''
 nv_help, 'grim_menu_clear_active_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_clear_active_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_clear_active_overlays, grim_data, plane
 grim_clear_active_user_overlays, plane


 grim_refresh, grim_data, /use_pixmap
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_activate_all_event
;
;
; PURPOSE:
;	 Activates all objects.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_activate_all_help_event, event
 text = ''
 nv_help, 'grim_menu_activate_all_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_activate_all_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_activate_all, grim_data, plane
 grim_refresh, grim_data, /no_image

 return
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_deactivate_all_event
;
;
; PURPOSE:
;	 Deactivates all objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_deactivate_all_help_event, event
 text = ''
 nv_help, 'grim_menu_deactivate_all_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_deactivate_all_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_deactivate_all, grim_data, plane
 grim_refresh, grim_data, /no_image

 return
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_invert_all_event
;
;
; PURPOSE:
;	 Inverts current overlay activations.  Desccriptor activations are
;	 determined by the resulting overlay activations. 
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
pro grim_menu_invert_all_help_event, event
 text = ''
 nv_help, 'grim_menu_invert_all_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_invert_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_invert_all_overlays, grim_data, plane

 grim_refresh, grim_data, /no_image
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_overlay_settings_event
;
;
; PURPOSE:
;	Allows the user modify settings relevant to the overlay points.  
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
pro grim_menu_overlay_settings_help_event, event
 text = ''
 nv_help, 'grim_menu_overlay_settings_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_overlay_settings_event, event
@grim_block.include

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_overlay_settings, grim_data, plane

end
;=============================================================================



