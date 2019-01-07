;=============================================================================
; grim_set_overlay_update_flag
;
;=============================================================================
pro grim_set_overlay_update_flag, ptd, value

 if(NOT keyword_set(ptd)) then return

 nptd = n_elements(ptd)
 for i=0, nptd-1 do if(obj_valid(ptd[i])) then $
   cor_set_udata, ptd[i], 'GRIM_UPDATE_FLAG', value, /noevent

end
;=============================================================================



;=============================================================================
; grim_get_overlay_update_flag
;
;=============================================================================
function grim_get_overlay_update_flag, ptd

 if(NOT keyword_set(ptd)) then return, 0

 nptd = n_elements(ptd)
 vals = bytarr(nptd)

 for i=0, nptd-1 do vals[i] = cor_udata(ptd[i], 'GRIM_UPDATE_FLAG', /noevent)

 return, vals
end
;=============================================================================



;=============================================================================
; grim_get_updated_ptd
;
;=============================================================================
function grim_get_updated_ptd, _ptd, ii=ii, clear=clear

 ii = 0

 ptd = 0
 nptd = n_elements(_ptd)

 for i=0, nptd-1 do $
  begin
   val = grim_get_overlay_update_flag(_ptd[i])
   if(val[0] EQ 1) then $
    begin
     ptd = append_array(ptd, _ptd[i])
     ii = append_array(ii, [i])
    end
  end

 if(keyword_set(clear)) then grim_set_overlay_update_flag, ptd, 0

 if(NOT keyword__set(ii)) then ii = -1			; need keyword__set here!

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_update_activations
;
;=============================================================================
pro grim_update_activations, grim_data, plane=plane, no_sync=no_sync

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ptdp = grim_ptd(plane, /pointer) 

 ;------------------------------------------
 ; clear all xd activations
 ;------------------------------------------
 for i=0, n_elements(ptdp)-1 do $
  if(keyword_set(*ptdp[i])) then $
   begin
    ptd = *ptdp[i]
    assoc_xd = pnt_assoc_xd(ptd)
    w = where(obj_valid(assoc_xd))
    if(w[0] NE -1) then grim_activate_xd, plane, assoc_xd[w], /deactivate
   end

 ;--------------------------------------------------------------
 ; activate xds for which any associated overlays are active
 ;--------------------------------------------------------------
 for i=0, n_elements(ptdp)-1 do $
  if(keyword_set(*ptdp[i])) then $
   begin
    ptd = *ptdp[i]
    assoc_xd = pnt_assoc_xd(ptd)
    w = where(obj_valid(assoc_xd))
    if(w[0] NE -1) then $
     begin
      ptd = ptd[w]
      assoc_xd = assoc_xd[w]
      active = cor_udata(ptd, 'GRIM_ACTIVE_FLAG', /noevent)
      w = where(active)
      if(w[0] NE -1) then grim_activate_xd, plane, assoc_xd[w]
     end
   end

 ;--------------------------------------------------------------
 ; copy activations
 ;--------------------------------------------------------------
 if(NOT keyword_set(no_sync)) then $
   if(grim_get_toggle_flag(grim_data, 'ACTIVATION_SYNCING')) then $
                                 grim_copy_activations, grim_data, plane=plane

end
;=============================================================================



;=============================================================================
; grim_add_activation_callback
;
;=============================================================================
pro grim_add_activation_callback, callbacks, data_ps, top=top, no_wset=no_wset

 grim_data = grim_get_data(top, no_wset=no_wset)

 act_callbacks = *grim_data.act_callbacks_p
 act_data_ps = *grim_data.act_callbacks_data_pp

 grim_add_callback, callbacks, data_ps, act_callbacks, act_data_ps

 *grim_data.act_callbacks_p = act_callbacks
 *grim_data.act_callbacks_data_pp = act_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_rm_activation_callback
;
;=============================================================================
pro grim_rm_activation_callback, data_ps, top=top

 grim_data = grim_get_data(top)
 if(NOT grim_exists(grim_data)) then return

 act_callbacks = *grim_data.act_callbacks_p
 act_data_ps = *grim_data.act_callbacks_data_pp

 grim_rm_callback, data_ps, act_callbacks, act_data_ps

 *grim_data.act_callbacks_p = act_callbacks
 *grim_data.act_callbacks_data_pp = act_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_call_activation_callbacks
;
;=============================================================================
pro grim_call_activation_callbacks, plane, ptd, deactivate=deactivate

 grim_data = grim_get_data(grn=plane.grn)
 grim_call_callbacks, *grim_data.act_callbacks_p, $
         *grim_data.act_callbacks_data_pp, {ptd:ptd, deactivate:deactivate}

end
;=============================================================================



;=============================================================================
; grim_draw_standard_points
;
;=============================================================================
pro grim_draw_standard_points, grim_data, plane, _ptd, name, data, color, tshade, shade, $
                            psym=psym, psize=symsize, plabels=plabels, label_shade=label_shade
 ptd = pnt_cull(_ptd, /nofree)
 if(NOT keyword_set(ptd)) then return

if(symsize LE 0) then $
 begin
  psize = call_function('grim_symsize_'+ name, data, ptd)
  if(psize[0] NE -1) then symsize = abs(symsize)*psize $
  else symsize = 1
 end


 if(NOT tshade) then shade = 1.0 $
 else shade = call_function('grim_shade_'+ name, data, ptd)
 col = make_array(n_elements(shade), val=color)

 pg_draw, ptd, col=col, shades=shade, label_color='yellow', $
           label_shade=label_shade, psym=psym, psize=symsize, plabels=plabels


end
;=============================================================================



;=============================================================================
; grim_draw_standard_overlays
;
;=============================================================================
pro grim_draw_standard_overlays, grim_data, plane, inactive_color, $
       update=update, mlab=mlab, override_color=override_color

  names = (*plane.overlays_p).name
  for i=0, n_elements(names)-1 do $
   begin
    name = names[i]
    info = grim_ptd_info(plane, type=name, $
	     color=color, psym=psym, symsize=symsize, shade=shade, tlab=tlab, $
	     tshade=tshade, data=data)
    if(keyword_set(color)) then $
     if(strlowcase(color) NE 'hidden') then $
      begin
       if(keyword_set(plane.override_color) $
        	 AND (strupcase(plane.override_color) NE 'NONE')) then $
        					  color = plane.override_color
       if(keyword_set(override_color)) then $
        		      color = (inactive_color = override_color)

       active_ptd = grim_ptd(plane, type=name, /active)
       inactive_ptd = grim_ptd(plane, type=name, /inactive)

;       if(symsize LE 0) then $
;        begin
;         _symsize = call_function('grim_symsize_'+ name, data)
;         if(_symsize[0] NE -1) then symsize = abs(symsize)*_symsize $
;         else symsize = 1
;        end

       ;- - - - - - - - - - - - - - - - - - - - - - -
       ; determine which overlays to actually draw
       ;- - - - - - - - - - - - - - - - - - - - - - -
       active_plabels = cor_name(active_ptd)
       if(NOT keyword_set(mlab) OR  NOT tlab) then active_plabels[*] = ''
       if(keyword_set(update)) then $
        begin
         active_ptd = grim_get_updated_ptd(active_ptd, ii=ii, /clear)
         if(keyword_set(active_ptd)) then active_plabels = active_plabels[ii]
        end

       inactive_plabels = cor_name(inactive_ptd)
       if(NOT keyword_set(mlab) OR  NOT tlab) then inactive_plabels[*] = ''
       if(keyword_set(update)) then $
        begin
         inactive_ptd = grim_get_updated_ptd(inactive_ptd, ii=ii, /clear)
         if(keyword_set(inactive_ptd)) then inactive_plabels = inactive_plabels[ii]
        end

       ;- - - - - - - - - - - - - - -
       ; inactive points
       ;- - - - - - - - - - - - - - -
       if(keyword_set(inactive_ptd)) then $
           grim_draw_standard_points, grim_data, plane, $
              inactive_ptd, name, data, inactive_color, tshade, shade, $
              psym=psym, psize=symsize, plabels=inactive_plabels, label_shade=0.5

       ;- - - - - - - - - - - - - - -
       ; active points
       ;- - - - - - - - - - - - - - -
       if(keyword_set(active_ptd)) then $
           grim_draw_standard_points, grim_data, plane, $
              active_ptd, name, data, color, tshade, shade, $
              psym=psym, psize=symsize, plabels=active_plabels, label_shade=1.0
      end
   end


end
;=============================================================================



;=============================================================================
; grim_draw_user_points
;
;=============================================================================
pro grim_draw_user_points, grim_data, plane, tags, inactive_color, xmap=xmap, $
                          override_color=override_color, noxgraphics=noxgraphics

 ;-------------------------------------
 ; draw each user array
 ;-------------------------------------
 for i=0, n_elements(tags)-1 do $
  begin
   ;- - - - - - - - - - - - - - - - - -
   ; get user array
   ;- - - - - - - - - - - - - - - - - -
   user_ptd = grim_get_user_ptd(plane=plane, tags[i], user_struct=user_struct)

   user_color = user_struct.color
   if(keyword_set(override_color)) then user_color = override_color

   user_fn_shade = user_struct.fn_shade
   user_fn_color = user_struct.fn_color
   user_shade_threshold = user_struct.shade_threshold
   user_fn_graphics = user_struct.fn_graphics
   user_xgraphics = user_struct.xgraphics
   user_psym = user_struct.psym
   user_thick = user_struct.thick
   user_line = user_struct.line
   user_symsize = user_struct.symsize

   np = n_elements(user_ptd)
   if(keyword_set(inactive_color)) then $
                            user_color = make_array(np, val=inactive_color)

   for j=0, np-1 do $
    begin
     ;- - - - - - - - - - - - - - - - - -
     ; draw only if not hidden
     ;- - - - - - - - - - - - - - - - - -
     draw = 0
     if(size(user_color, /type) NE 7) then draw = 1 $
     else if(strlowcase(user_color[j]) NE 'hidden') then draw = 1
     if(draw) then $
      begin
       ;- - - - - - - - - - - - - - - - - -
       ; get shade values
       ;- - - - - - - - - - - - - - - - - -
       shade = 1d

       if(keyword_set(user_fn_shade[j])) then $
          shade = call_function(user_fn_shade[j], user_ptd[j], grim_data, plane)


       ;- - - - - - - - - - - - - - - - - - - -
       ; determine which points are visible
       ;- - - - - - - - - - - - - - - - - - - -
       if(keyword_set(user_fn_shade[j]) AND defined(user_shade_threshold[j])) then $
               p = grim_shade_threshold(user_ptd[j], shade, user_shade_threshold[j], sub=sub) $
       else p = pnt_points(user_ptd[j], /visible)

       ;- - - - - - - - - - - - - - - - - - - -
       ; proceed with visible points
       ;- - - - - - - - - - - - - - - - - - - -
       if(keyword_set(p)) then $
        begin
         ;- - - - - - - - - - - - - - - - - - - -
         ; parse user color
         ;- - - - - - - - - - - - - - - - - - - -
         if((str_isnum(strtrim(user_color[j],2)))[0] EQ -1) then $
          begin
            ucol = ctcolor(user_color[j], shade)
            uxcol = ctcolor(user_color[j])
          end $
         else ucol = (uxcol = long(user_color[j]))

         if(keyword_set(user_fn_color[j])) then $
          begin
           uxcol = call_function(user_fn_color[j], user_ptd[j], grim_data, plane)
           if(defined(sub)) then uxcol = uxcol[sub]
           ucol = uxcol
          end

         ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         ; draw points using standard plotting or add to xgraphics map
         ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         if(keyword_set(user_xgraphics[j])) then $
          begin
           if(NOT keyword_set(noxgraphics)) then $
                 shade = xshade(p, shade, map=xmap, color=uxcol, /getmap, /tv)
          end $
         else $
          pg_draw, p, col=ucol, psym=user_psym[j], $
               thick=user_thick[j], line=user_line[j], psize=user_symsize[j], $
               graphics=user_fn_graphics[j]
        end
      end
    end
  end


end
;=============================================================================



;=============================================================================
; grim_match_user_tags
;
;=============================================================================
function grim_match_user_tags, tags, select_tags, sub=sub

 sub = -1
 if(NOT keyword_set(tags)) then return, ''

 nsel = n_elements(select_tags)
 nmid = make_array(nsel, val=1024)

 last = strmid(str_flip(select_tags), 0, 1)
 w = where(last EQ '*')
 if(w[0] NE -1) then nmid[w] = strlen(select_tags[w])-1
 
 for i=0, nsel-1 do $
  sub = append_array(sub, $
         where(strmid(tags, 0, nmid[i]) EQ strmid(select_tags[i], 0, nmid[i])), /def)
  
 sub = unique(sub)
 w = where(sub NE -1)
 if(w[0] EQ -1) then return, ''

 sub = sub[w]
 return, tags[sub]
end
;=============================================================================



;=============================================================================
; grim_draw_user_overlays
;
;=============================================================================
pro grim_draw_user_overlays, grim_data, plane, inactive_color, $
              override_color=override_color, noxgraphics=noxgraphics, tags=tags

 xmap = 0

 ;--------------------------------------------------
 ; draw user points
 ;--------------------------------------------------
 if(keyword_set(plane.user_ptd_tlp)) then $
  begin
   active_user_ptd = grim_get_active_user_overlays(plane, inactive_user_ptd)
;   active_tags = unique(cor_name(active_user_ptd))
;   inactive_tags = unique(cor_name(inactive_user_ptd))
   active_tags = cor_name(active_user_ptd)
   inactive_tags = cor_name(inactive_user_ptd)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; narrow to specified tags, if any
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(tags)) then $
    begin
     active_tags = grim_match_user_tags(active_tags, tags, sub=w)
     if(w[0] NE -1) then active_user_ptd = active_user_ptd[w] $
     else active_user_ptd = !null

     inactive_tags = grim_match_user_tags(inactive_tags, tags, sub=w)
     if(w[0] NE -1) then inactive_user_ptd = inactive_user_ptd[w] $
     else inactive_user_ptd = !null
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; draw points
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(active_user_ptd)) then $
           grim_draw_user_points, grim_data, plane, active_tags, xmap=xmap, $
                          override_color=override_color, noxgraphics=noxgraphics
   if(keyword_set(inactive_user_ptd)) then $
       grim_draw_user_points, grim_data, plane, inactive_tags, inactive_color, $
                 xmap=xmap, override_color=override_color, noxgraphics=noxgraphics
  end


 ;-------------------------------------
 ; draw xgraphics map
 ;-------------------------------------
 if(NOT keyword_set(noxgraphics)) then $
  if(keyword_set(xmap)) then $
   begin
    xmap = bytscl(xmap, max=512)			;;;;;;;;;;;;;;;;
    for i=1, 3 do $
           tv, byte((fix(smooth(xmap[*,*,i-1],3)) + $
                     fix(tvrd(0,0, !d.x_size,!d.y_size, i)))<255), 0,0, i 
   end

end
;=============================================================================



;=============================================================================
; grim_get_roi
;
;=============================================================================
function grim_get_roi, grim_data, plane, outline=outline

 if(keyword_set(outline)) then $
  begin
   if(NOT pnt_valid(plane.roi_ptd)) then return, !null
   return, plane.roi_ptd
  end

 if(NOT ptr_valid(plane.roi_p)) then return, !null
 return, *plane.roi_p

end
;=============================================================================



;=============================================================================
; grim_draw_roi
;
;=============================================================================
pro grim_draw_roi, grim_data, plane

if(pnt_valid(plane.roi_ptd)) then $
 begin
  p = pnt_points(plane.roi_ptd)
  plots, p, psym=-3, col=ctyellow()
 end

end
;=============================================================================



;=============================================================================
; grim_draw_indexed_arrays
;
;=============================================================================
pro grim_draw_indexed_arrays, ptdp, psym=psym

 if(NOT keyword_set(psym)) then psym = 3

 if(ptr_valid(ptdp)) then $
  begin
   for i=0, n_elements(*ptdp)-1 do $
    if(pnt_valid((*ptdp)[i])) then $
     begin
      pnt_query, (*ptdp)[i], /visible, p=p, nv=n, $
                         uname='GRIM_INDEXED_ARRAY_LABEL', udata=label
      label = strtrim(label,2)

      if(n GT 0) then $
       begin
        plots, p, col=ctred(), psym=psym

        q = convert_coord(p[0,0], p[1,0], /data, /to_device)
        xyouts, /device, q[0,0]+4, q[1,0]+4, label, align=0.5

        q = convert_coord(p[0,n-1], p[1,n-1], /data, /to_device)
        xyouts, /device, q[0,0]+4, q[1,0]+4, label, align=0.5
       end
     end
  end

end
;=============================================================================



;=============================================================================
; grim_draw_curves
;
;=============================================================================
pro grim_draw_curves, grim_data, plane
 psym = 3
 if(grim_test_map(grim_data)) then psym = -3
 grim_draw_indexed_arrays, plane.curve_ptdp, psym=psym
end
;=============================================================================



;=============================================================================
; grim_draw_tiepoints
;
;=============================================================================
pro grim_draw_tiepoints, grim_data, plane
 grim_draw_indexed_arrays, plane.tiepoint_ptdp, psym=1
end
;=============================================================================



;=============================================================================
; grim_draw_mask
;
;=============================================================================
pro grim_draw_mask, grim_data, plane

 mask = *plane.mask_p

 if(mask[0] NE -1) then $
  begin
   dim = dat_dim(plane.dd)
   p = w_to_xy(0, mask, sx=dim[0], sy=dim[1])
   plots, p, psym=6, col=ctgreen();, symsize=
   q = convert_coord(p[0,*], p[1,*], /data, /to_device)
  end

end
;=============================================================================



;=============================================================================
; grim_draw
;
;=============================================================================
pro grim_draw, grim_data, planes=planes, $
       all=all, wnum=wnum, $
       user=user, tiepoints=tiepoints, mask=mask, curves=curves, $
       label=labels, readout=readout, measure=measure, update=update, $
       nopoints=nopoints, noxgraphics=noxgraphics, roi=roi, $
       no_user=no_user, override_color=override_color, utags=utags

 if(grim_data.hidden) then return

 if(keyword_set(wnum)) then grim_wset, grim_data, wnum $
 else grim_wset, grim_data, grim_data.wnum

 if(NOT keyword_set(planes)) then planes = grim_get_plane(grim_data)


; grim_wset, grim_data, grim_data.overlay_pixmap
; erase


 nplanes = n_elements(planes)
 for jj=0, nplanes-1 do $
  begin
   plane = planes[jj]

   hidden = 'hidden'

   if(keyword_set(all)) then $
    begin
     roi=1 & user=1 & curves=1 & tiepoints=1 & mlab = 1 & readout = 1 & mask=1 & & measure = 1
    end

   if(keyword_set(no_user)) then user = 0

;   if(grim_test_map(grim_data)) then mlab = 0


  ;--------------------------------
  ; standard overlay points
  ;--------------------------------
  if(NOT keyword_set(nopoints)) then $
          grim_draw_standard_overlays, grim_data, plane, 'gray', $
                         update=update, mlab=mlab, override_color=override_color

   ;--------------------------------
   ; user overlay points
   ;--------------------------------
   if(keyword_set(user)) then $
        grim_draw_user_overlays, grim_data, plane, 'gray', $
              override_color=override_color, noxgraphics=noxgraphics, tags=utags


   ;--------------------------------
   ; roi
   ;--------------------------------
   if(keyword_set(roi)) then grim_draw_roi, grim_data, plane


   ;--------------------------------
   ; curves
   ;--------------------------------
   if(keyword_set(curves)) then grim_draw_curves, grim_data, plane


   ;--------------------------------
   ; tiepoints
   ;--------------------------------
   if(keyword_set(tiepoints)) then grim_draw_tiepoints, grim_data, plane


   ;--------------------------------
   ; mask
   ;--------------------------------
   if(keyword_set(mask)) then grim_draw_mask, grim_data, plane

  end


 ;--------------------------------
 ; readout mark
 ;--------------------------------
 if(keyword_set(readout)) then $
            plots, grim_data.readout_mark, psym=7, col=ctred()


 ;--------------------------------
 ; measure mark
 ;--------------------------------
 if(keyword_set(measure)) then $
            plots, grim_data.measure_mark, psym=-4, symsize=0.5, col=ctred()


 if(keyword_set(wnum)) then grim_wset, grim_data, grim_data.wnum

; grim_wset, grim_data, grim_data.wnum
;device, set_graphics=6
; device, copy=[0,0, !d.x_size,!d.y_size, 0,0, grim_data.overlay_pixmap]
;device, set_graphics=3


end
;=============================================================================



;=============================================================================
; grim_draw_grids
;
;=============================================================================
pro grim_draw_grids, grim_data, plane=plane, no_wset=no_wset
@grim_block.include

 ;--------------------------------------------
 ; image
 ;--------------------------------------------
 if(grim_data.type NE 'PLOT') then $
  begin

   ;----------------------------
   ; RA/DEC grid
   ;----------------------------
   if(grim_data.grid_flag) then $
    begin
     cd = grim_xd(plane, /cd)
     if(keyword_set(cd)) then plots, radec_grid(cd), psym=3, col=ctblue()
    end
   ;----------------------------
   ; pixel grid
   ;----------------------------
   if(grim_data.pixel_grid_flag) then $
               plots, pixel_grid(wnum=grim_data.wnum), psym=3, col=ctpurple()

  end $
 ;--------------------------------------------
 ; plot
 ;--------------------------------------------
 else $
  begin

  end


 
end
;=============================================================================



;=============================================================================
; grim_draw_axes
;
;=============================================================================
pro grim_draw_axes, grim_data, data, plane=plane, $
                    no_context=no_context, no_wset=no_wset
@grim_block.include

 ;--------------------------------------------
 ; images
 ;--------------------------------------------
 if(grim_data.type NE 'PLOT') then $
  begin
;   mg = 0.03
;   plot, [0], [0], /noerase, /data, pos=[mg,mg, 1.0-mg,1.0-mg]

   cd = grim_xd(plane, /cd)


   ;----------------------------
   ; main window image outline
   ;----------------------------
   if(keyword_set(cd)) then dim = image_size(cd) $
   else dim = dat_dim(plane.dd)

   xsize = dim[0]
   ysize = dim[1]

   plots, [-0.5,xsize-0.5,xsize-0.5,-0.5,-0.5], $
          [-0.5,-0.5,ysize-0.5,ysize-0.5,-0.5], line=1


   ;----------------------------
   ; optic axis 
   ;----------------------------
   if(keyword_set(cd)) then $
    if(cor_class(cd) EQ 'CAMERA') then $
     begin
      oaxis = cam_oaxis(cd)
 
      plots, oaxis, psym=1, symsize=4, col=ctred()
     end




   ;----------------------------
   ; current plane outline
   ;----------------------------
   if(grim_get_toggle_flag(grim_data, 'PLANE_HIGHLIGHT')) then $
    begin
     image = grim_get_image(grim_data, plane=plane, /current)
     outline_pts = image_outline(image)
     plots, outline_pts, psym=3, col=ctyellow()

     if(NOT keyword_set(no_context)) then $
      if(grim_data.context_mapped) then $
       begin
        grim_wset, grim_data, grim_data.context_pixmap
        plots, outline_pts, psym=3, col=ctyellow()
        grim_wset, grim_data, grim_data.wnum
       end
    end


   ;----------------------------
   ; pixel scales
   ;----------------------------



   ;----------------------------------------------------------------------
   ; inertial axes
   ;----------------------------------------------------------------------
   grim_show_axes, grim_data, plane
  end $
 ;--------------------------------------------
 ; plots
 ;--------------------------------------------
 else $
  begin
   ;------------------------------------------
   ; axes
   ;------------------------------------------
;   plots, plane.xrange, [0,0], line=1
;   plots, [0,0], plane.yrange, line=1


  end




 ;-----------------------------------------------
 ; primary window indicator outline
 ;-----------------------------------------------
 color = 0
 if(NOT widget_info(_primary, /valid)) then _primary = grim_data.base
 if(grim_data.base EQ _primary) then color = ctred() 
 if(NOT keyword__set(no_wset)) then grim_wset, grim_data, grim_data.wnum
 plots, [0,!d.x_size-1,!d.x_size-1,0,0], [0,0,!d.y_size-1,!d.y_size-1,0], $
           th=5, /device, color=color


 ;-----------------------------------------------
 ; FOV outline
 ;-----------------------------------------------



 ;----------------------------
 ; context window outline
 ;----------------------------
 if(NOT keyword_set(no_context)) then $
  if(grim_data.context_mapped) then $
   begin
    grim_wset, grim_data, grim_data.context_pixmap
    plots, /device, col=ctblue(), $
      [0,!d.x_size-1,!d.x_size-1,0,0], [0,0,!d.y_size-1,!d.y_size-1,0], th=4
    grim_wset, grim_data, grim_data.wnum


    ;-----------------------------------------------
    ; visible region outline in context window
    ;-----------------------------------------------
    p = tr([tr([0,0]),tr([!d.x_size, !d.y_size])])
    q = convert_coord(p, /device, /to_data)
    x0 = q[0,0]
    x1 = q[0,1]
    y0 = q[1,0]
    y1 = q[1,1]

    grim_wset, grim_data, grim_data.context_pixmap
    plots, /data, col=ctred(), [x0,x1,x1,x0,x0], [y0,y0,y1,y1,y0]
    grim_wset, grim_data, grim_data.wnum
   end

 
end
;=============================================================================



;=============================================================================
; grim_rm_ptd
;
;=============================================================================
pro grim_rm_ptd, plane, ptd

 if(NOT keyword_set(ptd)) then return

 ptdps = *plane.overlay_ptdps
 for i=0, n_elements(ptdps)-1 do $
  begin
   ptdp = ptdps[i]
   ptds = *ptdp
   if(keyword_set(ptds)) then $
    begin
     w = nwhere(ptds, ptd)
     if(w[0] NE -1) then *ptdp = rm_list_item(*ptdp, w, only=0, /scalar)
    end
  end

 nv_notify_unregister, ptd, 'grim_descriptor_notify'

end
;=============================================================================



;=============================================================================
; grim_match_overlays
;
;=============================================================================
function grim_match_overlays, ptd, ptd0, general=general


 ;-----------------------------------------------------------------
 ; narrow by comparing descriptions, names, and possibly assoc xds
 ;-----------------------------------------------------------------
 if(NOT keyword_set(general)) then $
   w = where( (pnt_desc(ptd) EQ pnt_desc(ptd0)) $
                 AND (cor_name(ptd) EQ cor_name(ptd0)) $
                    AND (pnt_assoc_xd(ptd) EQ pnt_assoc_xd(ptd0)) ) $
 else $
   w = where( (pnt_desc(ptd) EQ pnt_desc(ptd0)) $
                 AND (cor_name(ptd) EQ cor_name(ptd0)) )

 ;----------------------------------------------------------
 ; if only one match, assume it's correct
 ;----------------------------------------------------------
 if(n_elements(w) EQ 1) then return, w


 ;-------------------------------------------------------------------------
 ; compare observers for remaining candidates; multiple ods are possible
 ; for points hidden wrt a light source.  There should be only one match,
 ; so return the first one.
 ;-------------------------------------------------------------------------
 od = cor_gd(ptd, /od)
 for i=0, n_elements(w)-1 do $
  begin
   ii = w[i]
   od0 = cor_gd(ptd0[ii], /od)
   if(n_elements(od) EQ n_elements(od0)) then $
    begin
     ww = nwhere(od, od0)
     if(ww[0] NE -1) then $
         if(n_elements(ww) EQ n_elements(od)) then return, ii
    end
  end

 return, !null
end
;=============================================================================



;=============================================================================
; grim_add_new_points
;
;=============================================================================
pro grim_add_new_points, grim_data, ptdp, ptd, name, cd, plane=plane

 ptd0 = *ptdp

 for i=0, n_elements(ptd)-1 do if(pnt_valid(ptd[i])) then $
  begin
   w = grim_match_overlays(ptd[i], ptd0)
   if(w[0] EQ -1) then $
      grim_add_points, grim_data, plane=plane, ptd, name=name, cd=cd, data=data
  end

end
;=============================================================================



;=============================================================================
; grim_copy_overlay
;
;=============================================================================
pro grim_copy_overlay, ptd_dst, ptd_src

 pnt_assign, ptd_dst, /noevent, $
           points = pnt_points(ptd_src), $
           vectors = pnt_vectors(ptd_src), $
           flags = pnt_flags(ptd_src)

end
;=============================================================================



;=============================================================================
; grim_update_points
;
;=============================================================================
pro grim_update_points, grim_data, ptd0, ptd, plane=plane

 for i=0, n_elements(ptd)-1 do if(pnt_valid(ptd[i])) then $
  begin
   w = grim_match_overlays(ptd[i], ptd0)
   if(w[0] NE -1) then $
    begin
;if(cor_name(ptd[i]) EQ 'shadow-MOON') then print, ptd0[w], ptd[i]
; problem is there are two matches for the overlay; the second one is
;  overwriting the correct first one.  Why two matches???
     if(n_elements(w) EQ 1) then grim_copy_overlay, ptd0[w], ptd[i]
     nv_free, ptd[i]
    end
  end

end
;=============================================================================



;=============================================================================
; grim_rm_exclusions
;
;=============================================================================
pro grim_rm_exclusions, grim_data, overlay, ptd

 exclude_struct = *grim_data.exclude_overlays_p
 if(NOT keyword_set(exclude_struct)) then return

 w = where((exclude_struct.overlay EQ '') $
                      OR (exclude_struct.overlay EQ strupcase(overlay)))
 if(w[0] EQ -1) then return

 exclude_struct = exclude_struct[w]
 w = nwhere(cor_name(ptd), exclude_struct.name)

 if(w[0] EQ -1) then return

 nv_free, ptd[w]
 ptd = rm_list_item(ptd, w, only=obj_new())
end
;=============================================================================



;=============================================================================
; grim_add_points
;
;=============================================================================
pro grim_add_points, grim_data, ptd, plane=plane, $
         name=name, cd=cd, data=data, lock=lock

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 if(NOT keyword_set(cd)) then cd = grim_xd(plane, /cd)

 ;--------------------------------------------------------------------
 ; get points arrays and info for this overlay type
 ;--------------------------------------------------------------------
 ptd0 = grim_ptd(plane, type=name)


 ;-----------------------------------------------------------------------------
 ; if points exist for this type, replace existing points and append new ones
 ;-----------------------------------------------------------------------------
 ptd_new = ptd
 if(keyword_set(ptd0)) then $
  begin
   ptd_new = ptd0
   for i=0, n_elements(ptd)-1 do if(obj_valid(ptd[i])) then $
    begin
     w = grim_match_overlays(ptd[i], ptd0)
     if(w[0] EQ -1) then ptd_new = [ptd_new, ptd[i]] $
     else ptd_new[w] = ptd[i]
    end
  end 

 ;--------------------------------------------------------------------
 ; remove any excluded overlays
 ;--------------------------------------------------------------------
 grim_rm_exclusions, grim_data, name, ptd_new

 ;-----------------------------------------------------------------------------
 ; record new points list
 ;-----------------------------------------------------------------------------
 ptd_new = pnt_cull(ptd_new, /nofree)
 grim_set_ptd, plane, type=name, ptd_new
 grim_set_ptd_info, plane, type=name, data=data

 ;--------------------------------------------------------------------
 ; record overlay name for recalculation
 ;-------------------------------------------------------------------- 
 for i=0, n_elements(ptd_new)-1 do $
  begin
   cor_set_udata, ptd_new[i], 'GRIM_OVERLAY_NAME', name, /noevent
   if(keyword_set(lock)) then $
              cor_set_udata, ptd_new[i], 'GRIM_SELECT_LOCK', 1, /noevent
  end

end
;=============================================================================



;=============================================================================
; grim_default_activations
;
;=============================================================================
pro grim_default_activations, grim_data, plane=plane

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ;--------------------------------------------------------------------------
 ; if there's only one of a type of object, then it is automatically active
 ;--------------------------------------------------------------------------
; pd = grim_xd(plane, /pd)
; if(keyword__set(pd)) then $
;               if(n_elements(pd) EQ 1) then grim_activate, plane, pd

; rd = grim_xd(plane, /rd)
; if(keyword__set(rd)) then $
;               if(n_elements(rd) EQ 1) then grim_activate, plane, rd

; sd = grim_xd(plane, /sd)
; if(keyword__set(sd)) then $
;               if(n_elements(sd) EQ 1) then grim_activate, plane, sd


end
;=============================================================================



;=============================================================================
; grim_clear_active_overlays
;
;=============================================================================
pro grim_clear_active_overlays, grim_data, plane

 grim_rm_ptd, plane, grim_ptd(plane, /active)

end
;=============================================================================



;=============================================================================
; grim_frame_overlays
;
;=============================================================================
pro grim_frame_overlays, grim_data, plane, ptd, slop=slop, xy=xy

 if(NOT keyword_set(slop)) then slop = 0.1
 
 ;--------------------------------
 ; compute corners
 ;--------------------------------
 pp = pnt_points(/cat, /vis, ptd)
 npp = n_elements(pp)/2

 xmin = min(pp[0,*])
 xmax = max(pp[0,*])
 ymin = min(pp[1,*])
 ymax = max(pp[1,*])

 dx = xmax - xmin
 dy = ymax - ymin

 xslop = dx*slop
 yslop = dy*slop

 xmin = xmin - xslop
 xmax = xmax + xslop
 ymin = ymin - yslop
 ymax = ymax + yslop


 ;--------------------------------
 ; compute new tvim params
 ;--------------------------------
 offset = [xmin, ymin]

 if(keyword_set(xy)) then $
      zoom = [!d.x_size/abs(xmin-xmax), !d.y_size/abs(ymin-ymax)] $
 else zoom = !d.x_size/abs(xmin-xmax) < !d.y_size/abs(ymin-ymax)

 tvim, offset=offset, zoom=zoom, /inherit, /silent

 cx = !d.x_size/2
 cy = !d.y_size/2
 q = convert_coord(cx, cy, /device, /to_data)
 p = 0.5d*[xmin+xmax, ymin+ymax]
 tvim, doffset=(p-q)[0:1], /inherit, /silent


end
;=============================================================================



;=============================================================================
; grim_hide_overlays
;
;=============================================================================
pro grim_hide_overlays, grim_data, no_refresh=no_refresh, bm=bm

 if(grim_data.hidden) then $
  begin
   grim_data.hidden = 0
   bm = grim_hide_bitmap()
  end $
 else $
  begin
   grim_data.hidden = 1
   bm = grim_unhide_bitmap()
  end

 widget_control, grim_data.hide_button, set_value=bm

 grim_set_data, grim_data, grim_data.base
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap, /noglass

end
;=============================================================================



;=============================================================================
; grim_clear_objects
;
;=============================================================================
pro grim_clear_objects, grim_data, all=all, $
     cd=cd, pd=pd, rd=rd, sd=sd, std=std, ard=ard, ltd=ltd, skd=skd, planes=planes

 if(NOT keyword_set(planes)) then planes = grim_get_plane(grim_data)
 n = n_elements(planes)

 for i=0, n-1 do $
  begin
   ;----------------------------------
   ; clear descriptors
   ;----------------------------------
   if((keyword_set(all)) OR (keyword_set(cd))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /cd)
   if((keyword_set(all)) OR (keyword_set(pd))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /pd)
   if((keyword_set(all)) OR (keyword_set(rd))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /rd)
   if((keyword_set(all)) OR (keyword_set(sd))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /sd)
   if((keyword_set(all)) OR (keyword_set(std))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /std)
   if((keyword_set(all)) OR (keyword_set(ard))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /ard)
   if((keyword_set(all)) OR (keyword_set(ltd))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /ltd)
   if((keyword_set(all)) OR (keyword_set(skd))) then $
                           grim_rm_xd, planes[i], grim_xd(planes[i], /skd)

   ;----------------------------------
   ; clear points arrays
   ;----------------------------------
   names = (*planes[i].overlays_p).name
   for j=0, n_elements(names)-1 do $
    begin
     name = names[j]
     ptdp = grim_ptd(planes[i], type=name, class=class, /pointer)

     if(keyword_set(all)) then $
                      grim_rm_ptd, planes[i], grim_ptd(planes[i], type=name)
    end

   if(keyword_set(all)) then tag_list_rm, /nofree, planes[i].user_ptd_tlp
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_place_readout_mark
;
;=============================================================================
pro grim_place_readout_mark, grim_data, p

 ;------------------------
 ; erase old mark
 ;------------------------
; grim_refresh, grim_data, /use_pixmap
; q = convert_coord(grim_data.readout_mark[0], grim_data.readout_mark[1], $
;                                                           /data, /to_device)
; grim_display, grim_data, /use_pixmap, $
;                     pixmap_box_center=q[0:1], pixmap_box_side=10


 ;------------------------
 ; add new mark
 ;------------------------
 grim_data.readout_mark = p


 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_place_measure_mark
;
;=============================================================================
pro grim_place_measure_mark, grim_data, p

 ;------------------------
 ; erase old mark
 ;------------------------
; q = convert_coord(grim_data.measure_mark[0], grim_data.measure_mark[1], $
;                                                           /data, /to_device)
; grim_display, grim_data, /use_pixmap, $
;                pixmap_box_center=q[0:1], pixmap_box_side=10


 ;------------------------
 ; add new mark
 ;------------------------
 grim_data.measure_mark = p


 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_get_indexed_array
;
;=============================================================================
function grim_get_indexed_array, plane, name
 fields = tag_names(plane)
 ii_ptdp = where(fields EQ name+'_PTDP')
 return, plane.(ii_ptdp)
end
;=============================================================================



;=============================================================================
; grim_indexed_array_fname
;
;=============================================================================
function grim_indexed_array_fname, grim_data, plane, name, basename=basename
 if(NOT keyword_set(basename)) then basename = cor_name(plane.dd)
 return, grim_data.workdir + path_sep() + basename + '.' + strlowcase(name) + '_ptd'
end
;=============================================================================



;=============================================================================
; grim_unique_array_label
;
;=============================================================================
function grim_unique_array_label, ptdp

 ptd = *ptdp
 if(NOT keyword_set(ptd)) then return, 0
 nptd = n_elements(ptd)

 ii = make_array(nptd, val=-1)
 for i=0, nptd-1 do if(keyword_set(ptd[i])) then $
                ii[i] = cor_udata(ptd[i], 'GRIM_INDEXED_ARRAY_LABEL', /noevent)

 diff = set_difference(ii, lindgen(max(ii)+2))
 if(diff[0] EQ -1) then return, nptd

 return, min(diff)
end
;=============================================================================



;=============================================================================
; grim_add_indexed_array
;
;=============================================================================
pro grim_add_indexed_array, ptdp, p, ptd=ptd, $
           nointerp=nointerp, spacing=spacing, flags=flags, label=label

 if(NOT keyword_set(spacing)) then spacing = 1
 np = n_elements(p)/2

 ;-----------------------------------------
 ; interpolate 
 ;-----------------------------------------
 pp = p
 if(np GT 1) then $
  begin
   q1 = convert_coord(/device, /to_data, 0, 0)
   q2 = convert_coord(/device, /to_data, 1, 1)
   sample = abs(q1[0]-q2[0])*spacing

   if(NOT keyword_set(nointerp)) then pp = p_sample(p, sample) $
   else pp = p
 
   if(NOT keyword_set(p)) then return
  end

 ;-----------------------------------------
 ; set up array pointer
 ;-----------------------------------------
 if(NOT keyword_set(label)) then label = grim_unique_array_label(ptdp)

 ptd = pnt_create_descriptors(points=pp, $
        uname='GRIM_INDEXED_ARRAY_LABEL', $
        udata=label)
 cor_set_udata, ptd, 'GRIM_FULL_INDEXED_ARRAY_LABEL', label


 ;------------------------------------------------------------------------
 ; add the array
 ;------------------------------------------------------------------------
 *ptdp = append_array(*ptdp, ptd)

 if(defined(flags)) then pnt_set_flags, ptd, flags

end
;=============================================================================



;=============================================================================
; grim_write_indexed_arrays
;
;=============================================================================
pro grim_write_indexed_arrays, grim_data, plane, name, fname=fname

 if(NOT keyword_set(fname)) then $
                fname = grim_indexed_array_fname(grim_data, plane, name)

 tie_ptd = *plane.tiepoint_ptdp
 ptdp = grim_get_indexed_array(plane, name)
 ptd = *ptdp

 w = where(pnt_valid(ptd))
 if(w[0] NE -1) then pnt_write, fname, ptd[w] $
 else $
  begin
   ff = findfile(fname)
   if(keyword_set(ff)) then file_delete, fname, /quiet
  end

end
;=============================================================================



;=============================================================================
; grim_read_indexed_arrays
;
;=============================================================================
pro grim_read_indexed_arrays, grim_data, plane, name, fname=fname

 if(NOT keyword_set(fname)) then $
                fname = grim_indexed_array_fname(grim_data, plane, name)

 ff = (findfile(fname))[0]
 if(keyword_set(ff)) then ptd = pnt_read(ff) $
 else ptd = 0

 ptdp = grim_get_indexed_array(plane, name)

 w = where(pnt_valid(ptd))
 if(w[0] EQ -1) then return
 n = n_elements(w)

 for i=0, n-1 do grim_add_indexed_array, ptdp, pnt_points(ptd[i])

end
;=============================================================================



;=============================================================================
; grim_select_array_by_box
;
;
;=============================================================================
function grim_select_array_by_box, grim_data, ptd, cx, cy, plane=plane
@pnt_include.pro

 ii = -1

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 corners = convert_coord(cx, cy, /device, /to_data)

 ;-------------------------------------
 ; scan arrays
 ;-------------------------------------
 for i=0, n_elements(ptd)-1 do $
  if(pnt_valid(ptd[i])) then $
   begin
    pts = pnt_points(ptd[i])

    if(keyword_set(pts)) then $
     begin
      w = where((max(pts[0,*]) LE max(corners[0,*])) $
                    AND (min(pts[0,*]) GE min(corners[0,*])) $
                       AND (max(pts[1,*]) LE max(corners[1,*])) $
                          AND (min(pts[1,*]) GE min(corners[1,*])))
      if(w[0] NE -1) then ii = [ii, i]
     end
   end

 nii = n_elements(ii)
 if(nii GT 1) then ii = ii[1:*]

 return, ii
end
;=============================================================================



;=============================================================================
; grim_select_array_by_point
;
;=============================================================================
function grim_select_array_by_point, grim_data, ptd, p, all=all, plane=plane

d2min = 100
 ii = -1


 ;-----------------------------------------------------
 ; compute distance from p to each array
 ;-----------------------------------------------------
 for i=0, n_elements(ptd)-1 do $
  if(pnt_valid(ptd[i])) then $
   begin
    pts = pnt_points(ptd[i])
    n = n_elements(pts)/2

    q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
    cq = (convert_coord(/data, /to_device, pts[0,*], pts[1,*]))[0:1,*]

    qq = q#make_array(n,val=1d) 

    d2 = (qq[0,*]-cq[0,*])^2 + (qq[1,*]-cq[1,*])^2

    ;- - - - - - - - - - - - - - - - - - - - -
    ; remove lowest numbered array in range
    ;- - - - - - - - - - - - - - - - - - - - -
    w = where(d2 LE d2min)
    if(w[0] NE -1) then ii = [ii, i]
   end

 nii = n_elements(ii)
 if(nii GT 1) then ii = ii[1:*]

 return, ii
end
;=============================================================================



;=============================================================================
; grim_select_array
;
;=============================================================================
function grim_select_array, grim_data, plane=plane, ptd, p

d2min = 9

 ;---------------------------------------------
 ; remove array under initial cursor point
 ;---------------------------------------------
 ii = grim_select_array_by_point(grim_data, ptd, p, all=all, plane=plane)
 if(ii[0] NE -1) then return, ii

 ;-----------------------------------------------------------------------------
 ; if nothing removed by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------

 ;- - - - - - - - - - - - - - -
 ; drag box
 ;- - - - - - - - - - - - - - -
 q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
 box = tvrec(/restore, p0=q, col=ctyellow())

 cx = box[0,*]
 cy = box[1,*]
 d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; select overlays inside box, if dragged
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 box = 1
 if(d2 LE d2min) then box = 0

 if(box) then $
  begin
   ii = grim_select_array_by_box(grim_data, ptd, cx, cy, plane=plane)
   if(ii[0] NE -1) then return, ii
  end

 return, -1
end
;=============================================================================



;=============================================================================
; grim_rm_indexed_array_by_flabel
;
;=============================================================================
pro grim_rm_indexed_array_by_flabel, grim_data, plane, ptdp, _flabel

 if(NOT ptr_valid(ptdp)) then return
 if(NOT keyword_set(*ptdp)) then return

 xx = str_nnsplit(reform(strtrim(_flabel,2)), '-', rem=flabel)

 _flabels = strtrim(reform(cor_udata(*ptdp, 'GRIM_FULL_INDEXED_ARRAY_LABEL')),2)
 xx = str_nnsplit(_flabels, '-', rem=flabels)

 w = nwhere(flabels, flabel)
 if(w[0] EQ -1) then return 

 nv_free, (*ptdp)[w]
 *ptdp = rm_list_item(*ptdp, w, only=obj_new(), /scalar)

 
end
;=============================================================================



;=============================================================================
; grim_rm_indexed_array
;
;=============================================================================
pro grim_rm_indexed_array, grim_data, plane=plane, name, p, all=all, flabel=flabel

 ptdp = grim_get_indexed_array(plane, name)

 if(keyword__set(all)) then ii = lindgen(n_elements(*ptdp)) $
 else ii = grim_select_array(grim_data, plane=plane, *ptdp, p)

 if(ii[0] EQ -1) then return

 if(NOT keyword_set(*ptdp)) then return

 flabel = cor_udata((*ptdp)[ii], 'GRIM_FULL_INDEXED_ARRAY_LABEL')
 nv_free, (*ptdp)[ii]
 *ptdp = rm_list_item(*ptdp, ii, only=obj_new(), /scalar)

 if(keyword__set(all)) then nv_free, *ptdp

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_add_tiepoint
;
;=============================================================================
pro grim_add_tiepoint, grim_data, p, plane=plane, nointerp=nointerp, spacing=spacing, $
         no_sync=no_sync, flags=flags

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 grim_add_indexed_array, $
        plane.tiepoint_ptdp, p, nointerp=nointerp, spacing=spacing, flags=flags, ptd=ptd

 grim_set_plane, grim_data, plane, pn=plane.pn	
 grim_set_data, grim_data, grim_data.base


 if(NOT keyword_set(no_sync)) then grim_push_indexed_array, grim_data, ptd, 'TIEPOINT'
end
;=============================================================================



;=============================================================================
; grim_add_curve
;
;=============================================================================
pro grim_add_curve, grim_data, p, plane=plane, nointerp=nointerp, spacing=spacing, $
         no_sync=no_sync, flags=flags

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 grim_add_indexed_array, $
     plane.curve_ptdp, p, nointerp=nointerp, spacing=spacing, flags=flags, ptd=ptd

 grim_set_plane, grim_data, plane, pn=plane.pn	
 grim_set_data, grim_data, grim_data.base


 if(NOT keyword_set(no_sync)) then grim_push_indexed_array, grim_data, ptd, 'CURVE'
end
;=============================================================================



;=============================================================================
; grim_rm_tiepoint
;
;=============================================================================
pro grim_rm_tiepoint, grim_data, p, all=all, plane=plane, no_sync=no_sync, flabel=flabel

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)
 grim_rm_indexed_array, grim_data, plane=plane, 'TIEPOINT', p, all=all, flabel=flabel
 if(NOT keyword_set(flabel)) then return

 if(NOT keyword_set(no_sync)) then $
                   grim_push_indexed_array, grim_data, ptd, 'TIEPOINT', flabel=flabel
end
;=============================================================================



;=============================================================================
; grim_rm_curve
;
;=============================================================================
pro grim_rm_curve, grim_data, p, all=all, plane=plane, no_sync=no_sync, flabel=flabel

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)
 grim_rm_indexed_array, grim_data, plane=plane, 'CURVE', p, all=all, flabel=flabel
 if(NOT keyword_set(flabel)) then return

 if(NOT keyword_set(no_sync)) then $
                grim_push_indexed_array, grim_data, ptd, 'CURVE', flabel=flabel
end
;=============================================================================



;=============================================================================
; grim_set_roi
;
;=============================================================================
pro grim_set_roi, grim_data, roi, p, plane=plane

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 *plane.roi_p = roi
 flags = bytarr(n_elements(p)/2)
 pnt_set_points, plane.roi_ptd, p
 pnt_set_flags, plane.roi_ptd, flags

 if(grim_data.type EQ 'PLOT') then $
  begin
   dat = dat_data(plane.dd)

   ddx = dat[0,*]
   px = p[0,*]

   w = where((ddx GE floor(min(px))) AND (ddx LE ceil(max(px))))
   nw = n_elements(w)

   roi = lindgen(nw) + fix(min(px))
  end


 *plane.roi_p = roi

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base


end
;=============================================================================



;=============================================================================
; grim_add_mask
;
;=============================================================================
pro grim_add_mask, grim_data, p, plane=plane, replace=replace, subscript=subscript
@pnt_include.pro

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 p = round(p)

 mask = *plane.mask_p

 dim = dat_dim(plane.dd)

 if(keyword_set(subscript)) then sub = p $
 else sub = xy_to_w(0, p, sx=dim[0], sy=dim[1])


 if((mask[0] EQ -1) OR keyword_set(replace)) then mask = sub $
 else mask = [mask, sub]

; mask = mask[unique(mask)]
 *plane.mask_p = mask
 

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_copy_mask
;
;=============================================================================
pro grim_copy_mask, grim_data, plane, planes

 n = n_elements(planes)
 
 for i=0, n-1 do $
  begin
   *planes[i].mask_p =*plane.mask_p
   grim_set_plane, grim_data, planes[i], pn=pn
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_copy_indexed_array
;
;=============================================================================
pro grim_copy_indexed_array, grim_data, plane, planes, name

 ptdp = grim_get_indexed_array(plane, 'CURVE')

 n = n_elements(planes)
 nptd = n_elements(*ptdp)
 
 for i=0, n-1 do $
  begin
   ptdp_i = grim_get_indexed_array(planes[i], 'CURVE')

   pn = planes[i].pn
   nv_free, *ptdp_i
   
   *ptdp_i = objarr(nptd)
   for j=0, nptd-1 do (*ptdp_i)[j] = nv_clone((*ptdp)[j])

   grim_set_plane, grim_data, planes[i], pn=pn
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_copy_tiepoint
;
;=============================================================================
pro grim_copy_tiepoint, grim_data, plane, planes
 grim_copy_indexed_array, grim_data, plane, planes, 'TIEPOINT'
end
;=============================================================================



;=============================================================================
; grim_copy_curve
;
;=============================================================================
pro grim_copy_curve, grim_data, plane, planes
 grim_copy_indexed_array, grim_data, plane, planes, 'CURVE'
end
;=============================================================================



;=============================================================================
; grim_get_tiepoint_indices
;
;=============================================================================
function grim_get_tiepoint_indices, grim_data, plane=plane
@pnt_include.pro

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ptdp = grim_get_indexed_array(plane, 'TIEPOINT')
 ii = where(ptr_vaid(*ptdp))

 return, ii
end
;=============================================================================



;=============================================================================
; grim_replace_tiepoints
;
;=============================================================================
pro grim_replace_tiepoints, grim_data, ii, p, plane=plane

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ptdp = grim_get_indexed_array(plane, 'TIEPOINT')
 nii = n_element(ii)
 for i=0, nii-1 do pnt_set_points, (*ptdp)[ii[i]], p[*,i]

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_image_to_surface
;
;=============================================================================
function grim_image_to_surface, grim_data, plane, image_pts, $
                      body_pts=near_pts, $
                      back_pts=surf_pts_back, names=names, bx=bx;, valid=valid
@grim_block.include
@pnt_include.pro

 if(grim_data.type EQ 'PLOT') then return, 0

 cd = grim_xd(plane, /cd)
 surf_pts = 0

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; map
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 if(grim_test_map(grim_data)) then $
  begin
   map_pts = map_image_to_map(cd, image_pts, valid=valid)
   if(valid[0] NE -1) then $
    begin
     surf_pts = map_to_surface(cd, 0, map_pts[*,valid])
     names = make_array(n_elements(valid), val=cor_name(cd))
    end
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; otherwise test all bodies
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   bx = grim_cat_bodies(plane)
   nbx = n_elements(bx)

   raytrace, image_pts, cd=cd, bx=bx, hit_indices=ii, $
                 range_matrix=dist, hit_matrix=near_pts, back_matrix=back_pts
   w = -1

   bx = bx[ii]
   w = where(ii NE -1)
   nw = n_elements(w)

   if(w[0] NE -1) then $
    begin
     names = cor_name(bx[w])
     surf_pts = body_to_surface(bx[w], near_pts[w,*])
     surf_pts_back = body_to_surface(bx[w], back_pts[w,*])
    end


;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   ; any unaccounted for points go to the sky
;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   w = complement(ii, valid)
;   if(w[0] NE -1) then $
;    begin
;     names[w] = 'SKY'
;     surf_pts[w,*] = image_to_radec(cd, image_pts[*,w])
;    end

  end 


 return, surf_pts
end
;=============================================================================



;=============================================================================
; grim_surface_to_image
;
;=============================================================================
function grim_surface_to_image, grim_data, plane, surf_pts, names, valid=valid
@grim_block.include
@pnt_include.pro

 if(grim_data.type EQ 'PLOT') then return, 0

 cd = grim_xd(plane, /cd)
 image_pts = 0

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; map 
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 if(grim_test_map(grim_data)) then $
  begin
   name = cor_name(cd)   
   w = where(names EQ name)

   if(w[0] NE -1) then $
    begin
     image_pts = surface_to_image(cd, 0, surf_pts[w,*])
    end
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; non-map 
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   bx = grim_cat_bodies(plane)
   all_names = cor_name(bx)

   for k=0, n_elements(all_names)-1 do $
    begin
     w = where(names EQ all_names[k])
     if(w[0] NE -1) then $
	 image_pts = surface_to_image(cd, bx[k], surf_pts[w,*], body_pts=body_pts)
     r = bod_inertial_to_body_pos(bx[k], bod_pos(cd))
    end

;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   ; sky points 
;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   w = where(names EQ 'SKY')
;   if(w[0] NE -1) then image_pts[*,w] = radec_to_image(cd, surf_pts[w,*])
  end

 return, image_pts
end
;=============================================================================



;=============================================================================
; grim_sync_indexed_array
;
;=============================================================================
pro grim_sync_indexed_array, grim_data, plane, ptd, _grim_data, _plane, _ptdp
@grim_block.include
@pnt_include.pro

 if(NOT keyword_set(ptd)) then return 
 if(NOT obj_valid(ptd[0])) then return 

 pts = pnt_points(ptd)

 ;------------------------------------------
 ; convert array to surface points
 ;------------------------------------------
 surf_pts = $
   grim_image_to_surface(grim_data, plane, pts, names=names, back=surf_pts_back)
 if(NOT keyword_set(surf_pts)) then return

 ;------------------------------------------
 ; convert surface points to image points
 ;------------------------------------------
 _pts = grim_surface_to_image(_grim_data, _plane, surf_pts, names, valid=valid)
 if(keyword_set(surf_pts_back)) then $
   back_pts = grim_surface_to_image(_grim_data, _plane, surf_pts_back, names)


 ;------------------------------------------
 ; add points
 ;------------------------------------------
 label = strtrim(grim_data.grn,2) + '.' + $
               strtrim(plane.pn,2) + '.' + $
                    strtrim(cor_udata(ptd, 'GRIM_INDEXED_ARRAY_LABEL', /noevent),2)
 cor_set_udata, ptd, 'GRIM_FULL_INDEXED_ARRAY_LABEL', label
 if(keyword_set(_pts)) then $
  begin
   grim_add_indexed_array, _ptdp, _pts, label=label
   if(keyword_set(back_pts)) then $
       grim_add_indexed_array, _ptdp, back_pts, label='-'+label, spacing=8
  end

end
;=============================================================================



;=============================================================================
; grim_push_indexed_array
;
;=============================================================================
pro grim_push_indexed_array, grim_data, ptd, name, flabel=flabel
@grim_block.include
@pnt_include.pro

 if(NOT keyword_set(_all_tops)) then return

 plane = grim_get_plane(grim_data)
 
 top = _top
 tops = _all_tops
 ntops = n_elements(tops)

 full_name = name+'_SYNCING'

 ;------------------------------------------------------
 ; project/remove arrays in other planes and windows
 ;------------------------------------------------------
 for i=0, ntops-1 do $
  begin
   _grim_data = grim_get_data(tops[i])
   if(_grim_data.type NE 'PLOT') then $
    begin
     _planes = grim_get_plane(_grim_data, /all)

     for ii=0, n_elements(_planes)-1 do $
      begin
       _ptdp = grim_get_indexed_array(_planes[ii], name)
  
       if(keyword_set(flabel)) then $
           grim_rm_indexed_array_by_flabel, _grim_data, _planes[ii], _ptdp, flabel $
       else if((tops[i] NE top) OR (_planes[ii].pn NE plane.pn)) then $
        begin
         if(grim_get_toggle_flag(_grim_data, full_name) $
                   OR grim_get_toggle_flag(grim_data, full_name)) then $
             grim_sync_indexed_array, $
   			 grim_data, plane, ptd, _grim_data, _planes[ii], _ptdp 
        end
       end
     if(tops[i] NE top) then grim_refresh, _grim_data, /use_pixmap
    end
  end


 grim_data = grim_get_data(top)

end
;=============================================================================



;=============================================================================
; grim_rm_mask_by_point
;
;=============================================================================
function grim_rm_mask_by_point, grim_data, p, plane=plane, pp=pp
@pnt_include.pro

d2min = 100
 mask = *plane.mask_p
 if(mask[0] EQ -1) then return, -1

 dim = dat_dim(plane.dd)
 mp = w_to_xy(0, mask, sx=dim[0], sy=dim[1])

 ;-----------------------------------------------------
 ; compute distance from p to each mask point
 ;-----------------------------------------------------
 n = n_elements(mask)

 q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
 tq = (convert_coord(/data, /to_device, mp[0,*], mp[1,*]))[0:1,*]

 qq = q#make_array(n,val=1d) 

 d2 = (qq[0,*]-tq[0,*])^2 + (qq[1,*]-tq[1,*])^2


 ;-------------------------------------------------------
 ; remove lowest-numbered mask point that's within range
 ;-------------------------------------------------------
 w = where(d2 LE d2min)
 if(w[0] EQ -1) then return, -1

 mask = rm_list_item(mask, w, only=-1)
 pp = mp[*,w[0]]

 *plane.mask_p = mask
 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base

 return, 0
end
;=============================================================================



;=============================================================================
; grim_rm_mask_by_box
;
;
;=============================================================================
pro grim_rm_mask_by_box, grim_data, cx, cy, plane=plane, pp=pp
@pnt_include.pro

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 corners = convert_coord(cx, cy, /device, /to_data)


 ;-------------------------------------
 ; scan mask points
 ;-------------------------------------
 mask = *plane.mask_p
 dim = dat_dim(plane.dd)
 pts = w_to_xy(0, mask, sx=dim[0], sy=dim[1])

 npts = n_elements(mask)
 if(npts GT 0) then $
  begin
   w = where((pts[0,*] LE max(corners[0,*])) AND (pts[0,*] GE min(corners[0,*])) $
              AND (pts[1,*] LE max(corners[1,*])) AND (pts[1,*] GE min(corners[1,*])))
   if(w[0] NE -1) then $
    begin
     mask = rm_list_item(mask, w, only=-1)
     pp = pts[*,w]
    end
  end


 *plane.mask_p = mask


end
;=============================================================================



;=============================================================================
; grim_rm_mask
;
;
;=============================================================================
pro grim_rm_mask, grim_data, p, all=all, plane=plane, pp=pp

d2min = 9
 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 mask = *plane.mask_p
 if(mask[0] EQ -1) then return

 if(keyword__set(all)) then $
  begin
   *plane.mask_p = -1
   grim_set_plane, grim_data, plane, pn=plane.pn
   grim_set_data, grim_data, grim_data.base
   return
  end

 ;---------------------------------------------
 ; remove mask point under initial cursor point
 ;---------------------------------------------
 stat = grim_rm_mask_by_point(grim_data, p, plane=plane, pp=pp)


 ;-----------------------------------------------------------------------------
 ; if nothing removed by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------
 if(stat EQ -1) then $
  begin
   ;- - - - - - - - - - - - - - -
   ; drag box
   ;- - - - - - - - - - - - - - -
   q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
   box = tvrec(/restore, p0=q, col=ctyellow())

   cx = box[0,*]
   cy = box[1,*]
   d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 
 
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   ; select overlays inside box, if dragged
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   box = 1
   if(d2 LE d2min) then box = 0

   if(box) then grim_rm_mask_by_box, grim_data, cx, cy, plane=plane, pp=pp
  end



end
;=============================================================================



;=============================================================================
; grim_get_object_overlays
;
;  Returns all overlay arrays associated with the given xd.
;
;=============================================================================
function grim_get_object_overlays, grim_data, plane, xd

 class = strlowcase(cor_class(xd))
 ptdp = grim_ptd(plane, /pointer)

 ptd = 0
 for i=0, n_elements(ptdp)-1 do $
  begin
   ptd0 = *ptdp[i]
   if(keyword_set(ptd0)) then $
    begin
     for j=0, n_elements(ptd0)-1 do $
      begin
       assoc_xd = pnt_assoc_xd(ptd0[j])
       if(obj_valid(assoc_xd)) then $
         if(assoc_xd EQ xd) then ptd = append_array(ptd, ptd0[j])
      end
    end
  end

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_copy_activations
;
;=============================================================================
pro grim_copy_activations, grim_data, plane=plane0

 planes = grim_get_plane(grim_data, /all)
 ptd0 = grim_ptd(plane0)
 if(NOT keyword_set(ptd0)) then return

 name0 = cor_name(ptd0)
 active0 = cor_udata(ptd0, 'GRIM_ACTIVE_FLAG')

 for i=0, n_elements(planes)-1 do if(planes[i].pn NE plane0.pn) then $
  begin
   ptd = grim_ptd(planes[i])
   if(keyword_set(ptd)) then $
    for j=0, n_elements(ptd)-1 do $
     begin
      w = grim_match_overlays(ptd[j], ptd0, /general)
      if(defined(w)) then $
        if(w[0] NE -1) then $
           cor_set_udata, ptd[j], 'GRIM_ACTIVE_FLAG', active0[w], /noevent
     end
   grim_update_activations, grim_data, plane=planes[i], /no_sync
  end


end
;=============================================================================



;=============================================================================
; grim_activate_xd
;
;=============================================================================
pro grim_activate_xd, plane, xds, deactivate=deactivate

 if(NOT keyword_set(xds)) then return

 ;--------------------------------------------------------------------
 ; activate xds
 ;--------------------------------------------------------------------
 deactivate = keyword_set(deactivate)
 cor_set_udata, xds, 'GRIM_ACTIVE_FLAG', 1-deactivate, /all, /noevent

end
;=============================================================================



;=============================================================================
; grim_activate_overlay
;
;=============================================================================
pro grim_activate_overlay, grim_data, plane, ptd, xds=xds, pptd=pptd, $
      no_callback=no_callback, deactivate=deactivate

 if(NOT keyword_set(ptd)) then return

 ;--------------------------------------------------------------------
 ; activate overlays
 ;--------------------------------------------------------------------
 deactivate = keyword_set(deactivate)
 cor_set_udata, ptd, 'GRIM_ACTIVE_FLAG', 1-deactivate, /all, /noevent

 ;-----------------------------------
 ; contact activation callbacks
 ;-----------------------------------
 if(NOT keyword_set(no_callback)) then $
              grim_call_activation_callbacks, plane, ptd, deactivate=deactivate

 grim_update_activations, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_activate_all_overlays
;
;=============================================================================
pro grim_activate_all_overlays, grim_data, plane, deactivate=deactivate

 if(NOT keyword_set(*plane.overlay_ptdps)) then return

 n = n_elements(*plane.overlay_ptdps)
 for i=0, n-1 do $
       grim_activate_overlay, grim_data, plane, $
                          *(*plane.overlay_ptdps)[i], deactivate=deactivate

 grim_activate_user_overlay, plane, $
                      grim_get_user_ptd(plane=plane), deactivate=deactivate

 grim_update_activations, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_invert_active_overlays
;
;=============================================================================
pro grim_invert_active_overlays, grim_data, plane, ptd

 if(NOT keyword_set(ptd)) then return

 ;------------------------------------------------------
 ; invert activations
 ;------------------------------------------------------
 flag = cor_udata(ptd, 'GRIM_ACTIVE_FLAG', /noevent)
 cor_set_udata, ptd, 'GRIM_ACTIVE_FLAG', 1-flag, /noevent


 ;-----------------------------------------------------
 ; update object-referenced activation lists
 ;-----------------------------------------------------
 grim_update_activations, grim_data, plane=plane


end
;=============================================================================



;=============================================================================
; grim_invert_all_overlays
;
;=============================================================================
pro grim_invert_all_overlays, grim_data, plane

 if(NOT keyword_set(*plane.overlay_ptdps)) then return

 n = n_elements(*plane.overlay_ptdps)
 for i=0, n-1 do $
    grim_invert_active_overlays, grim_data, plane, *(*plane.overlay_ptdps)[i]

 grim_invert_active_user_overlays, grim_data, plane

end
;=============================================================================



;=============================================================================
; grim_nearest_overlay
;
;=============================================================================
function grim_nearest_overlay, plane, p, ptds

d2min = 25

 n = n_elements(ptds)
 mins = make_array(n, val=1d20)

 q = (convert_coord(p[0], p[1], /data, /to_device))[0:1]

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; find minimum distance to each object
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 for i=0, n-1 do if(obj_valid(ptds[i])) then $
  begin
   pts = pnt_points(ptds[i], /visible)
   npts = n_elements(pts)/2
   if(npts GT 0) then $
    begin
     pp = (convert_coord(pts[0,*], pts[1,*], /data, /to_device))[0:1,*]
     qq = q#make_array(npts,val=1d) 
     d2 = (qq[0,*]-pp[0,*])^2 + (qq[1,*]-pp[1,*])^2
    mins[i] = min(d2)
    end
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; return closest in-range object
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 mm = min(mins, ww)
 if(mm LE d2min) then return, ptds[ww]


 return, 0
end
;=============================================================================



;=============================================================================
; grim_enclosed_overlays
;
;=============================================================================
function grim_enclosed_overlays, corners, ptds

 if(NOT keyword_set(ptds)) then return, 0

 n = n_elements(ptds)

 ;-------------------------------------------
 ; find minimum distance to each object
 ;-------------------------------------------
 for i=0, n-1 do if(obj_valid(ptds[i])) then $
  begin
   pts = pnt_points((ptds)[i], /visible)
   npts = n_elements(pts)/2
   if(npts GT 0) then $
    begin
     xmin = make_array(npts, val=min(corners[0,*]))
     xmax = make_array(npts, val=max(corners[0,*]))
     ymin = make_array(npts, val=min(corners[1,*]))
     ymax = make_array(npts, val=max(corners[1,*]))

     w = where((pts[0,*] GT xmax) OR (pts[0,*] LT xmin) $
                   OR (pts[1,*] GT ymax) OR (pts[1,*] LT ymin))
     if(w[0] EQ -1) then ww = append_array(ww, i, /def)
    end
  end
 if(NOT defined(ww)) then return, !null

 return, ptds[ww]
end
;=============================================================================



;=============================================================================
; grim_select_overlays_by_point
;
;=============================================================================
function grim_select_overlays_by_point, grim_data, plane, p0, ptds, clicks=clicks

 ;---------------------------------------------
 ; select overlay under initial cursor point
 ;---------------------------------------------
 p = (convert_coord(p0[0], p0[1], /device, /to_data))[0:1]
 ptd = grim_nearest_overlay(plane, p, ptds)
 if(NOT keyword_set(ptd)) then return, !null

 ;----------------------------------------------------------
 ; if double click, get all ptds associated with the xd
 ;----------------------------------------------------------
 if(keyword_set(clicks)) then $
  if(clicks EQ 2) then $
   begin
    xds = pnt_assoc_xd(ptd)

    if(keyword_set(xds)) then $
     for i=0, n_elements(xds)-1 do $
      begin
       pptd = grim_get_object_overlays(grim_data, plane, xds[i])
       ptd = append_array(ptd, pptd)   
      end
     ptd = unique(ptd)
   end

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_select_overlays_by_box
;
;=============================================================================
function grim_select_overlays_by_box, grim_data, plane, p0, ptds


d2min = 9
 ;---------------------------------------------
 ; drag box
 ;---------------------------------------------
 box = tvrec(/restore, p0=p0, col=ctblue())

 cx = box[0,*]
 cy = box[1,*]
 d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 

 ;---------------------------------------------
 ; select overlays inside box, if dragged
 ;---------------------------------------------
 box = 1
 if(d2 LE d2min) then return, !null

 corners = convert_coord(cx, cy, /device, /to_data)
 ptd = grim_enclosed_overlays(corners,  ptds)
 if(keyword_set(ptd)) then return, ptd

 return, !null
end
;=============================================================================



;=============================================================================
; grim_select_overlays
;
;=============================================================================
function grim_select_overlays, grim_data, plane, p0, ptds, $
                 filter=filter, value=value, complement=complement, $
                                     clicks=clicks, point=point, box=box

 ;---------------------------------------------
 ; get appropriate points set
 ;---------------------------------------------
 if(NOT keyword_set(ptds)) then $
   ptds = append_array(grim_ptd(plane), grim_get_user_ptd(plane=plane))
 if(NOT keyword_set(ptds)) then return, !null

 ;---------------------------------------------
 ; filter by user value if filter specified
 ;---------------------------------------------
 if(keyword_set(filter)) then $
  begin
   values = cor_udata(ptds, filter)
   w = where(values EQ value, complement=ww)
   if(keyword_set(complement)) then w=ww
   if(w[0] EQ -1) then return, !null
   ptds = ptds[w]
  end 

 ;--------------------------------------------------------
 ; remove those that are locked
 ;--------------------------------------------------------
 lock = cor_udata(ptds, 'GRIM_SELECT_LOCK')
 w = where(lock EQ 0)
 if(w[0] EQ -1) then return, !null
 ptds = ptds[w]

 ;---------------------------------------------
 ; select overlay under initial cursor point
 ;---------------------------------------------
 if(NOT keyword_set(box)) then $
  begin
   ptd = grim_select_overlays_by_point(grim_data, plane, p0, ptds, clicks=clicks)
   if(keyword_set(ptd)) then return, ptd
   if(keyword_set(point)) then return, !null
  end

 ;-----------------------------------------------------------------------------
 ; if nothing selected by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------
 ptd = grim_select_overlays_by_box(grim_data, plane, p0, ptds)
 if(keyword_set(ptd)) then return, ptd

 return, !null
end
;=============================================================================



;=============================================================================
; grim_trim_overlays
;
;=============================================================================
pro grim_trim_overlays, grim_data, plane=plane, region

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 names = (*plane.overlays_p).name
 for i=0, n_elements(names)-1 do $
  begin
   name = names[i]
   ptd = grim_ptd(plane, type=name)
   if(keyword_set(ptd)) then pg_trim, 0, pnt_cull(ptd, /nofree), region
  end

end
;=============================================================================



;=============================================================================
; grim_select_overlay_points
;
;=============================================================================
pro grim_select_overlay_points, grim_data, plane=plane, region, deselect=deselect
@pnt_include.pro

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 names = (*plane.overlays_p).name
 for i=0, n_elements(names)-1 do $
  begin
   name = names[i]
   ptd = grim_ptd(plane, type=name)
   if(keyword_set(ptd)) then $
    begin
     ptd = pnt_cull(ptd, /nofree)
     if(NOT keyword_set(deselect)) then $
                      pg_trim, 0, ptd, region, mask=PTD_MASK_SELECT $
     else pg_trim, 0, ptd, region, mask=PTD_MASK_SELECT, /off
    end
  end

end
;=============================================================================



;=============================================================================
; grim_activate_select
;
;=============================================================================
pro grim_activate_select, grim_data, plane, p0, $
            deactivate=deactivate, clicks=clicks, invert=invert, status=status, $
            point=point, box=box

 status = -1

 ;--------------------------------------------------------
 ; select overlays
 ;--------------------------------------------------------
  if(NOT keyword_set(invert)) then $
 if(clicks NE 2) then $
   begin
    filter = 'GRIM_ACTIVE_FLAG'
    value = keyword_set(deactivate)
   end

 ptd = grim_select_overlays(grim_data, plane, p0, $
            filter=filter, value=value, clicks=clicks, point=point, box=box)
 if(NOT keyword_set(ptd)) then return

 ;--------------------------------------------------------
 ; activate/deactivate overlays
 ;--------------------------------------------------------
 status = 0

 active = cor_udata(ptd, 'GRIM_ACTIVE_FLAG', /noevent)
 if(keyword_set(invert)) then deactivate = active ? 1 : 0

 grim_set_overlay_update_flag, ptd, 1
 grim_activate_overlay, grim_data, plane, ptd, deactivate=deactivate

 grim_update_activations, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_remove_overlays
;
;=============================================================================
pro grim_remove_overlays, grim_data, plane, p0, $
                            clicks=clicks, status=status, user=user

 status = -1

 fn = keyword_set(user) ? 'grim_rm_user_overlay' : 'grim_rm_ptd'

 ptd = grim_select_overlays(grim_data, plane, p0, clicks=clicks, point=point, box=box)
 if(keyword_set(ptd)) then $
  begin
   status = 0
   call_procedure, fn, plane, ptd
  end

 grim_update_activations, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_initial_overlay_settings
;
;=============================================================================
pro grim_initial_overlay_settings, grim_data, settings_overlays

 if(NOT keyword_set(settings_overlays)) then return

 planes = grim_get_plane(grim_data, /all)
 for i=0, n_elements(planes)-1 do $
  begin
   overlays = *planes[i].overlays_p
   ii = lindgen(n_elements(overlays))

   tags = tag_names(settings_overlays)
   w = where(tags EQ 'NAME')
   if(w[0] NE -1) then $
          ii = where(overlays.name EQ strupcase(settings_overlays.name))

   for j=0, n_elements(ii)-1 do $
    begin
     info = overlays[ii[j]]
     struct_assign, /nozero, settings_overlays, info
     overlays[ii[j]] = info
    end

   *planes[i].overlays_p = overlays
  end

end
;=============================================================================



;=============================================================================
; grim_create_overlay
;
;=============================================================================
pro grim_create_overlay, grim_data, plane, name, class=class, dep_classes=dep_classes, dep_overlays, $
                   color=color, psym=psym, symsize=symsize, shade=shade, $
                   tlab=tlab, tshade=tshade, genre=genre

 if(grim_test_map(grim_data, plane=plane)) then psym = abs(psym)

 if(NOT defined(symsize)) then symsize = 1.
 if(NOT defined(shade)) then shade = 1.

 info = {	ptdp		: ptr_new(0), $
		name 		: name, $
		class 		: class, $
		genre 		: genre, $
		dep_classes_p 	: ptr_new(dep_classes), $
		color 		: color, $
		shade 		: float(shade), $
		psym 		: fix(psym), $
		symsize 	: float(symsize), $
		tlab 		: tlab, $
		tshade 		: tshade, $
		data_p 		: ptr_new(0) }

 *plane.overlays_p = append_array(*plane.overlays_p, info)
 *plane.overlay_ptdps = append_array(*plane.overlay_ptdps, ptr_new(0))

end
;=============================================================================



;=============================================================================
; grim_create_overlays
;
;=============================================================================
pro grim_create_overlays, grim_data, plane

   grim_create_overlay, grim_data, plane, $
	'RING_GRID', $
		class='RING', $
		dep_classes=['LIGHT', 'PLANET'], $
		genre='CURVE', $
		col='orange', psym=3, tlab=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'PLANET_GRID', $
		class='PLANET', $
		dep_classes=['LIGHT', 'RING'], $
		genre='CURVE', $
		col='green', psym=3, tlab=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'STATION', $
		class='STATION', $
		dep_classes=['PLANET', 'LIGHT', 'RING'], $
		genre='POINT', $
		col='yellow', psym=1, tlab=1, tshade=1

   grim_create_overlay, grim_data, plane, $
	'ARRAY', $
		class='ARRAY', $
		dep_classes=['PLANET', 'LIGHT', 'RING'], $
		genre='CURVE', $
		col='blue', psym=-3, tlab=1, tshade=1

   grim_create_overlay, grim_data, plane, $
	'LIMB', $
		class='PLANET', $
		dep_classes=['LIGHT', 'RING'], $
		genre='CURVE', $
		col='yellow', psym=-3, tlab=0, shade=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'TERMINATOR', $
		class='PLANET', $
		dep_classes=['LIGHT', 'RING'], $
		genre='CURVE', $
		col='red', psym=-3, tlab=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'RING', $
		class='RING', $
		dep_classes=['LIGHT', 'PLANET'], $
		genre='CURVE', $
		col='orange', psym=-3, tlab=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'CENTER', $
		class='PLANET', $
		dep_classes=['LIGHT'], $
		genre='POINT', $
		col='white',    psym=1, tlab=1, tshade=1

   grim_create_overlay, grim_data, plane, $
	'STAR', $
		class='STAR', $
		dep_classes=['PLANET', 'RING'], $
		genre='POINT', $
		col='white',  psym=6, tlab=0, symsize=1, tshade=0

   grim_create_overlay, grim_data, plane, $
	'SHADOW', $
		class='', $
		dep_classes=['PLANET', 'RING', 'LIGHT'], $
		genre='CURVE', $
		col='blue', psym=3, tlab=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'REFLECTION', $
		class='', $
		dep_classes=['PLANET', 'RING', 'LIGHT'], $
		genre='CURVE', $
		col='blue', psym=3, tlab=0, tshade=1


end
;=============================================================================



;=============================================================================
; grim_overlay
;
;=============================================================================
pro grim_overlay, grim_data, name, plane=plane, source_xd=source_xd, ptd=ptd, source_ptd=source_ptd, $
                                   obj_name=obj_name, temp=temp

 if(grim_data.slave_overlays) then plane = grim_get_plane(grim_data, pn=0)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)


 ;-----------------------------------------------------------------------
 ;  If the given name gives no result, then if there is an 'S' at the 
 ;  end, remove it and try a second time
 ;-----------------------------------------------------------------------
 for i=0,1 do $
  begin
   ptdp = grim_ptd(plane, info=info, type=name, /pointer) 
   if(keyword_set(ptdp)) then data = *info.data_p $
   else if(strmid(name, strlen(name)-1, 1) EQ 'S') then $
    begin
     name = strmid(name, 0, strlen(name)-1)
     ptdp = grim_ptd(plane, info=info, type=name, /pointer) 
     data = *info.data_p
    end
  end
 fn = 'grim_compute_' + name

 ;--------------------------------------------------
 ; if the dependencies are given, then just update
 ;  existing arrays
 ;--------------------------------------------------
 if(keyword_set(source_xd)) then $
  begin
   grim_suspend_events 

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; recompute the overlay points
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;**   gd = *plane.gd_p
   gd = grim_gd(plane)
   if(cor_test_gd(gd, 'MD')) then gd = cor_create_gd(gd=gd, cd=gd.md, od=gd.od)

   _ptd = call_function(fn, gd=gd, $
           map=grim_test_map(grim_data), clip=plane.clip, hide=plane.hide, $
           bx=source_xd, ptd=source_ptd, data=data, $
           npoints=grim_data.npoints)
   _ptd = pnt_cull(_ptd)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; replace existing overlay arrays wth recomputed ones
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   grim_update_points, grim_data, plane=plane, ptd, _ptd

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; add any new arrays
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   grim_add_new_points, grim_data, plane=plane, ptdp, _ptd, name, gd.cd

   grim_resume_events
   return
  end


 ;---------------------------------------------------------
 ; otherwise create new arrays
 ;---------------------------------------------------------
 grim_suspend_events 

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; make sure relevant descriptors are loaded
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 grim_load_descriptors, grim_data, name, plane=plane, obj_name=obj_name, cd=cd, gd=gd
 if(NOT keyword_set(cd)) then return

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; compute overlay arrays
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 active_xds = grim_xd(plane, /active)
 if(keyword_set(obj_name)) then $
  begin
   xds = cor_dereference_gd(gd)
   w = nwhere(strlowcase(cor_name(xds)), strlowcase(obj_name))
   if(w[0] EQ -1) then return
   active_xds = xds[w]
  end
 if(NOT keyword_set(active_xds)) then active_xds = grim_xd(plane)

 ptd = call_function(fn, gd=gd, data=data, $
          map=grim_test_map(grim_data), clip=plane.clip, hide=plane.hide, $
          bx=active_xds, $
          ptd=grim_ptd(plane, /active, /user), $
          npoints=grim_data.npoints)
 ptd = pnt_cull(ptd)

 w = where(pnt_valid(ptd))
 if(w[0] EQ -1) then return


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; add overlays
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(temp)) then $
   grim_add_points, grim_data, plane=plane, ptd, name=name, cd=cd, data=data

 grim_resume_events

end
;=============================================================================

pro grim_overlays_include
a=!null
end

