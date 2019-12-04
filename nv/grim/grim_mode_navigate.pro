;=============================================================================
; grim_mode_navigate_bitmap
;
;=============================================================================
function grim_mode_navigate_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [127B, 254B],                   $
                [071B, 249B],                   $
                [127B, 231B],                   $
                [067B, 223B],                   $
                [127B, 231B],                   $
                [071B, 249B],                   $
                [127B, 254B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]


end
;=============================================================================



;=============================================================================
; grim_mode_navigate_get_body
;
;=============================================================================
function grim_mode_navigate_get_body, active=active, grim_data, plane=plane, $
                 cd, xy, points_ptd, curves_ptd, user_ptd, $
                 name=name, body_pt=body_pt, inertial_pt=inertial_pt


 name = ''

 if(keyword_set(active)) then $
  begin
   ptd = grim_ptd(plane, /active)
   if(keyword_set(ptd)) then $
    begin
     name = 'ACTIVE'
     vv = pnt_vectors(ptd, /cat)
     inertial_pt = reform(total(vv,1)/(n_elements(vv)/3), 1, 3)
     bx = nv_clone(grim_xd(plane, /cd))
     bod_set_pos, bx, inertial_pt
    end
  end $
 else $
  begin 
   surf_pts = grim_image_to_surface(grim_data, plane, xy[*,0], $
				       bx=bx, names=names, body_pts=body_pts)
   if(keyword_set(surf_pts)) then $
    begin
     name = names[0]
     bx = bx[0]
     body_pt = body_pts[0,*]
     inertial_pt = bod_body_to_inertial_pos(bx, body_pt)
    end
  end 

 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd

 if(NOT keyword_set(name)) then return, 0
 return, bx
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_get_points
;
;=============================================================================
pro grim_mode_navigate_get_points, grim_data, plane=plane, $
                                        points_ptd, curves_ptd, user_ptd

 points_ptds = grim_ptd(plane, genre='POINT')
 curves_ptds = grim_ptd(plane, genre='CURVE')
 user_ptds = grim_get_user_ptd(plane=plane)

 points_ptd = pnt_compress(points_ptds)
 curves_ptd = pnt_compress(curves_ptds)
 user_ptd = pnt_compress(user_ptds, /nodata)

end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition
;
;=============================================================================
pro grim_mode_navigate_reposition, cd, cd0, curves_ptd, points_ptd, user_ptd, tracking, xarr, yarr, axes=axes

speed = 1

 ;-------------------------------------------
 ; update position
 ;-------------------------------------------
 nv_copy, cd, cd0

 xy = (convert_coord(double(xarr), double(yarr), /device, /to_data))[0:1,*]
 dxy = xy[*,1] - xy[*,0]

 dr = speed*dxy

 pos = bod_pos(cd)
 om = bod_orient(cd)

 pos = pos + $
         axes[0]*dr[0]*om[0,*] + axes[1]*dr[1]*om[1,*] + axes[2]*dr[1]*om[2,*]
 bod_set_pos, cd, pos


 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_xy
;
;=============================================================================
pro grim_mode_navigate_reposition_xy, data, xarr, yarr, pixmap, win_num
 grim_data = data.grim_data
 plane = grim_get_plane(grim_data)

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd

 cd0 = grim_xd(plane, /cd)

 scale = (cam_scale(cd))[0]
scale=1d
 grim_mode_navigate_reposition, cd, cd0, $
     curves_ptd, points_ptd, user_ptd, tracking, xarr, yarr, axes=[scale,-1,0]
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_xz_active
;
;=============================================================================
pro grim_mode_navigate_reposition_xz_active, data, xarr, yarr, pixmap, win_num
 grim_mode_navigate_reposition_xz, /active, data, xarr, yarr, pixmap, win_num
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_track_active
;
;=============================================================================
pro grim_mode_navigate_reposition_track_active, data, xarr, yarr, pixmap, win_num
common grim_mode_navigate_reposition_track_active_block, bx, name, inertial_pt0

 grim_data = data.grim_data
 plane = grim_get_plane(grim_data)

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd

 cd0 = grim_xd(plane, /cd)
 nv_copy, cd, cd0

 xy = (convert_coord(double(xarr), double(yarr), /device, /to_data))[0:1,*]


 ;-------------------------------------------
 ; get initial points
 ;-------------------------------------------
 if(p_mag(xy[*,1]-xy[*,0]) EQ 0) then $
  begin
   bx = grim_mode_navigate_get_body(/active, grim_data, plane=plane, $
                 cd, xy, points_ptd, curves_ptd, user_ptd, $
                 name=name, inertial_pt=inertial_pt0)
   return
  end
 if(NOT keyword_set(name)) then return



 ;------------------------------------------------------------------------------
 ; reposition cd such that:
 ;  - initial point stays fixed in the image plane
 ;  - cd distance from initial point stays constant
 ;------------------------------------------------------------------------------
rate = 2d*!dpi/500  ; rad/pixel

 dxy = xy[*,1]-xy[*,0]
 dphi = -dxy[0]*rate
 dtheta = dxy[1]*rate


 ;- - - - - - - - - - - - - - - - - - - -
 ; rotate cd position about bx center
 ;- - - - - - - - - - - - - - - - - - - -
 pos = bod_pos(cd)

 pos_body = bod_inertial_to_body_pos(bx, pos)
 orient = bod_orient(bx)
 xx = [[1],[0],[0]]
 zz = [[0],[0],[1]]

 pos_body = v_rotate(pos_body, xx, sin(dtheta), cos(dtheta))
 pos_body = v_rotate(pos_body, zz, sin(dphi), cos(dphi))

 bod_set_pos, cd, bod_body_to_inertial_pos(bx, pos_body)


 ;- - - - - - - - - - - - - - - - - - - -
 ; repoint cd 
 ;- - - - - - - - - - - - - - - - - - - -
 vcent0 = v_unit(bod_pos(bx) - bod_pos(cd0))
 vcent = v_unit(bod_pos(bx) - bod_pos(cd))

 M = v_rot(vcent0, vcent)
 bod_set_orient, cd, M##bod_orient(cd0)


 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd

;;;;; nv_free, bx
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_xz
;
;=============================================================================
pro grim_mode_navigate_reposition_xz, data, xarr, yarr, pixmap, win_num, active=active
common grim_mode_navigate_reposition_xz_block, name, bx, inertial_pt0

 grim_data = data.grim_data
 plane = grim_get_plane(grim_data)

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd

 cd0 = grim_xd(plane, /cd)
 nv_copy, cd, cd0

 xy = (convert_coord(double(xarr), double(yarr), /device, /to_data))[0:1,*]

 ;-------------------------------------------
 ; get initial point on first call
 ;-------------------------------------------
 if(p_mag(xy[*,1]-xy[*,0]) EQ 0) then $
  begin
   bx = grim_mode_navigate_get_body(active=active, grim_data, plane=plane, $
                 cd, xy, points_ptd, curves_ptd, user_ptd, $
                 name=name, inertial_pt=inertial_pt0)
   return
  end
 if(NOT keyword_set(name)) then return


 ;-------------------------------------------
 ; reposition camera
 ;-------------------------------------------
 dist = v_mag(inertial_pt0 - bod_pos(cd0))
 speed = dist*(cam_scale(cd))[0]

 grim_mode_navigate_reposition, $
          cd, cd0, curves_ptd, points_ptd, user_ptd, $
                                 tracking, xarr, yarr, axes=-[speed,0,speed]

;;;; if(keyword_set(active)) then nv_free, bx
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_track
;
;=============================================================================
pro grim_mode_navigate_reposition_track, data, xarr, yarr, pixmap, win_num
common grim_mode_navigate_reposition_track_block, name, bx, body_pt0

 grim_data = data.grim_data
 plane = grim_get_plane(grim_data)

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd

 cd0 = grim_xd(plane, /cd)
 nv_copy, cd, cd0

 xy = (convert_coord(double(xarr), double(yarr), /device, /to_data))[0:1,*]


 ;-------------------------------------------
 ; get surface point on first call
 ;-------------------------------------------
 if(p_mag(xy[*,1]-xy[*,0]) EQ 0) then $
  begin
   bx = grim_mode_navigate_get_body(grim_data, plane=plane, $
                 cd, xy, points_ptd, curves_ptd, user_ptd, $
                 name=name, body_pt=body_pt0)
   return
  end
 if(NOT keyword_set(name)) then return


 ;------------------------------------------------------------------------------
 ; reposition cd such that:
 ;  - bx center stays fixed in the image plane
 ;  - cd altitude above bx stays constant
 ;  - body_pt maps to xy[*,1] in image plane (i.e., body_pt stays under cursor)
 ;------------------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - - -
 ; get body intercept point
 ;- - - - - - - - - - - - - - - - - - - -
 body_pt = image_to_body(hit=hit, cd, bx, xy[*,1])

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if off body, put the point on the limb
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(hit[0] EQ -1) then $
  begin
   vxy = image_to_inertial(cd, xy)
   n = v_cross(vxy[0,*], vxy[1,*])
   v = v_cross(n,bod_pos(bx)-bod_pos(cd))
   body_pt = bod_inertial_to_body(bx, v)
  end

 ;- - - - - - - - - - - - - - - - - - - -
 ; rotate cd position about bx center
 ;- - - - - - - - - - - - - - - - - - - -
 body_pt = body_pt[0,*]

 n = v_unit(v_cross(body_pt, body_pt0))
 theta = v_angle(body_pt0, body_pt)

 pos = bod_pos(cd)
 pos_body = bod_inertial_to_body_pos(bx, pos)

 pos = v_rotate(pos_body, n, sin(theta), cos(theta))
 bod_set_pos, cd, bod_body_to_inertial_pos(bx, pos)

 ;- - - - - - - - - - - - - - - - - - - -
 ; adjust cd altitude above bx surface
 ;- - - - - - - - - - - - - - - - - - - -
 surf_pt0 = body_to_surface(bx, $
             bod_inertial_to_body_pos(bx, bod_pos(cd0)))
 surf_pt = body_to_surface(bx, $
             bod_inertial_to_body_pos(bx, bod_pos(cd)))
 n = surface_normal(bx, pos_body, body_pt)
 alt0 = surf_pt0[2]
 alt = surf_pt[2]
 bod_set_pos, cd, bod_pos(cd) + n*(alt-alt0)

 ;- - - - - - - - - - - - - - - - - - - -
 ; repoint cd 
 ;- - - - - - - - - - - - - - - - - - - -
 vcent0 = v_unit(bod_pos(bx) - bod_pos(cd0))
 vcent = v_unit(bod_pos(bx) - bod_pos(cd))

 M = v_rot(vcent0, vcent)
 bod_set_orient, cd, M##bod_orient(cd0)


 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_draw
;
;=============================================================================
pro grim_mode_navigate_draw, wnum, pixmap, erase_pixmap, cd, $
                                        curves_ptd, points_ptd, user_ptd

 wset, pixmap
 device, copy=[0,0, !d.x_size,!d.y_size, 0,0, erase_pixmap]
 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd
 wset, wnum
 device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]

end
;=============================================================================



;=============================================================================
; grim_mode_navigate_nadir_zenith
;
;=============================================================================
pro grim_mode_navigate_nadir_zenith, grim_data, dir, event


 plane = grim_get_plane(grim_data)

 ;-------------------------------------------
 ; get surface point
 ;-------------------------------------------
 p = (convert_coord(double(event.x), double(event.y), /device, /to_data))[0:1]
 surf_pt = grim_image_to_surface(grim_data, plane, p, $
                                         bx=bx, names=names, body_pt=body_pt)
 if(NOT keyword_set(surf_pt)) then return
 surf_pos = bod_body_to_inertial_pos(bx, body_pt)


 ;-------------------------------------------
 ; get current altitude above bx
 ;-------------------------------------------
 cd = grim_xd(plane, /cd)
 cam_pos_surf = inertial_to_surface_pos(bx, bod_pos(cd))


 ;-------------------------------------------
 ; reposition camera above selected location
 ;-------------------------------------------
 surf_pt[2] = cam_pos_surf[2]
 new_pos = surface_to_inertial_pos(bx, surf_pt)
 bod_set_pos, cd, new_pos


 ;-------------------------------------------
 ; repoint camera
 ;-------------------------------------------
 pg_repoint, cd=cd, dir*v_unit(new_pos - surf_pos)

end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_y_event
;
;=============================================================================
pro grim_mode_navigate_reposition_y_event, event
common grim_mode_navigate_reposition_y_block, name, bx, inertial_pt0

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 data = *grim_data.misc_data_p
 struct = tag_names(event, /struct)

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd
 event_pro = data.event_pro
 wnum = data.wnum
 pixmap = data.pixmap
 erase_pixmap = data.erase_pixmap
 active = data.active

 ;---------------------------------------------------------------
 ; quit and restore main handler if not wheel or motion event
 ;---------------------------------------------------------------
 done = 0
 if(struct NE 'WIDGET_DRAW') then done = 1 $
 else if((event.type NE 7) AND (event.type NE 2)) then done = 1 $
 else if(NOT keyword_set(event.modifiers)) then done = 1

 if(done) then $
  begin
   nv_copy, grim_xd(plane, /cd), cd
   nv_free, [cd, curves_ptd, points_ptd]				;;;;;
   widget_control, grim_data.draw, event_pro=event_pro
   wdelete, pixmap
   wdelete, erase_pixmap
   bx = 0
   return
  end


 p0 = (convert_coord(double(event.x), double(event.y), /device, /to_data))[0:1]

 ;-------------------------------------------
 ; get body on first call
 ;-------------------------------------------
 if(NOT keyword_set(bx)) then $
  begin
   bx = grim_mode_navigate_get_body(active=active, grim_data, plane=plane, $
                 cd, p0, points_ptd, curves_ptd, user_ptd, $
                 name=name, inertial_pt=inertial_pt0)
   return
  end
 if(NOT keyword_set(name)) then return
 if(name EQ 'SKY') then return


 ;---------------------------------------------------------------
 ; determine speed
 ;---------------------------------------------------------------
 alt = v_mag(bod_pos(cd) - inertial_pt0)
 speed = alt[0]*0.1


 ;---------------------------------------------------------------
 ; move along click direction
 ;---------------------------------------------------------------
 dm = event.clicks

 v = image_to_inertial(cd, p0)

 pos = bod_pos(cd)
 pos = pos + v*speed*dm
 bod_set_pos, cd, pos


 ;---------------------------------------------------------------
 ; draw points
 ;---------------------------------------------------------------
 grim_mode_navigate_draw, wnum, pixmap, erase_pixmap, cd, $
                                       curves_ptd, points_ptd, user_ptd

;;;; if(keyword_set(active)) then nv_free, bx
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reposition_y
;
;=============================================================================
pro grim_mode_navigate_reposition_y, grim_data, active=active

 active = keyword_set(active)
 plane = grim_get_plane(grim_data)

 grim_mode_navigate_get_points, grim_data, $
                               plane=plane, points_ptd, curves_ptd, user_ptd
 cd = nv_clone(grim_xd(plane, /cd))

 ;-----------------------------------------------
 ; temporarily replace main event handler
 ;-----------------------------------------------
 event_pro = widget_info(grim_data.draw, /event_pro)
 widget_control, grim_data.draw, event_pro='grim_mode_navigate_reposition_y_event'

 ;-----------------------------------------------
 ; set up display maps
 ;-----------------------------------------------
 wnum = !d.window

 window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
 pixmap = !d.window

 window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
 erase_pixmap = !d.window
 device, copy=[0,0, !d.x_size,!d.y_size, 0,0, wnum]

 grim_mode_navigate_draw, $
           wnum, pixmap, erase_pixmap, cd, curves_ptd, points_ptd, user_ptd


 *grim_data.misc_data_p = $
          {cd:cd, $
           active:active, $
           curves_ptd:curves_ptd, $
           points_ptd:points_ptd, $
           user_ptd:user_ptd, $
           event_pro:event_pro, $
           wnum:wnum, $
           pixmap:pixmap, $
           erase_pixmap:erase_pixmap}

end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reorient_nod
;
;=============================================================================
pro grim_mode_navigate_reorient_nod, data, xarr, yarr, pixmap, win_num
 grim_data = data.grim_data
 plane = grim_get_plane(grim_data)

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd

 cd0 = grim_xd(plane, /cd)

 xy = (convert_coord(double(xarr), double(yarr), /device, /to_data))[0:1,*]
 dxy = xy[*,1] - xy[*,0]

 nv_copy, cd, cd0
 cam_reorient, cd, [0,0], dxy, 0

 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_reorient_twist
;
;=============================================================================
pro grim_mode_navigate_reorient_twist, data, xarr, yarr, pixmap, win_num
common grim_mode_navigate_reorient_twist_block, p0
 grim_data = data.grim_data
 plane = grim_get_plane(grim_data)

 minpix = 10

 curves_ptd = data.curves_ptd
 points_ptd = data.points_ptd
 user_ptd = data.user_ptd
 cd = data.cd

 cd0 = grim_xd(plane, /cd)

 xy = (convert_coord(double(xarr), double(yarr), /device, /to_data))[0:1,*]

 dxyarr = [xarr[1]-xarr[0], yarr[1]-yarr[0]]
 dxy = xy[*,1] - xy[*,0]

 ;---------------------------------------------
 ; no rotation if too close to origin point
 ;---------------------------------------------
 if(p_mag(dxyarr) LT minpix) then p0 = 0 $
 ;---------------------------------------------
 ; otherwise rotate about origin point
 ;---------------------------------------------
 else $
  begin
   if(NOT keyword_set(p0)) then p0 = xy[*,1]

   r0 = p0 - xy[*,0]
   r1 = xy[*,1] - xy[*,0]
   theta0 = atan(r0[1,*], r0[0,*])
   theta1 = atan(r1[1,*], r1[0,*])
   dtheta = theta1 - theta0

   nv_copy, cd, cd0
   cam_reorient, cd, xy[*,0], [0,0], dtheta

  end

 grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd
end
;=============================================================================



;=============================================================================
; grim_mode_navigate_mouse_event
;
;=============================================================================
pro grim_mode_navigate_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 if(NOT keyword_set(grim_xd(plane, /cd))) then return

 ;---------------------------------------
 ; scroll wheel -- adjust distance
 ;---------------------------------------
 if(event.type EQ 7) then $
  begin
   active = 0
   if(event.modifiers EQ 3) then active = 1 $
   else if(event.modifiers NE 1) then return

   grim_refresh, grim_data, plane=plane, /use_pixmap, /no_objects
   grim_mode_navigate_reposition_y, grim_data, active=active

   return
  end

 if(event.type NE 0) then return


 ;---------------------------------------
 ; nadir/zenith mode
 ;---------------------------------------
 if(event.modifiers EQ 2) then $
  begin
   dir = event.press EQ 1 ? -1 : 1
   grim_mode_navigate_nadir_zenith, grim_data, dir, event
   return
  end


 ;---------------------------------------
 ; get points
 ;---------------------------------------
 grim_mode_navigate_get_points, grim_data, plane=plane, $
                                            points_ptd, curves_ptd, user_ptd
 cd = nv_clone(grim_xd(plane, /cd))
 p0 = [event.x, event.y]

 fn = ''
 fn_data = {curves_ptd:curves_ptd, $
            points_ptd:points_ptd, $
            user_ptd:user_ptd, $
            cd:cd, $
            grim_data:grim_data}

 grim_refresh, grim_data, plane=plane, /use_pixmap, /noglass, $
                                             overlay_color=ctgray(0.25)


 ;- - - - - - - - - - - - - - - - - - -
 ; activation mode
 ;- - - - - - - - - - - - - - - - - - -
 if(event.modifiers EQ 3) then $
     fn = event.press EQ 1 ? 'reposition_xz_active' : 'reposition_track_active' $
 ;- - - - - - - - - - - - - - - - - - -
 ; reposition mode
 ;- - - - - - - - - - - - - - - - - - -
 else if(event.modifiers EQ 1) then $
        fn = event.press EQ 1 ? 'reposition_xz' : 'reposition_track' $
 ;- - - - - - - - - - - - - - - - - - -
 ; reorient mode
 ;- - - - - - - - - - - - - - - - - - -
 else fn = event.press EQ 1 ? 'reorient_nod' : 'reorient_twist'

 if(keyword_set(fn)) then $
       pp = tvline(p0=p0, fn_draw='grim_mode_navigate_'+fn, fn_data=fn_data)



 nv_copy, grim_xd(plane, /cd), cd
 nv_free, [cd, points_ptd, curves_ptd]			;;;;;

end
;=============================================================================



;=============================================================================
; grim_mode_navigate_mode
;
;=============================================================================
pro grim_mode_navigate_mode, grim_data, data_p

 device, cursor_standard = 142
 grim_print, grim_data, $
      'NAVIGATE CAMERA -- L:Nod R:Twist <Shift> L:XZ R:Track WHEEL:Y <Ctrl> L:Nadir R:Zenith'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_navigate_button_event
;
;
; PURPOSE:
;	Selects the navigate cursor mode.  
;
;	 No modifiers: 
;	   Left:	Repoint the camera by dragging the cursor.
;
;	   Right:	Twists the camera by dragging the cursor about 
;			an axis corresponding to the initial cursor 
;			position.
;
;	 <Shift>:
;	   Left:	Repositions the camera in the X-Z plane 
;			(image plane) by dragging the cursor.  Speed 
;			depends on the initial object under the cursor.
;
;	   Right:	Repositions and reorients the camera
;			simultaneously by tracking the object under 
;			the cursor.
;
;	   Wheel:	Repositions the camera in the Y (optic axis) 
;			direction.  Speed depends on the initial object 
;			under the cursor.
;
;
;	 <Shift+Ctrl>:	Same as <Shift> functions, except applied to 
;			active points.
;	   
;
;	 <Ctrl>:
;	   Left:	Repositions the camera directly above the selected
;			body location at the current altitude, pointing 
;			straight down.
;
;	   Right:	Repositions the camera directly above the selected
;			body location at the current altitude, pointing 
;			straight up.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Allow the user to fly around the system.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2009
;	
;-
;=============================================================================
pro grim_mode_navigate_button_help_event, event
 text = ''
 nv_help, 'grim_mode_navigate_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_navigate_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Fly through system'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_navigate', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_navigate_init
;
;=============================================================================
pro grim_mode_navigate_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_navigate
;
;=============================================================================
function grim_mode_navigate, arg

 data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_navigate', $
		 event_pro:	'grim_mode_navigate_button_event', $
                 bitmap:	 grim_mode_navigate_bitmap(), $
                 menu:		'Navigate', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
