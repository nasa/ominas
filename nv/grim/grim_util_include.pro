;=============================================================================
; grim_select_active
;
;=============================================================================
function grim_select_active, xds, active=active, inactive=inactive

 if(NOT keyword_set(xds)) then return, 0
; if(NOT obj_valid(xds[0])) then return, 0

 flag = cor_udata(xds, 'GRIM_ACTIVE_FLAG')
 w = where(flag, complement=ww)

 if(keyword_set(active)) then $
  begin
   if(w[0] EQ -1) then return, !null
   return, xds[w]
  end

 if(keyword_set(inactive)) then $
  begin
   if(ww[0] EQ -1) then return, !null
   return, xds[ww]
  end

 return, xds
end
;=============================================================================



;=============================================================================
; grim_xd
;
;=============================================================================
function grim_xd, plane, class=_class, $
       active=active, inactive=inactive, visible=visible, _ref_extra=keys

;** return, cor_dereference_gd(*plane.gd_p, _ref_extra=keys)

 xds = !null

 if(defined(_class)) then $
  begin
   class = _class
   if(class[0] EQ '') then return, obj_new()
   if(class[0] EQ 'all') then class = ''

   all_xds = grim_xd(plane)
   for i=0, n_elements(class)-1 do $
                  xds = append_array(xds, cor_select(all_xds, class, /class))
   return, grim_select_active(xds, active=active, inactive=inactive)
  end


 if(NOT keyword_set(keys)) then $
  begin
   xds =  cor_cull([*plane.skd_p, $
                    *plane.cd_p, $
                    *plane.pd_p, $
                    *plane.rd_p, $
                    *plane.sd_p, $
                    *plane.ltd_p, $
                    *plane.std_p, $
                    *plane.ard_p])
   return, grim_select_active(xds, active=active, inactive=inactive)
  end


 if((where(keys EQ 'SKD'))[0] NE -1) then xds = append_array(xds, *plane.skd_p)
 if((where(keys EQ 'CD'))[0] NE -1) then xds = append_array(xds, *plane.cd_p)
 if((where(keys EQ 'MD'))[0] NE -1) then xds = append_array(xds, *plane.md_p)
 if((where(keys EQ 'OD'))[0] NE -1) then xds = append_array(xds, *plane.od_p)
 if((where(keys EQ 'PD'))[0] NE -1) then xds = append_array(xds, *plane.pd_p)
 if((where(keys EQ 'RD'))[0] NE -1) then xds = append_array(xds, *plane.rd_p)
 if((where(keys EQ 'SD'))[0] NE -1) then xds = append_array(xds, *plane.sd_p)
 if((where(keys EQ 'STD'))[0] NE -1) then xds = append_array(xds, *plane.std_p)
 if((where(keys EQ 'ARD'))[0] NE -1) then xds = append_array(xds, *plane.ard_p)
 if((where(keys EQ 'LTD'))[0] NE -1) then xds = append_array(xds, *plane.ltd_p)
 if((where(keys EQ 'BX'))[0] NE -1) then $
  begin
   xds = append_array(xds, *plane.pd_p)
   xds = append_array(xds, *plane.rd_p)
   xds = append_array(xds, *plane.sd_p)
   xds = append_array(xds, *plane.ltd_p)
  end
 if((where(keys EQ 'GBX'))[0] NE -1) then $
  begin
   xds = append_array(xds, *plane.pd_p)
   xds = append_array(xds, *plane.sd_p)
   xds = append_array(xds, *plane.ltd_p)		;;;;;;
  end
 if((where(keys EQ 'DKX'))[0] NE -1) then $
  begin
   xds = append_array(xds, *plane.rd_p)
  end

 if((where(keys EQ 'SKY'))[0] NE -1) then xds = append_array(xds, *plane.skd_p)
 if((where(keys EQ 'CAMERA'))[0] NE -1) then xds = append_array(xds, *plane.cd_p)
 if((where(keys EQ 'MAP'))[0] NE -1) then xds = append_array(xds, *plane.md_p)
 if((where(keys EQ 'OBSERVER'))[0] NE -1) then xds = append_array(xds, *plane.od_p)
 if((where(keys EQ 'PLANET'))[0] NE -1) then xds = append_array(xds, *plane.pd_p)
 if((where(keys EQ 'RING'))[0] NE -1) then xds = append_array(xds, *plane.rd_p)
 if((where(keys EQ 'STAR'))[0] NE -1) then xds = append_array(xds, *plane.sd_p)
 if((where(keys EQ 'STATION'))[0] NE -1) then xds = append_array(xds, *plane.std_p)
 if((where(keys EQ 'ARRAY'))[0] NE -1) then xds = append_array(xds, *plane.ard_p)
 if((where(keys EQ 'LIGHT'))[0] NE -1) then xds = append_array(xds, *plane.ltd_p)
 if((where(keys EQ 'BODY'))[0] NE -1) then $
  begin
   xds = append_array(xds, *plane.pd_p)
   xds = append_array(xds, *plane.rd_p)
   xds = append_array(xds, *plane.sd_p)
   xds = append_array(xds, *plane.ltd_p)
  end
 if((where(keys EQ 'GLOBE'))[0] NE -1) then $
  begin
   xds = append_array(xds, *plane.pd_p)
   xds = append_array(xds, *plane.sd_p)
   xds = append_array(xds, *plane.ltd_p)		; not necessarily a globe
  end
 if((where(keys EQ 'DISK'))[0] NE -1) then $
  begin
   xds = append_array(xds, *plane.rd_p)
  end

 return, grim_select_active(xds, active=active, inactive=inactive)
end
;=============================================================================



;=============================================================================
; grim_ptd
;
;=============================================================================
function grim_ptd, plane, type=type, class=class, genre=genre, _ref_extra=keys, $
                       active=active, inactive=inactive, user=user, pointer=pointer, $
                       info=info_out

 if(NOT keyword_set(type)) then if(keyword_set(keys)) then type = keys

 ptdps = *plane.overlay_ptdps
 info = *plane.overlays_p

 if(keyword_set(type)) then field = info.name $
 else if(keyword_set(class)) then field = info.class $
 else if(keyword_set(genre)) then field = info.genre

 if(keyword_set(type)) then match = type $
 else if(keyword_set(class)) then match = class $
 else if(keyword_set(genre)) then match = genre

 result = 0
 info_out = !null
 if(keyword_set(field)) then $
  begin
   for i=0, n_elements(match)-1 do $
    begin
     w = where(field EQ match[i])
     if(w[0] NE -1) then $
       for j=0, n_elements(w)-1 do $
        begin  
         result = append_array(result, pointer_switch(ptdps[w[j]], pointer=pointer))
         info_out = append_array(info_out, info[w[j]])
        end  
    end
  end $
 else $
  begin
   for i=0, n_elements(ptdps)-1 do $
                       result = append_array(result, $
                                    pointer_switch(ptdps[i], pointer=pointer))
   info_out = info
  end
 if(keyword_set(pointer)) then return, decrapify(result)


 if(keyword_set(user)) then result = append_array(result, tag_list_get(plane.user_ptd_tlp))

 return, grim_select_active(result, active=active, inactive=inactive)
end
;=============================================================================



;=============================================================================
; grim_set_ptd
;
;=============================================================================
pro grim_set_ptd, plane, ptds, type=type, class=class, genre=genre, _ref_extra=keys, $
                       active=active, inactive=inactive

 if(NOT keyword_set(type)) then if(keyword_set(keys)) then type = keys
 if(NOT keyword_set(type)) then return

 ptdps = *plane.overlay_ptdps
 info = *plane.overlays_p

 w = where(info.name EQ type)
 if(w[0] EQ -1) then return

 ptdp = ptdps[w[0]]
 *ptdp = ptds
end
;=============================================================================



;=============================================================================
; grim_ptd_info
;
;=============================================================================
function grim_ptd_info, plane, ptd, type=type, class=class, genre=genre, ii=ii, $
                        ptds=ptds, data=data, dep_classes=dep_classes, $
                        color=color, psym=psym, tlab=tlab, tshade=tshade, $
                        symsize=symsize, shade=shade

 info = *plane.overlays_p

 if(NOT defined(ii)) then $
  begin
;   if(keyword_set(ptd)) then ii = ... $
   if(keyword_set(type)) then ii = where(info.name EQ type) $
   else if(keyword_set(class)) then ii = where(info.class EQ class) $
   else if(keyword_set(genre)) then ii = where(info.genre EQ genre)
  end

 if(NOT keyword_set(ii)) then return, info
 if(ii[0] EQ -1) then return, 0
 ii = ii[0]

 info = info[ii]

 type = info.name
 class = info.class
 genre = info.genre

 dep_classes = *info.dep_classes_p
 ptds = *info.ptdp
 data = *info.data_p

 color = info.color
 psym = info.psym
 symsize = info.symsize
 shade = info.shade
 tlab = info.tlab
 tshade = info.tshade

 return, info
end
;=============================================================================



;=============================================================================
; grim_set_ptd_info
;
;=============================================================================
pro grim_set_ptd_info, plane, ptd, type=type, class=class, genre=genre, ii=ii, $
                        ptds=ptds, data=data, dep_classes=dep_classes, $
                        color=color, psym=psym, tlab=tlab, tshade=tshade, $
                        symsize=symsize, shade=shade

 info = *plane.overlays_p

 if(NOT defined(ii)) then $
  begin
;   if(keyword_set(ptd)) then ii = ... $
   if(keyword_set(type)) then ii = where(info.name EQ type) $
   else if(keyword_set(class)) then ii = where(info.class EQ class) $
   else if(keyword_set(genre)) then ii = where(info.genre EQ genre)
  end

 if(NOT keyword_set(ii)) then return
 if(ii[0] EQ -1) then return
 ii = ii[0]

 if(defined(type)) then info[ii].name = type
 if(defined(class)) then info[ii].class = class
 if(defined(genre)) then info[ii].genre = genre

 if(defined(dep_classes)) then *info[ii].dep_classes_p = dep_classes
 if(defined(ptds)) then *info[ii].ptdp = ptds
 if(defined(data)) then *info[ii].data_p = data

 if(defined(color)) then info[ii].color = color
 if(defined(psym)) then info[ii].psym = psym
 if(defined(symsize)) then info[ii].symsize = symsize
 if(defined(shade)) then info[ii].shade = shade
 if(defined(tlab)) then info[ii].tlab = tlab
 if(defined(tshade)) then info[ii].tshade = tshade

 *plane.overlays_p = info
end
;=============================================================================



;=============================================================================
; grim_gd
;
;=============================================================================
function grim_gd, plane, class=_class, _ref_extra=keys

;** return, *plane.gd_p

   gd = {skd:grim_xd(plane, /skd), $
         cd:grim_xd(plane, /cd), $
         pd:grim_xd(plane, /pd), $
         rd:grim_xd(plane, /rd), $
         ltd:grim_xd(plane, /ltd), $
         sd:grim_xd(plane, /sd), $
         std:grim_xd(plane, /std), $
         ard:grim_xd(plane, /ard), $
         od:grim_xd(plane, /od)}

 return, gd
end
;=============================================================================



;===============================================================================
; grim_get_body_by_point
;
;  Returns all bodies hit by p, in order of distance.
;
;===============================================================================
function grim_get_body_by_point, grim_data, plane, p

 cd = grim_xd(plane, /cd)
 cam_pos = bod_pos(cd)

 xds = grim_xd(plane)
 w = where(cor_isa(xds, 'SOLID'))
 xds = xds[w]

 for i=0, n_elements(xds)-1 do $
  begin
   body_pt = image_to_body(cd, xds[i], p, hit=hit)
   if(hit[0] NE -1) then $
    begin
     hit_xds = append_array(hit_xds, xds[i])
     inertial_pt = bod_body_to_inertial(xds[i], body_pt)
     hit_dist = append_array(hit_dist, v_mag(cam_pos-inertial_pt))
    end
  end

 if(NOT keyword_set(hit_xds)) then return, !null
 return, hit_xds[sort(hit_dist)]
end
;===============================================================================



;===============================================================================
; grim_sort_by_flux
;
;  This just puts stars before planets.  To be correct, must look at 
;  luminosity and reflectance.  Probably do via a composite function.
;
;===============================================================================
function grim_sort_by_flux, xds, od

 return, append_array(cor_select(xds, 'STAR', /class), $
                      cor_select(xds, 'PLANET', /class))

end
;===============================================================================



;=============================================================================
; grim_set_user_data
;
;=============================================================================
pro grim_set_user_data, grim_data, tag, data

 tlp = grim_data.user_tlp
 tag_list_set, tlp, tag, data

 grim_data.user_tlp = tlp

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_get_user_data
;
;=============================================================================
function grim_get_user_data, grim_data, tag

 tlp = grim_data.user_tlp
 data = tag_list_get(tlp, tag)

 return, data
end
;=============================================================================



;=============================================================================
; grim_n_colors
;
;=============================================================================
function grim_n_colors, type

 case type of
    1: n_colors = 256
    2 : n_colors = 256
    3: n_colors = 256
    4: n_colors = 256
    5: n_colors = 256
    else : n_colors = 256
 endcase

 return, n_colors
end
;=============================================================================



;=============================================================================
; grim_get_body_by_name_single
;
;=============================================================================
function grim_get_body_by_name_single, xd_p, name

 if(NOT ptr_valid(xd_p)) then return, 0
 names = cor_name(*xd_p)
 w = where(name EQ names)
 if(w[0] NE -1) then return, (*xd_p)[w]

 return, 0
end
;=============================================================================



;=============================================================================
; grim_get_body_by_name
;
;=============================================================================
function grim_get_body_by_name, name, plane=plane

 bx = grim_get_body_by_name_single(plane.pd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.rd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.sd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.skd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.ltd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.std_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.ard_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.cd_p, name)
 if(keyword_set(bx)) then return, bx

 return, 0
end
;=============================================================================



;=============================================================================
; grim_shade_threshold
;
;=============================================================================
function grim_shade_threshold, ptd, shade, threshold, sub=w

 pp = pnt_points(ptd, /vis)
 w = where(shade GT threshold)
 
 if(w[0] EQ -1) then $
  begin
   shade = 0
   return, 0
  end

 pp = pp[*,w]
 shade = shade[w]

 return, pp
end
;=============================================================================



;=============================================================================
; grim_parse_overlay
;
;  fn:name1/field1=value1,name2/field2=value2/field3=value3;...
;                       or
;  fn:name1/field1=value1;name2/field2=value2/field3=value3;...
;
;=============================================================================
function grim_parse_overlay, plane, overlay, names

 ;---------------------------------------------------------
 ; determine which delimiter is being used
 ;---------------------------------------------------------
 delim = ','
 p = strpos(overlay, delim)
 if(p[0] EQ -1) then delim = ';'

 names = ''

 ;---------------------------------------------------------
 ; get overlay function
 ;---------------------------------------------------------
 s = str_split(overlay, ':')
 fn = s[0]
 if(n_elements(s) EQ 1) then return, fn

 ;---------------------------------------------------------
 ; get overlay names and parameters
 ;---------------------------------------------------------
 items = strupcase(str_nsplit(s[1], '/'))
 p = strpos(items, '=')
 w = where(p EQ -1, complement=ww)
 if(w[0] NE -1) then names = str_nsplit(items[w], delim)
 if(ww[0] NE -1) then parm = items[ww]

 ;---------------------------------------------------------
 ; assign parameters
 ;---------------------------------------------------------
 if(keyword_set(parm)) then $
  begin
   overlays = *plane.overlays_p
   tags = tag_names(overlays)

   w = where(overlays.name EQ fn)
   if(w[0] NE -1) then $
   for i=0, n_elements(parm)-1 do $
    begin
     s = str_split(parm[i], '=')
     key = s[0] & val = s[1]
     ww = where(tags EQ strupcase(key))
     if(ww[0] NE -1) then overlays[w].(ww) = match_type(overlays[w].(ww), val)
    end
   *plane.overlays_p = overlays
  end

 return, fn
end
;=============================================================================



;=============================================================================
; grim_parse_overlay_exclusions
;
;  fn:name1,name2,...
;          or
;  fn:name1;name2;...
;
;=============================================================================
pro grim_parse_overlay_exclusions, grim_data, exclude_overlays
;print, exclude_overlays
;stop

 for i=0, n_elements(exclude_overlays)-1 do $
  begin
   overlay = grim_parse_overlay(0, exclude_overlays[i], names)
   nstruct = n_elements(names)
   if(NOT keyword_set(names)) then $
    begin
     names = overlay
     overlay = ''
    end

   struct = replicate({overlay:'', name: ''}, nstruct)
   struct.overlay = strupcase(overlay)
   struct.name = strupcase(names)

   *grim_data.exclude_overlays_p = $
                     append_array(*grim_data.exclude_overlays_p, struct)
  end

 grim_set_data, grim_data
end
;=============================================================================



;=============================================================================
; grim_redimension
;
;=============================================================================
function grim_redimension, dim0, ndim

 ndim0 = n_elements(dim0)

 if(ndim EQ ndim0) then return, dim0
 if(ndim GT ndim0) then return, pad_array(dim0, ndim, pad=1)

 dim = lonarr(ndim)
 if(ndim GT 1) then dim[0:ndim-2] = dim0[0:ndim-2]
 dim[ndim-1] = product(dim0[ndim-1:*])
 return, dim
end
;=============================================================================



;=============================================================================
; grim_redimension_data
;
;=============================================================================
function grim_redimension_data, data, ndim
 
 dim = grim_redimension(dim0, ndim)

end
;=============================================================================



;=============================================================================
; grim_cat_bodies
;
;=============================================================================
function grim_cat_bodies, plane

 bx = grim_xd(plane, /pd, /rd)
 w = where(obj_valid(bx))
 if(w[0] EQ -1) then return, 0
 return, bx[w]
end
;=============================================================================



;=============================================================================
; grim_get_cursor_swap
;
;=============================================================================
function grim_get_cursor_swap, grim_data

 return, test_endian()

 swap = 0
 if(grim_data.cursor_swap EQ -1) then $
  begin
   if(test_endian()) then swap = 1
  end $
 else if(grim_data.cursor_swap EQ 1) then swap = 1

 return, swap
end
;=============================================================================



;=============================================================================
; grim_wset
;
;=============================================================================
pro grim_wset, grim_data, wnum, get_info=get_info, $
    save=save, noplot=noplot

 if(NOT windows_output()) then return

 if(grim_data.type EQ 'PLOT') then tvgr, wnum, get_info=get_info, $
     save=save, noplot=noplot, /silent $
 else tvim, wnum, get_info=get_info, save=save, noplot=noplot, /silent 

end
;=============================================================================



;=============================================================================
; grim_logging_callback
;
;=============================================================================
pro grim_logging_callback, data_p, message
 grim_data = *data_p 

 grim_print, grim_data, message
end
;=============================================================================



;=============================================================================
; grim_logging
;
;=============================================================================
pro grim_logging, grim_data, start=start, stop=stop
common grim_logging_block, data_p=data_p

 tag = 'GRIM_LOGGING-'+strtrim(grim_data.base,2)

 if(keyword_set(start)) then $
  begin
   data_p = ptr_new(grim_data)
   nv_message, callback='grim_logging_callback', cb_tag=tag, cb_data_p=data_p
  end $
 else $
  begin
   nv_message, cb_tag=tag, /disconnect
   if(ptr_valid(data_p)) then ptr_free, data_p
   grim_print, grim_data, ''
  end

end
;=============================================================================



;=============================================================================
; grim_menu_delim_event
;
;=============================================================================
pro grim_menu_delim_event, event
end
;=============================================================================



;=============================================================================
; grim_parse_form_entry
;
;=============================================================================
function grim_parse_form_entry, ids, tags, tag, null=null, drop=drop, $
                                            numeric=numeric, string=string

 i = (where(strupcase(tags) EQ strupcase(tag)))[0]

 if(NOT keyword_set(drop)) then $
  begin   
   widget_control, ids[i], get_value=value

   null = 1
   if(NOT keyword_set(numeric)) then $
               if((strmid(value, 0, 1))[0] EQ '-') then return, 0
   null = 0

   if((size(value, /type) EQ 7) AND (NOT keyword_set(string))) then $
                                    value = str_sep(strtrim(value,2), ' ')
  end $
 else value = widget_info(ids[i], /droplist_select)

 if(keyword_set(string)) then value = value[0]

 return, value
end
;=============================================================================



;=============================================================================
; grim_set_form_entry
;
;=============================================================================
pro grim_set_form_entry, ids, tags, tag, value, drop=drop, cwbutton=cwbutton, $
        sensitive=sensitive

 i = (where(tags EQ tag))[0]

 if(n_elements(sensitive) NE 0) then widget_control, ids[i], sensitive=sensitive
 if(n_elements(value) EQ 0) then return

;print, i
 if(keyword_set(drop)) then widget_control, ids[i], set_droplist_select=value $
 else if(keyword_set(cwbutton)) then $
                                widget_control, ids[i], set_value=value $
 else widget_control, ids[i], set_value = strtrim(value,2) + ' '


end
;=============================================================================



;=============================================================================
; grim_add_callback
;
;=============================================================================
pro grim_add_callback, callbacks, data_ps, callbacks_list, data_ps_list

 if(NOT keyword__set(callbacks_list)) then callbacks_list = 0

 if(n_elements(callbacks) NE n_elements(data_ps)) then $
                       nv_message, /anonymous, 'Inconsistent callback registration.'

 if(NOT keyword__set(callbacks_list[0])) then $
  begin
   callbacks_list = callbacks
   data_ps_list = data_ps
  end $ 
 else $
  begin
   callbacks_list = [callbacks_list, callbacks]
   data_ps_list = [data_ps_list, data_ps]
  end

end
;=============================================================================



;=============================================================================
; grim_rm_callback
;
;=============================================================================
pro grim_rm_callback, data_ps, callbacks_list, data_ps_list

 if(NOT keyword__set(data_ps_list[0])) then return

 w = nwhere(data_ps_list, data_ps)
 if(w[0] EQ -1) then return
 ww = complement(data_ps_list, w)

 if(ww[0] EQ -1) then $
  begin
   callbacks_list = 0
   data_ps_list = 0
  end $
 else $
  begin
   callbacks_list = callbacks_list[ww]
   data_ps_list = data_ps_list[ww]
  end


end
;=============================================================================



;=============================================================================
; grim_call_callbacks
;
;=============================================================================
pro grim_call_callbacks, _callbacks_list, _data_ps_list, event

 if(NOT keyword__set(_callbacks_list)) then _callbacks_list = 0
 if(NOT keyword__set(_data_ps_list)) then _data_ps_list = 0
 callbacks_list = _callbacks_list
 data_ps_list = _data_ps_list

 if(keyword__set(callbacks_list[0])) then $
  begin
   n = n_elements(callbacks_list)
   for i=0, n-1 do $
    begin
     callback = callbacks_list[i]
     if(NOT keyword_set(event)) then call_procedure, callback, data_ps_list[i] $
     else call_procedure, callback, data_ps_list[i], event
    end
  end


end
;=============================================================================



;=============================================================================
; grim_get_menu_id
;
;=============================================================================
function grim_get_menu_id, grim_data, desc

 menu_ids = *grim_data.menu_ids_p
 menu_desc = *grim_data.menu_desc_p

 w = where(strpos(menu_desc, desc) NE -1)
 return, menu_ids[w[0]]
end
;=============================================================================



;=============================================================================
; grim_get_menu_value
;
;=============================================================================
function grim_get_menu_value, grim_data, name, suffix=suffix

 if(NOT keyword_set(suffix)) then suffix = ''
 id = grim_get_menu_id(grim_data, name)

 widget_control, id, get_value=s

 ss = str_ext(s, '[', ']')

 return, long(strmid(ss, 0, strlen(ss)-strlen(suffix)))
end
;=============================================================================



;=============================================================================
; grim_set_menu_value
;
;=============================================================================
pro grim_set_menu_value, grim_data, name, value, suffix=suffix, len=len

 if(NOT keyword_set(suffix)) then suffix = ''
 
 id = grim_get_menu_id(grim_data, name)

 widget_control, id, get_value=s

 ss = str_ext(s, '[', ']')

 sval = strtrim(value,2)
 if(keyword_set(len)) then $
  begin
   sval = strmid(sval, 0, len)
   if(keyword_set(suffix)) then sval = strmid(sval, 0, len-strlen(suffix))
  end
 
 sss = strep_s(s, ss, sval+suffix)

 widget_control, id, set_value=sss
end
;=============================================================================



;=============================================================================
; grim_update_menu_toggle
;
;=============================================================================
pro grim_update_menu_toggle, grim_data, name, flag

 id = grim_get_menu_id(grim_data, name)

 onoff = flag ? 'ON' : 'OFF'
 widget_control, id, get_value=s

 ss = str_ext(s, '[', ']')
 sss = strep_s(s, ss, onoff)

 widget_control, id, set_value=sss
end
;=============================================================================



;=============================================================================
; grim_get_toggle_flag
;
;=============================================================================
function grim_get_toggle_flag, grim_data, name

 flag = grim_get_user_data(grim_data, 'GRIM_TOGGLE_' + name)
 if(NOT keyword_set(flag)) then flag = 0

 return, flag
end
;=============================================================================



;=============================================================================
; grim_set_toggle_flag
;
;=============================================================================
pro grim_set_toggle_flag, grim_data, name, flag

 grim_set_user_data, grim_data, 'GRIM_TOGGLE_' + name, flag

end
;=============================================================================



;=============================================================================
; grim_compare
;
;=============================================================================
function grim_compare, x1, x2

 if((NOT keyword_set(x1)) AND (NOT keyword_set(x1))) then return, 1

 nx1 = n_elements(x1)
 nx2 = n_elements(x2)
 
 type1 = size(x1, /type)
 type2 = size(x2, /type)

 if((type1 EQ 7) XOR (type2 EQ 7)) then return, 0

 if(nx1 NE nx2) then return, 0
 if(total(x1 EQ x2) NE nx1) then return, 0

 return, 1
end
;=============================================================================

pro grim_util_include
a=!null
end


