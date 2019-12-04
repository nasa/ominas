;=============================================================================
; grim_user_ptd_struct__define
;
;=============================================================================
pro grim_user_ptd_struct__define

 struct = $
    { grim_user_ptd_struct, $
	color		:	'', $
	fn_color	:	'', $
	fn_shade	:	'', $
	psym		:	0, $
	thick		:	1, $
	line		:	1, $
	shade_threshold	:	0d, $
	fn_graphics	:	3, $
	xgraphics	:	0b, $
	xradius		:	0b, $
	symsize		:	0. $
    }


end
;=============================================================================



;=============================================================================
; grim_add_user_points
;
;=============================================================================
pro grim_add_user_points, grn=grn, user_ptd, tag, update=update, $
                  color=color, fn_color=fn_color, fn_shade=fn_shade, psym=psym, $
                  thick=thick, line=line, symsize=symsize, $
                  shade_threshold=shade_threshold, $
                  fn_graphics=fn_graphics, xgraphics=xgraphics, xradius=xradius, $
                  nodraw=nodraw, inactive=inactive, $
                  no_refresh=no_refresh, plane=plane, lock=lock

 if(NOT keyword_set(tag)) then tag = 'no_name'
 if(NOT keyword_set(symsize)) then symsize = 1
 if(NOT keyword_set(fn_shade)) then fn_shade = ''
 if(NOT keyword_set(fn_color)) then fn_color = ''
 if(NOT keyword_set(shade_threshold)) then shade_threshold = 0d

 if(NOT defined(grn)) then if(keyword_set(plane)) then grn = plane.grn
 grim_data = grim_get_data(grn=grn)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 pp = pnt_points(user_ptd)
 vv = pnt_vectors(user_ptd)
 if(NOT keyword_set(pp)) then $
  if(keyword_set(vv)) then $
   begin
    pp = inertial_to_image_pos(grim_xd(plane, /cd), vv)
    pnt_set_points, user_ptd, pp
   end

 pn = plane.pn

 cor_set_name, user_ptd, tag, /noevent

 if(NOT keyword_set(color)) then color = 'purple' 

 if(NOT keyword_set(fn_graphics)) then fn_graphics = grim_data.default_user_fn_graphics
 if(NOT keyword_set(xgraphics)) then xgraphics = 0
 if(NOT keyword_set(xradius)) then xradius = 0
 if(NOT keyword_set(psym)) then psym = grim_data.default_user_psym
 if(NOT keyword_set(thick)) then thick = grim_data.default_user_thick
 if(NOT keyword_set(line)) then line = grim_data.default_user_line

 user_struct = {grim_user_ptd_struct}
 user_struct.color = color
 user_struct.fn_color = fn_color
 user_struct.fn_shade = fn_shade
 user_struct.psym = psym
 user_struct.shade_threshold = shade_threshold
 user_struct.fn_graphics = fn_graphics
 user_struct.xgraphics = xgraphics
 user_struct.xradius = xradius
 user_struct.thick = thick
 user_struct.line = line
 user_struct.symsize = symsize

 cor_set_udata, user_ptd, 'GRIM_USER_STRUCT', user_struct, /noevent

 if(keyword_set(lock)) then $
              cor_set_udata, user_ptd, 'GRIM_SELECT_LOCK', 1, /noevent

 tlp = plane.user_ptd_tlp
 if(keyword_set(update)) then $
              if((tag_list_match(tlp, tag))[0] EQ -1) then return

 tag_list_set, tlp, tag, user_ptd, new=new, index=index

 if(NOT keyword_set(inactive)) then grim_activate_user_overlay, plane, user_ptd


 if(keyword_set(nodraw)) then return

 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
; grim_update_user_points
;
;=============================================================================
pro grim_update_user_points, plane=plane, grn=grn, user_ptd, tag, $
                  user_struct=user_struct, nodraw=nodraw, no_refresh=no_refresh

 if(NOT keyword_set(grn)) then if(keyword_set(plane)) then grn = plane.grn
 grim_data = grim_get_data(grn=grn)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 if(NOT keyword_set(plane.user_ptd_tlp)) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 user_ptd = tag_list_get(plane.user_ptd_tlp, tag)
 cor_set_udata, user_ptd, 'GRIM_USER_STRUCT', user_struct, /all, /noevent

 if(keyword_set(nodraw)) then return
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
; grim_rm_user_points
;
;=============================================================================
pro grim_rm_user_points, grim_data, tag, plane=plane, grn=grn

 if(NOT keyword_set(plane)) then $
  begin
   grim_data = grim_get_data(grn=grn)
   plane = grim_get_plane(grim_data)
  end

 if(NOT keyword_set(plane.user_ptd_tlp)) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 for i=0, n_elements(tag)-1 do tag_list_rm, /nofree, plane.user_ptd_tlp, tag[i]


end
;=============================================================================



;=============================================================================
; grim_test_active_user_ptd
;
;=============================================================================
function grim_test_active_user_ptd, plane, tag, prefix=prefix

 user_ptd = tag_list_get(plane.user_ptd_tlp, tag)
 if(NOT keyword_set(user_ptd)) then return, 0

 flag = cor_udata(user_ptd, 'GRIM_ACTIVE_FLAG', /noevent)

 w = where(flag EQ 1)
 if(w[0] NE -1) then return, 1
 return, 0
end
;=============================================================================



;=============================================================================
; grim_get_user_ptd
;
;=============================================================================
function grim_get_user_ptd, plane=plane, grn=grn, tag, prefix=prefix, $
           user_struct=user_struct, $
           tags=tags, active=active

 user_struct = !null

 if(NOT keyword_set(plane)) then $
  begin
   grim_data = grim_get_data(grn=grn)
   plane = grim_get_plane(grim_data)
  end

 if(NOT keyword_set(plane.user_ptd_tlp)) then return, 0
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return, 0

 if(NOT keyword_set(tag)) then tag = tag_list_names(plane.user_ptd_tlp)

 n = n_elements(tag)

 user_ptd = 0
 for i=0, n-1 do $
  begin
   _user_ptd = tag_list_get(plane.user_ptd_tlp, tag[i], prefix=prefix)

   if(keyword_set(_user_ptd)) then $
    if((NOT keyword_set(active)) OR $
        grim_test_active_user_ptd(plane, tag[i], prefix=prefix)) then $
     begin
      _user_struct = reform(cor_udata(_user_ptd, 'GRIM_USER_STRUCT', /noevent))

      user_ptd = append_array(user_ptd, _user_ptd)
      user_struct = append_array(user_struct, _user_struct)
      tags = append_array(tags, tag[i])			;;;;
     end
  end

 return, user_ptd
end
;=============================================================================



;=============================================================================
; grim_get_active_user_overlays
;
;=============================================================================
function grim_get_active_user_overlays, plane, inactive_user_ptd

 active_user_ptd = (inactive_user_ptd = 0)

 user_ptd = grim_get_user_ptd(plane=plane)
 if(NOT keyword_set(user_ptd)) then return, 0

 flag = cor_udata(user_ptd, 'GRIM_ACTIVE_FLAG', /noevent)
 active_indices = where(flag EQ 1)
 inactive_indices = where(flag EQ 0)

 if(inactive_indices[0] NE -1) then inactive_user_ptd = user_ptd[inactive_indices]
 if(active_indices[0] NE -1) then active_user_ptd = user_ptd[active_indices]

 return, active_user_ptd
end
;=============================================================================



;=============================================================================
; grim_user_notify
;
;=============================================================================
pro grim_user_notify, grim_data, plane=plane

 if(NOT keyword_set(plane.user_ptd_tlp)) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return
 if(NOT keyword_set(*plane.user_ptd_tlp)) then return

 ptd = grim_get_user_ptd(plane=plane)
 if(NOT keyword_set(ptd)) then return

 cd = grim_xd(plane, /cd)

 nv_suspend_events

 for i=0, n_elements(ptd)-1 do $
  begin
   v = pnt_vectors(ptd[i])
   if(keyword_set(v)) then $
                pnt_set_points, ptd[i], reform(inertial_to_image_pos(cd, v))
  end

 nv_resume_events
end
;=============================================================================



;=============================================================================
; grim_rm_user_overlay
;
;=============================================================================
pro grim_rm_user_overlay, plane, ptd

 if(NOT keyword_set(ptd)) then return

 for i=0, n_elements(ptd)-1 do tag_list_rm, plane.user_ptd_tlp, cor_name(ptd[i])

end
;=============================================================================



;=============================================================================
; grim_trim_user_overlays
;
;=============================================================================
pro grim_trim_user_overlays, grim_data, plane=plane, region

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ptd = grim_get_user_ptd(plane=plane)
 if(keyword_set(ptd)) then pg_trim, 0, ptd, region

end
;=============================================================================



;=============================================================================
; grim_activate_user_overlay
;
;=============================================================================
pro grim_activate_user_overlay, plane, ptd, deactivate=deactivate

 if(NOT keyword_set(ptd)) then return

 ;--------------------------------------------------------------------
 ; activate overlays
 ;--------------------------------------------------------------------
 flag = keyword_set(deactivate) ? 0 : 1
 cor_set_udata, ptd, 'GRIM_ACTIVE_FLAG', flag, /all, /noevent


end
;=============================================================================



;=============================================================================
; grim_deactivate_user_overlay
;
;=============================================================================
pro grim_deactivate_user_overlay, plane, ptd

 if(NOT keyword_set(ptd)) then return

 ;--------------------------------------------------------------------
 ; deactivate overlays
 ;--------------------------------------------------------------------
 cor_set_udata, ptd, 'GRIM_ACTIVE_FLAG', 0, /all, /noevent

end
;=============================================================================



;=============================================================================
; grim_clear_active_user_overlays
;
;=============================================================================
pro grim_clear_active_user_overlays, plane

 ;------------------------------------------
 ; get tags of active user overlays
 ;------------------------------------------
 user_ptd = grim_get_active_user_overlays(plane)
 if(NOT keyword_set(user_ptd)) then return
 active_tags = cor_name(user_ptd, /noevent)

 ;------------------------------------------
 ; remove active user overlays
 ;------------------------------------------
 n = n_elements(user_ptd)
 for i=0, n-1 do tag_list_rm, plane.user_ptd_tlp, active_tags[i]

end
;=============================================================================



;=============================================================================
; grim_invert_active_user_overlays
;
;=============================================================================
pro grim_invert_active_user_overlays, grim_data, plane

 ptd = grim_get_user_ptd(plane=plane)
 grim_invert_active_overlays, grim_data, plane, ptd
 
end
;=============================================================================



;=============================================================================
; grim_set_udata
;
;=============================================================================
pro grim_set_udata, grim_data, name, udata
 cor_set_udata, grim_data.crd, name, udata
end
;=============================================================================



;=============================================================================
; grim_udata
;
;=============================================================================
function grim_udata, grim_data, name
 return, cor_udata(grim_data.crd, name)
end
;=============================================================================




pro grim_user_include
a=!null
end

