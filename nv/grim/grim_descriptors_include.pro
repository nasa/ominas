;=============================================================================
; grim_compute_fov
;
;=============================================================================
function grim_compute_fov, grim_data, plane, cov=cov

 if(grim_test_map(grim_data)) then return, 0

 cd = grim_xd(plane, /cd)
 if(NOT keyword_set(cd)) then return, 0

 fov = (cov = 0)

 ;-----------------------------------------------------------------
 ; fov = 0: no filtering
 ;-----------------------------------------------------------------
 if(plane.fov EQ 0) then return, fov

 ;-----------------------------------------------------------------
 ; fov > 0: filtering relative to image / optic axis
 ;-----------------------------------------------------------------
 if(plane.fov GT 0) then return, plane.fov

 ;-----------------------------------------------------------------
 ; fov < 0: filtering relative to viewport
 ;-----------------------------------------------------------------
 cov = (convert_coord(/device, /to_data, !d.x_size/2, !d.y_size/2))[0:1]

 p = (convert_coord(/device, /to_data, 0, 0))[0:1]
 q = (convert_coord(/device, /to_data, !d.x_size-1, !d.y_size-1))[0:1]

 dpq = abs(q-p)
 fov = max(dpq) / min(cam_size(cd))

 return, -fov/plane.fov
end
;=============================================================================



;=============================================================================
; grim_suspend_events
;
;=============================================================================
pro grim_suspend_events
@grim_block.include


 _suspend_events = 1

end
;=============================================================================



;=============================================================================
; grim_resume_events
;
;=============================================================================
pro grim_resume_events
@grim_block.include

 _suspend_events = 0

end
;=============================================================================



;=============================================================================
; grim_descriptor_notify
;
;=============================================================================
pro grim_descriptor_notify, events, refresh=refresh, new=new
@grim_block.include

 widget_control, /hourglass

 if(keyword_set(_suspend_events)) then return

 n = n_elements(events)

 ;-------------------------------------------
 ; handle events one at a time
 ;-------------------------------------------
 for i=0, n-1 do $
  begin
   grim_data = 0
   top = long(events[i].data)
   xd = events[i].xd
   grim_data = grim_get_data(top)
   plane = grim_get_plane(grim_data)

; if(NOT keyword_set(grim_data)) then nv_notify_unregister, xd, ...

   ;- - - - - - - - - - - - - - - - - - - -
   ; handle the event
   ;- - - - - - - - - - - - - - - - - - - -
   if(keyword_set(grim_data)) then $
          grim_descriptor_notify_handle, grim_data, xd, refresh=refresh, new=new

   ;- - - - - - - - - - - - - - - - - - - -
   ; open a new grim window if necessary
   ;- - - - - - - - - - - - - - - - - - - -
   if((events[i].desc EQ 'DATA') OR (events[i].desc EQ 'ALL')) then $
    if(keyword_set(new)) then $
     begin
stop
; this is not working.  You just get an infinite number of events and new grim windows.
help, events[i].xd
      sibling_dd = dat_sibling(plane.dd)

      new = 0
;      if(NOT obj_valid(plane.sibling_dd)) then new = 1 $
;      else if(sibling_dd NE plane.sibling_dd) then new = 1

      if(obj_valid(plane.sibling_dd)) then  $
      if(sibling_dd NE plane.sibling_dd) then new = 1

;nv_suspend_events
      if(new) then grim, /new, sibling_dd
;nv_resume_events
      plane.sibling_dd = sibling_dd

      grim_set_plane, grim_data, plane
     end 

   if(keyword_set(refresh)) then grim_refresh, grim_data, use_pixmap=use_pixmap
  end


end
;=============================================================================



;=============================================================================
; grim_rm_xd
;
;=============================================================================
pro grim_rm_xd, plane, xd

 if(NOT keyword_set(xd)) then xd = grim_xd(plane)
 if(NOT keyword_set(xd)) then return

 xdps = [plane.skd_p, $
         plane.cd_p, $
         plane.pd_p, $
         plane.rd_p, $
         plane.sd_p, $
         plane.ltd_p, $
         plane.std_p, $
         plane.ard_p]


 ;--------------------------------------------------------
 ; check each object type
 ;--------------------------------------------------------
 for j=0, n_elements(xdps)-1 do if(keyword_set(*xdps[j])) then $
  begin
   xdp = xdps[j]
   w = nwhere((*xdp), xd, rev=ww)
   if(w[0] NE -1) then $
    begin
     *xdp = rm_list_item(*xdp, w, only=obj_new(), /scalar)  
     xdx = xd[ww]

     ;--------------------------------------------------------
     ; unregister event handler
     ;--------------------------------------------------------
     nv_notify_unregister, xdx, 'grim_descriptor_notify'
     grim_activate_xd, plane, xdx, /deactivate

     ;----------------------------------
     ; remove its overlays
     ;----------------------------------
     for i=0, n_elements(xdx)-1 do $
      begin
       ptd = grim_get_object_overlays(grim_data, plane, xdx[i])
       if(keyword_set(ptd)) then nv_notify_unregister, ptd, 'grim_descriptor_notify'
      end

     ;--------------------------------------------------------
     ; free descriptors, only if originally created via GRIM
     ;--------------------------------------------------------
     if(keyword_set(cor_udata(xdx, 'grim_status'))) then nv_free, xdx

     ;--------------------------------------------------------
     ; cull dd generic descriptor
     ;--------------------------------------------------------
     cor_set_gd, plane.dd, cor_create_gd(cor_gd(plane.dd), /explicit), /noevent
    end
  end

end
;=============================================================================



;=============================================================================
; grim_rm_descriptor
;
;=============================================================================
pro grim_rm_descriptor, grim_data, plane=plane, xdp, xd

 ;--------------------------------------------------------
 ; remove the descriptor, remove all if no xd given
 ;--------------------------------------------------------
 if(NOT ptr_valid(xdp)) then return
 if(NOT keyword_set(*xdp)) then return
 if(NOT keyword_set(xd)) then xd = *xdp
 if(NOT keyword_set(xd)) then return

 w = nwhere((*xdp), xd)
 if(w[0] EQ -1) then return
 *xdp = rm_list_item(*xdp, w, only=obj_new(), /scalar)

 ;--------------------------------------------------------
 ; unregister event handler
 ;--------------------------------------------------------
 nv_notify_unregister, xd, 'grim_descriptor_notify'
 grim_activate_xd, plane, xd, /deactivate

 ;----------------------------------
 ; remove its overlays
 ;----------------------------------
 for i=0, n_elements(xd)-1 do $
  begin
   ptd = grim_get_object_overlays(grim_data, plane, xd[i])
   if(keyword_set(ptd)) then nv_notify_unregister, ptd, 'grim_descriptor_notify'
  end

 ;--------------------------------------------------------
 ; free descriptors, only if originally created via GRIM
 ;--------------------------------------------------------
 if(keyword_set(cor_udata(xd, 'grim_status'))) then nv_free, xd

 ;--------------------------------------------------------
 ; cull dd generic descriptor
 ;--------------------------------------------------------
 cor_set_gd, plane.dd, cor_create_gd(cor_gd(plane.dd), /explicit), /noevent
end
;=============================================================================



;=============================================================================
; grim_mark_descriptor
;
;=============================================================================
pro grim_mark_descriptor, xd, val
 nv_suspend_events
 for i=0, n_elements(xd)-1 do if(keyword_set(xd[i])) then $
                cor_set_udata, xd[i], 'grim_status', val, /noevent
 nv_resume_events
end
;=============================================================================



;=============================================================================
; grim_demark_descriptor
;
;=============================================================================
function grim_demark_descriptor, xd
 if(NOT keyword_set(xd)) then return, 0
 if(NOT obj_valid(xd[0])) then return, 0
 return, cor_udata(xd[0], 'grim_status')
end
;=============================================================================



;=============================================================================
; grim_mark_descriptors
;
;=============================================================================
pro grim_mark_descriptors, grim_data, all=all, $
     cd=cd, pd=pd, rd=rd, sd=sd, std=std, ard=ard, ltd=ltd, planes=planes, $
     val

 if(NOT keyword_set(planes)) then planes = grim_get_plane(grim_data)
 n = n_elements(planes)

 for i=0, n-1 do $
  begin
   ;----------------------------------
   ; clear descriptors
   ;----------------------------------
   if((keyword_set(all)) OR (keyword_set(cd))) then $
                                grim_mark_descriptor, *planes[i].cd_p, val
   if((keyword_set(all)) OR (keyword_set(pd))) then $
                                grim_mark_descriptor, *planes[i].pd_p, val
   if((keyword_set(all)) OR (keyword_set(rd))) then $
                                grim_mark_descriptor, *planes[i].rd_p, val
   if((keyword_set(all)) OR (keyword_set(sd))) then $
                                grim_mark_descriptor, *planes[i].sd_p, val
   if((keyword_set(all)) OR (keyword_set(std))) then $
                                grim_mark_descriptor, *planes[i].std_p, val
   if((keyword_set(all)) OR (keyword_set(ard))) then $
                                grim_mark_descriptor, *planes[i].ard_p, val
   if((keyword_set(all)) OR (keyword_set(ltd))) then $	
                                grim_mark_descriptor, *planes[i].ltd_p, val
  end


end
;=============================================================================



;=============================================================================
; grim_add_xd
;
;=============================================================================
pro grim_add_xd, grim_data, xdp, _xd, one=one, $
                               noregister=noregister, assoc_xd=assoc_xd
@grim_constants.common

 if(NOT keyword_set(_xd)) then return
 plane = grim_get_plane(grim_data)

 ;----------------------------------------------------------
 ; select associated descriptors 
 ;----------------------------------------------------------
 xd = cor_associate_gd(_xd, assoc_xd)
 if(NOT keyword_set(xd)) then return

 all_xd = grim_xd(plane)

 ;------------------------------------------------------------------------
 ; Cull descriptors such that names are unique.  Remove older
 ; duplicates (unless they are the same object), so new ones replace them. 
 ; If only one descriptor allowed, force remove.
 ;------------------------------------------------------------------------
 if(keyword_set(one)) then xd = xd[0]
; if(keyword_set(all_xd)) then $
 if(keyword_set(*xdp)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Determine which descriptors duplicate existing ones by name.
   ; Record the indices of the new ones for removal.
   ; Removing originals would cause a problem if any other
   ; objects have them as dependencies.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;stop
;all_names = cor_name(all_xd)



   old_names = cor_name(*xdp)
   new_names = cor_name(xd)

   names = [old_names, new_names]
   sort_names = [new_names+'-0', old_names+'-1']
   
   ss = sort(sort_names)
   uu = uniq(names[ss])

   w = complement(names, ss[uu])
   if(w[0] NE -1) then xdx = (*xdp)[w]
  end

 ;------------------------------------------------------------------------
 ; Remove duplicates.  Check that any descriptors to remove are not 
 ; actually the same object as the new one.  If so, do nothing with them.
 ;------------------------------------------------------------------------
 if(keyword_set(xdx)) then $
  begin
   ww = nwhere(xdx, xd, rev=ii)
   xdx = rm_list_item(xdx, ww, only=obj_new())   
   xd = rm_list_item(xd, ii, only=obj_new())   
   if(keyword_set(xdx)) then grim_rm_xd, plane, xdx
  end
 if(NOT keyword_set(xd)) then return


 ;-----------------------------------------------------------------------
 ; add descriptors and register
 ;-----------------------------------------------------------------------
 grim_mark_descriptor, xd, MARK_FRESH
 *xdp = append_array(*xdp, xd)
 if(NOT keyword_set(noregister)) then $
              nv_notify_register, xd, 'grim_descriptor_notify', $
                                                   scalar_data=grim_data.base

end
;=============================================================================



;=============================================================================
; grim_get_sky
;
;=============================================================================
function grim_get_sky, grim_data, plane=plane
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; get sky descriptor
 ;------------------------------------------------
 grim_message, /clear
 grim_print, grim_data, 'Getting sky descriptor...'
 cd = pg_get_sky()
 grim_message

 ;------------------------------------------------
 ; if not a map, then cd is camera descriptor
 ;------------------------------------------------
 grim_add_xd, grim_data, plane.skd_p, cd, /one 
 grim_set_plane, grim_data, plane;, pn=plane.pn


 return, grim_xd(plane, /skd)
end
;=============================================================================



;=============================================================================
; grim_get_cameras
;
;=============================================================================
function grim_get_cameras, grim_data, plane=plane
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_CAM_TRS')
 if(NOT grim_compare(_trs, plane.cam_trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(cd)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(cd)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then return, cd


 ;------------------------------------------------
 ; get camera and map descriptors
 ;------------------------------------------------
 cd0 = cd
 t = ''
 if(keyword_set(cd0)) then $
  begin
   if(cor_isa(cd0[0], 'BODY')) then t = bod_time(cd0)
   orient = bod_orient(cd0)
  end

 grim_message, /clear
 grim_print, grim_data, 'Getting camera descriptor...'
 cd = pg_get_cameras(plane.dd, plane.cam_trs, $
                 time=t, default_orient=orient, _extra=*grim_data.keyvals_p)
 md = pg_get_maps(plane.dd)
 grim_message

 if(NOT keyword_set(cd)) then $
  if(NOT keyword_set(md)) then return, 0

 map = grim_test_map(grim_data)
 if(keyword_set(md)) then map = 1

 ;------------------------------------------------
 ; if not a map, then cd is camera descriptor
 ;------------------------------------------------
 if(NOT map) then $
  begin
;++**   grim_add_xd, grim_data, cd, /one 
   grim_add_xd, grim_data, plane.cd_p, cd, /one 
   plane.t0 = bod_time(cd)
   grim_set_plane, grim_data, plane;, pn=plane.pn
  end $

 ;------------------------------------------------------------------
 ; otherwise, cd is map descriptor and od is camera descriptor
 ;------------------------------------------------------------------
 else $
  begin
;++**   grim_add_xd, grim_data, md, /one
   grim_add_xd, grim_data, plane.cd_p, md, /one
   if(keyword_set(cd)) then $
	       grim_add_xd, grim_data, plane.od_p, cd, /one
  end
 cor_set_udata, plane.dd, 'GRIM_CAM_TRS', plane.cam_trs, /noevent

 return, grim_xd(plane, /cd)
end
;=============================================================================



;=============================================================================
; grim_get_planets
;
;=============================================================================
function grim_get_planets, grim_data, plane=plane, names=names
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)
 pd = grim_xd(plane, /pd)
 ltd = grim_xd(plane, /ltd)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if requested names differ from loaded objects, need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(names)) then _names = cor_udata(plane.dd, 'GRIM_PLT_NAMES')
 if(NOT grim_compare(_names, names)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_PLT_TRS')
 if(NOT grim_compare(_trs, plane.plt_trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(pd)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1		;;;

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(pd)) then load = 1			;;;

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then return, get_object_by_name(pd, names)


 ;----------------------------------------------------------------------------
 ; load descriptors
 ;----------------------------------------------------------------------------
 fov = grim_compute_fov(grim_data, plane, cov=cov)

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; get main planets
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 grim_print, grim_data, 'Getting planet descriptors...'
 pd = pg_get_planets(plane.dd, od=cd, sd=ltd, $
         name=names, plane.plt_trs, fov=fov, cov=cov, _extra=*grim_data.keyvals_p)

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; get planets that require primary descriptors
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(pd)) then $
  begin
   pdd = pg_get_planets(plane.dd, od=cd, sd=ltd, pd=pd, $
       name=names, plane.plt_trs, fov=fov, cov=cov, _extra=*grim_data.keyvals_p)
   if(keyword_set(pdd)) then pd = [pd, pdd]

   _names = cor_name(pd)
   w = where(_names NE 'UNKNOWN')
   if(w[0] EQ -1) then pd = 0 $
   else pd = pd[w]
  end

 cor_set_udata, plane.dd, 'GRIM_PLT_NAMES', names, /noevent

 if(keyword_set(pd[0])) then grim_add_xd, grim_data, plane.pd_p, pd
 
 return, pd
end
;=============================================================================



;=============================================================================
; grim_get_lights
;
;=============================================================================
function grim_get_lights, grim_data, plane=plane, names=names
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;----------------------------------------------------------------------------
 ; get light sources
 ;----------------------------------------------------------------------------
 if(NOT keyword_set(names)) then $
  begin
   names = *grim_data.lights_p
   if(NOT keyword_set(names)) then names = 'SUN'
  end

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)
 od = grim_xd(plane, /od)
 ltd = grim_xd(plane, /ltd)
 xds = grim_xd(plane)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if requested names differ from loaded objects, need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(names)) then _names = cor_udata(plane.dd, 'GRIM_LGT_NAMES')
 if(NOT grim_compare(_names, names)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_LGT_TRS')
 if(NOT grim_compare(_trs, plane.lgt_trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(ltd)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(ltd)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then $
  begin
   for i=0, n_elements(names)-1 do $
             xd = append_array(xd, cor_select(ltd, names[i], /name))
   return, xd
  end


 ;----------------------------------------------------------------------------
 ; load descriptors
 ;----------------------------------------------------------------------------
 grim_print, grim_data, 'Getting Light descriptors...'

 for i=0, n_elements(names)-1 do $
  begin
   w = where(cor_name(xds) EQ names[i])
   if(w[0] NE -1) then ltd = append_array(ltd, xds[w]) $
   else $
    begin
     xd = pg_get_stars(plane.dd, od=cd, $
                 name=names[i], plane.lgt_trs, _extra=*grim_data.keyvals_p)
     if(NOT keyword_set(xd)) then $
       xd = pg_get_planets(plane.dd, od=cd, $
                  name=names[i], plane.lgt_trs, _extra=*grim_data.keyvals_p)

     if(keyword_set(xd)) then ltd = append_array(ltd, xd)
    end
  end

 ;----------------------------------------------------------------------------
 ; sort by flux at observer position
 ;----------------------------------------------------------------------------
 ltd = grim_sort_by_flux(ltd, od)
 names = cor_name(ltd)


 cor_set_udata, plane.dd, 'GRIM_LGT_NAMES', names, /noevent
 cor_set_udata, plane.dd, 'GRIM_LGT_TRS', plane.lgt_trs, /noevent


 if(keyword_set(ltd)) then grim_add_xd, grim_data, plane.ltd_p, ltd

 return, ltd
end
;=============================================================================



;=============================================================================
; grim_get_stars
;
;=============================================================================
function grim_get_stars, grim_data, plane=plane, names=names
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 trs = '/tr_nosort'
 if(keyword_set(plane.str_trs)) then trs = trs + ', ' + plane.str_trs

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)
 sd = grim_xd(plane, /sd)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if requested names differ from loaded objects, need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(names)) then _names = cor_udata(plane.dd, 'GRIM_STR_NAMES')
 if(NOT grim_compare(_names, names)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_STR_TRS')
 if(NOT grim_compare(_trs, trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(sd)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(sd)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the view has changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 tvim, /silent, get=tvd
 _tvd = cor_udata(plane.dd, 'GRIM_STR_TVD')
 if(keyword_set(_tvd)) then $
  begin
   if(total(_tvd.zoom - tvd.zoom) GT 0) then load = 1
   if(total(_tvd.offset - tvd.offset) GT 0) then load = 1
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then return, get_object_by_name(sd, names)


 ;----------------------------------------------------------------------------
 ; load descriptors
 ;----------------------------------------------------------------------------
 fov = grim_compute_fov(grim_data, plane, cov=cov)

 grim_print, grim_data, 'Getting star descriptors...'
 sd = pg_get_stars(plane.dd, od=cd, $
                 trs, name=names, fov=fov, cov=cov, _extra=*grim_data.keyvals_p)
 cor_set_udata, plane.dd, 'GRIM_STR_NAMES', names, /noevent
 cor_set_udata, plane.dd, 'GRIM_STR_TRS', trs, /noevent
 cor_set_udata, plane.dd, 'GRIM_STR_TVD', tvd, /noevent

 if(keyword_set(sd[0])) then grim_add_xd, grim_data, plane.sd_p, sd

 return, sd
end
;=============================================================================



;=============================================================================
; grim_get_rings
;
;=============================================================================
function grim_get_rings, grim_data, plane=plane, names=names
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)
 rd = grim_xd(plane, /rd)
 pd = grim_xd(plane, /pd)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if requested names differ from loaded objects, need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(names)) then _names = cor_udata(plane.dd, 'GRIM_RNG_NAMES')
 if(NOT grim_compare(_names, names)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_RNG_TRS')
 if(NOT grim_compare(_trs, plane.rng_trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(rd)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(rd)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then return, get_object_by_name(rd, names)

 ;----------------------------------------------------------------------------
 ; load descriptors
 ;----------------------------------------------------------------------------
 fov = grim_compute_fov(grim_data, plane, cov=cov)

 grim_print, grim_data, 'Getting ring descriptors...'
 if(NOT keyword_set(pd)) then return, obj_new()

;help, names
;help, plane.rng_trs
 rd = pg_get_rings(plane.dd, $
         od=cd, pd=pd, name=names, $
                   plane.rng_trs, fov=fov, cov=cov, _extra=*grim_data.keyvals_p)
;help, rd
 cor_set_udata, plane.dd, 'GRIM_RNG_NAMES', names, /noevent
 cor_set_udata, plane.dd, 'GRIM_RNG_TRS', plane.rng_trs, /noevent

 if(keyword_set(rd)) then grim_add_xd, grim_data, plane.rd_p, rd

 return, rd
end
;=============================================================================



;=============================================================================
; grim_get_stations
;
;=============================================================================
function grim_get_stations, grim_data, plane=plane, names=names
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 map = grim_test_map(grim_data)

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)
 pd = grim_xd(plane, /pd)
 std = grim_xd(plane, /std)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if requested names differ from loaded objects, need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(names)) then _names = cor_udata(plane.dd, 'GRIM_STN_NAMES')
 if(NOT grim_compare(_names, names)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_STN_TRS')
 if(NOT grim_compare(_trs, plane.stn_trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(std)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1
 
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(std)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then return, get_object_by_name(std, names)


 ;----------------------------------------------------------------------------
 ; load descriptors
 ;----------------------------------------------------------------------------
 grim_print, grim_data, 'Getting station descriptors...'
 if(NOT map) then bx = pd
 std = pg_get_stations(plane.dd, $
		   od=cd, bx=bx, name=names, $
                          plane.stn_trs, _extra=*grim_data.keyvals_p)
 cor_set_udata, plane.dd, 'GRIM_STN_NAMES', names, /noevent
 cor_set_udata, plane.dd, 'GRIM_STN_TRS', plane.stn_trs, /noevent

 if(keyword_set(std)) then grim_add_xd, grim_data, plane.std_p, std

 return, std
end
;=============================================================================



;=============================================================================
; grim_get_arrays
;
;=============================================================================
function grim_get_arrays, grim_data, plane=plane, names=names
@grim_constants.common

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 map = grim_test_map(grim_data)

 ;----------------------------------------------------------------------------
 ; determine whether to reload or keep current descriptor set
 ;----------------------------------------------------------------------------
 load = 0
 cd = grim_xd(plane, /cd)
 pd = grim_xd(plane, /pd)
 ard = grim_xd(plane, /ard)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if requested names differ from loaded objects, need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(names)) then _names = cor_udata(plane.dd, 'GRIM_ARR_NAMES')
 if(NOT grim_compare(_names, names)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if the translator keywords have changed, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _trs = cor_udata(plane.dd, 'GRIM_ARR_TRS')
 if(NOT grim_compare(_trs, plane.arr_trs)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if descriptor has been marked as stale, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 mark = grim_demark_descriptor(ard)
 if((where(mark NE MARK_FRESH))[0] NE -1) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if there are no descriptors, then need to load
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(ard)) then load = 1

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; don't continue if load not necessary
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT load) then return, get_object_by_name(ard, names)


 ;----------------------------------------------------------------------------
 ; load descriptors
 ;----------------------------------------------------------------------------
 grim_print, grim_data, 'Getting array descriptors...'
 if(NOT map) then bx = pd
 ard = pg_get_arrays(plane.dd, $
		   od=cd, bx=bx, name=names, $
                         plane.arr_trs, _extra=*grim_data.keyvals_p)
 cor_set_udata, plane.dd, 'GRIM_ARR_NAMES', names, /noevent
 cor_set_udata, plane.dd, 'GRIM_ARR_TRS', plane.arr_trs, /noevent

 if(keyword_set(ard)) then grim_add_xd, grim_data, plane.ard_p, ard

 return, ard
end
;=============================================================================



;=============================================================================
; grim_clear_descriptors
;
;=============================================================================
pro grim_clear_descriptors, grim_data, planes=planes

 if(NOT keyword_set(planes)) then planes = grim_get_plane(grim_data)
 n = n_elements(planes)

 for i=0, n-1 do $
  begin
   grim_rm_xd, planes[i], grim_xd(planes[i], /cd)
   grim_rm_xd, planes[i], grim_xd(planes[i], /pd)
   grim_rm_xd, planes[i], grim_xd(planes[i], /rd)
   grim_rm_xd, planes[i], grim_xd(planes[i], /sd)
   grim_rm_xd, planes[i], grim_xd(planes[i], /std)
   grim_rm_xd, planes[i], grim_xd(planes[i], /ard)
   grim_rm_xd, planes[i], grim_xd(planes[i], /ltd)
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================












;=============================================================================
; grim_load_descriptors
;
;=============================================================================
pro grim_load_descriptors, grim_data, name, plane=plane, class=class, $
       skd=skd, cd=cd, pd=pd, rd=rd, ltd=ltd, sd=sd, ard=ard, std=std, od=od, $
       obj_name=obj_name, gd=gd

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;-----------------------------------------------------------------------
 ; get dependencies
 ;-----------------------------------------------------------------------
 info = grim_ptd_info(plane, type=name, class=class, dep=dep)

 dep = append_array(dep, class)
 if(NOT keyword_set(dep)) then return

 if(NOT keyword_set(obj_name)) then obj_name = ''

 ;----------------------------------------------------------------
 ; load descriptors based on dependencies for this type of object
 ;----------------------------------------------------------------
 skd = (cd = (pd = (rd = (ltd = (sd = (std = (ard = (od = 0))))))))

 cd = grim_get_cameras(grim_data, plane=plane)
 if(NOT keyword_set(cd[0])) then return

 map = grim_test_map(grim_data)

 ;----------------------------------------------------------------
 ; camera-only descriptors...
 ;----------------------------------------------------------------
 if(NOT map) then $
  begin
   skd = grim_get_sky(grim_data, plane=plane)

   if((where(dep EQ 'PLANET'))[0] NE -1) then $
    begin
     names = ''
     if(class EQ 'PLANET') then names = obj_name
     pd = grim_get_planets(grim_data, plane=plane, names=names)
    end

   if((where(dep EQ 'RING'))[0] NE -1) then $
    begin
     names = ''
     if(class EQ 'RING') then names = obj_name
     rd = grim_get_rings(grim_data, plane=plane, names=names)
    end

   if((where(dep EQ 'STAR'))[0] NE -1) then $
    begin
     names = ''
     if(class EQ 'STAR') then names = obj_name
     sd = grim_get_stars(grim_data, plane=plane, names=names)
    end

   if((where(dep EQ 'LIGHT'))[0] NE -1) then $
           ltd = grim_get_lights(grim_data, plane=plane)
  end $
 ;----------------------------------------------------------------
 ; map-only descriptors...
 ;----------------------------------------------------------------
 else $
  begin
   pd = grim_xd(plane, /pd)
   ltd = grim_xd(plane, /ltd)
   od = grim_xd(plane, /od)
  end


 ;----------------------------------------------------------------
 ; common descriptors...
 ;----------------------------------------------------------------
 if((where(dep EQ 'STATION'))[0] NE -1) then $
  begin
   names = ''
   if(class EQ 'STATION') then names = obj_name
   std = grim_get_stations(grim_data, plane=plane, names=names)
  end

 if((where(dep EQ 'ARRAY'))[0] NE -1) then $
  begin
   names = ''
   if(class EQ 'ARRAY') then names = obj_name
   ard = grim_get_arrays(grim_data, plane=plane, names=names)
  end


 gd = {cd: cd, $
       skd: skd, $
       pd: pd, $
       rd: rd, $
       ltd: ltd, $
       sd: sd, $
       std: std, $
       ard: ard, $
       od: od}
end
;=============================================================================


pro grim_descriptors_include
a=!null
end



