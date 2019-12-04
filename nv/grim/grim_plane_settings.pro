;=============================================================================
; grps_overlay_tag
;
;=============================================================================
function grps_overlay_tag, i, name
 return, strupcase('PLANES_' + name + '_' + strtrim(i, 2))
end
;=============================================================================



;=============================================================================
; grps_update_form
;
;=============================================================================
pro grps_update_form, grim_data, plane, base

 widget_control, base, get_uvalue=data

 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 ;-----------------------------------------------------
 ; set form entries
 ;-----------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - -
 ; channels
 ;- - - - - - - - - - - - - - - - - - - - - - -
 for i=0, nplanes-1 do $
   grim_set_form_entry, data.ids, data.tags, grps_overlay_tag(i,'rgb'), planes[i].rgb, /cwbutton


 ;- - - - - - - - - - - - - - - - - - - - - - -
 ; visibility toggles
 ;- - - - - - - - - - - - - - - - - - - - - - -
 for i=0, nplanes-1 do $
  grim_set_form_entry, data.ids, data.tags, $
                grps_overlay_tag(i,'dvis'), planes[i].visibility, /cwbutton

 for i=0, nplanes-1 do $
  grim_set_form_entry, data.ids, data.tags, $
                grps_overlay_tag(i,'ovis'), planes[i].visible, /cwbutton


 ;- - - - - - - - - - - - - - - - - - - - - - -
 ; override colors
 ;- - - - - - - - - - - - - - - - - - - - - - -
 for i=0, nplanes-1 do $
  begin
   w = where(data.colors EQ planes[i].override_color)
   grim_set_form_entry, data.ids, data.tags, $
                         grps_overlay_tag(i,'color'), w[0], /drop
  end


 widget_control, base, set_uvalue=data
end
;=============================================================================



;=============================================================================
; grps_invert
;
;=============================================================================
pro grps_invert, data, base, s

 p = strpos(data.tags, 'PLANES_' + s)
 w = where(p NE -1)
 n = n_elements(w)

 tags = data.tags[w]
 pns = long(strmid(tags, 12,11))

 for i=0, n-1 do $
  begin
   val = byte(grim_parse_form_entry(data.ids, data.tags, tags[i]))
   grim_set_form_entry, data.ids, data.tags, tags[i], 1-val, /cwbutton
  end

end
;=============================================================================



;=============================================================================
; grps_cleanup
;
;=============================================================================
pro grps_cleanup, base
common grim_plane_settings_block, tops

 widget_control, base, get_uvalue=data


 w = where(tops EQ data.top)
 if(w[0] NE -1) then tops = rm_list_item(tops, w, only=-1)

end
;=============================================================================



;=============================================================================
; grps_apply_settings
;
;=============================================================================
pro grps_apply_settings, data

 grim_data = grim_get_data(data.top)
 if(NOT grim_exists(grim_data)) then return


 ;--------------------
 ; all
 ;--------------------
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)


 onoff = ['ON', 'OFF']

 for i=0, nplanes-1 do $
  begin
   ;-----------------------
   ; RGB
   ;-----------------------
   planes[i].rgb = float(grim_parse_form_entry(data.ids, data.tags, grps_overlay_tag(i,'rgb')))

   ;-----------------------
   ; visibility
   ;-----------------------
   planes[i].visibility = byte(grim_parse_form_entry(data.ids, data.tags, grps_overlay_tag(i,'dvis')) NE 0)
   planes[i].visible = byte(grim_parse_form_entry(data.ids, data.tags, grps_overlay_tag(i,'ovis')) NE 0)

   ;-----------------------
   ; override color
   ;-----------------------
   color = data.colors[grim_parse_form_entry(data.ids, data.tags, $
                                         grps_overlay_tag(i,'color'), /drop)]
   planes[i].override_color = color


   grim_set_plane, grim_data, planes[i], pn=planes[i].pn
  end

 grim_set_data, grim_data, grim_data.base
 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
; grps_ok
;
;=============================================================================
pro grps_ok, data, base

 grps_apply_settings, data
 widget_control, base, /destroy

end
;=============================================================================



;=============================================================================
; grim_plane_settings_event
;
;=============================================================================
pro grim_plane_settings_event, event

 ;-----------------------------------------------
 ; get form base and data
 ;-----------------------------------------------
 base = event.top
 widget_control, base, get_uvalue=data
 struct = tag_names(event, /struct)

 grim_data = grim_get_data(data.top)

 ;-----------------------------------------------
 ; adjust base size
 ;-----------------------------------------------
 if(struct EQ 'WIDGET_BASE') then $
  begin
   dx = event.x - data.base_xsize
   dy = event.y - data.base_ysize

   w = where(data.tags EQ 'SCROLL_BASE')
   widget_control, data.ids[w], $
         scr_xsize=data.scroll_xsize+dx, scr_ysize=data.scroll_ysize+dy

   geom = widget_info(base, /geom)
   data.base_xsize = geom.xsize
   data.base_ysize = geom.ysize

   geom = widget_info(data.ids[w], /geom)
   data.scroll_xsize = geom.scr_xsize
   data.scroll_ysize = geom.scr_ysize

   widget_control, base, set_uvalue=data
   return
  end


 ;-----------------------------------------------
 ; get form value structure
 ;-----------------------------------------------
 widget_control, event.id, get_value=value


 ;----------------------------------------
 ; check for plane button
 ;----------------------------------------
 if(strmid(event.tag, 0, 12) EQ 'PLANES_LABEL') then $
  begin
   pn = long(strmid(event.tag, 13, 100))
   grim_jump_to_plane, grim_data, pn
   grim_refresh, grim_data
   return
  end

 ;-----------------------------------------------
 ; switch on item tag
 ;-----------------------------------------------
 case event.tag of
  ;---------------------------------------------------------
  ; 'Cancel' button --
  ;  Just destroy the form and forget about it
  ;---------------------------------------------------------
  'CANCEL' :  widget_control, base, /destroy

  ;---------------------------------------------------------
  ; 'Apply' button --
  ;  Apply the current settings.
  ;---------------------------------------------------------
  'APPLY' : grps_apply_settings, data

  ;---------------------------------------------------------
  ; 'Ok' button --
  ;  Apply the current settings and destroy the form.
  ;---------------------------------------------------------
  'OK' : grps_ok, data, base

  ;---------------------------------------------------------
  ; 'Invert Channels' button --
  ;  Invert all RGB settings
  ;---------------------------------------------------------
  'INVERT_RGB' : grps_invert, data, base, 'RGB'

  ;---------------------------------------------------------
  ; 'Invert Visibility' button --
  ;  Invert all visibility settings
  ;---------------------------------------------------------
  'INVERT_DVIS' : grps_invert, data, base, 'DVIS'

  ;---------------------------------------------------------
  ; 'Invert Overlay Visibility' button --
  ;  Invert all overlay visibility settings
  ;---------------------------------------------------------
  'INVERT_OVIS' : grps_invert, data, base, 'OVIS'

  else: if(size(event.value, /type) EQ 7) then grps_ok, data, base
 endcase


end
;=============================================================================



;=============================================================================
; grim_plane_settings
;
;=============================================================================
pro grim_plane_settings, grim_data
common grim_plane_settings_block, tops

 if(NOT keyword_set(tops)) then tops = -1

 ;------------------------------------------------------------
 ; only one plane settings widget allowed per grim window
 ;------------------------------------------------------------
 top = grim_data.base
 if(tops[0] EQ -1) then tops = top $
 else $
  begin
   w = where(tops EQ top)
   if(w[0] NE -1) then return
   tops = [tops, top]
  end



 ;-----------------------------------------------
 ; settings form widget
 ;-----------------------------------------------
 base = widget_base(title = 'GRIM Plane Settings - grim ' + strtrim(grim_data.grn,2), /tlb_size_events)

 blank = '0'
 colors = ['none', $
           'red', $
           'brown', $
           'orange', $
           'yellow', $
           'green', $
           'blue', $
           'cyan', $
           'pink', $
           'purple', $
           'white']
 ncolors = n_elements(colors)
 dl_colors = colors[0]
 for i=1, ncolors-1 do dl_colors = dl_colors + '|' + colors[i]

 ;- - - - - - - - - - - 
 ; top part
 ;- - - - - - - - - - - 
 blank = '0'
 desc = [ $
	'1, BASE,, COLUMN, FRAME, TAG=planes_base', $
	  '0, BASE,, ROW, TAG=overlay_label_base']

 ;- - - - - - - - - - - 
 ; planes list
 ;- - - - - - - - - - - 
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 desc = [desc, $
	'1, BASE,, COLUMN, FRAME, TAG=mid_base', $
	  '0, LABEL,Plane       Channels          Data Visibility      Overlay Visibility   Override Color, TAG=scroll_label, LEFT', $
	  '3, BASE,, COLUMN, FRAME, SCROLL, TAG=scroll_base']

 for i=0, nplanes-1 do $
  begin 
   desc = [desc, $
	'1, BASE,, ROW, TAG=planes_base_' + strtrim(i,2), $
	  '0, BUTTON, ' + str_pad(strtrim(i,2),4) + ':,, TAG=' + grps_overlay_tag(i,'label'), $
	  '0, BUTTON, R|G|B, ROW, SET_VALUE=' + blank + $
	           ', TAG=' + grps_overlay_tag(i,'rgb'), $
	  '0, BUTTON, Normal|Always, EXCLUSIVE, ROW, SET_VALUE=' + blank + $
	           ', TAG=' + grps_overlay_tag(i,'dvis'), $
	  '0, BUTTON, Normal|Always, EXCLUSIVE, ROW, SET_VALUE=' + blank + $
	           ', TAG=' + grps_overlay_tag(i,'ovis'), $
	  '2, DROPLIST,' + dl_colors + ', TAG=' + grps_overlay_tag(i,'color') + $
	       ',SET_VALUE=']
 end
 desc = [desc, $
         '2, LABEL, , CENTER']


 ;- - - - - - - - - - - - - - - - - - - - - -
 ; Other functions
 ;- - - - - - - - - - - - - - - - - - - - - -
 desc = [desc, $
	  '1, BASE,, ROW, FRAME', $
	   '0, BUTTON, Invert Channels, TAG=invert_rgb', $
	   '0, BUTTON, Invert Data Visibility, TAG=invert_dvis', $
	   '2, BUTTON, Invert Overlay Visibility, TAG=invert_ovis']

 ;- - - - - - - - - - - - - - - - - - - - - -
 ; Ok, Apply, and Cancel buttons
 ;- - - - - - - - - - - - - - - - - - - - - -
 desc = [desc, $
	  '1, BASE,, ROW, FRAME', $
	   '0, BUTTON, Ok, QUIT, TAG=ok', $
	   '0, BUTTON, Apply,, TAG=apply', $
	   '2, BUTTON, Cancel, QUIT, TAG=cancel']


 ;-----------------------------------------------------
 ; create the form widget
 ;-----------------------------------------------------
 form = cw__form(base, desc, ids=ids, tags=tags)
 widget_control, form, set_uvalue={ids:ids, tags:tags}

 w = where(tags EQ 'SCROLL_BASE')
 widget_control, ids[w[0]], scr_xsize=550, scr_ysize=600


 ;-----------------------------------------------
 ; save data
 ;-----------------------------------------------
 data = { $
		base			:	base, $
		ids			:	ids, $
		tags			:	tags, $
		colors			:	colors, $
		top			:	top, $
		base_xsize		:	0l, $
		base_ysize		:	0l, $
		scroll_xsize		:	0l, $
		scroll_ysize		:	0l, $
		data_p			:	nv_ptr_new() $
	     }

 data.data_p = nv_ptr_new(data)
 widget_control, base, set_uvalue=data, map=0


 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize


 ;-----------------------------------------------------
 ; set initial form entries
 ;-----------------------------------------------------
 grps_update_form, grim_data, plane, base
 widget_control, base, /map


 xmanager, 'grim_plane_settings', base, /no_block, cleanup='grps_cleanup'

 geom = widget_info(base, /geom)
 data.base_xsize = geom.xsize
 data.base_ysize = geom.ysize

 w = where(tags EQ 'SCROLL_BASE')
 geom = widget_info(ids[w], /geom)
 data.scroll_xsize = geom.scr_xsize
 data.scroll_ysize = geom.scr_ysize

 widget_control, base, set_uvalue=data

end
;=============================================================================
