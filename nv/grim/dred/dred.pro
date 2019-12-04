;=============================================================================
; dred_update_form
;
;=============================================================================
pro dred_update_form, data, class

end
;=============================================================================



;=============================================================================
; dred_update_form
;
;=============================================================================
pro dred_update_form, data

 done = 0

stop
 sub_bases = *data.sub_bases_p
 for jj=0, n_elements(sub_bases)-1 do $
  begin
print, jj
   field_base = widget_info(sub_bases[jj], /child)
   while(NOT done) do $
    begin
     field_row_base = widget_info(field_base, /child)

     lab = widget_info(field_row_base, /child)

     if(NOT keyword_set(lab)) then done = 1 $
     else $
      begin
       widget_control, lab, get_value=field_name
       field_name = strtrim(field_name,2)
       field_name = strmid(field_name, 0, strlen(field_name)-1)
help, field_name

       val = cor_get_field(data.xd, field_name)

       n = n_elements(val)
       text = widget_info(lab, /sibling)
       for ii=0, n-1 do $
        begin
         if(size(val, /type) NE 10) then $
               widget_control, text, set_value=strtrim(val[ii],2)
         text = widget_info(text, /sibling)
        end

       field_base = widget_info(field_base, /sibling)
       if(NOT keyword_set(field_base)) then done = 1
      end
    end

  end

end
;=============================================================================



;=============================================================================
; dred_configure_xd
;
;=============================================================================
function dred_configure_xd, base, xd

 sub_base = widget_base(base, /col, map=0)

 fields = cor_get_field_names(xd)
 nfields = n_elements(fields)

 label_size = max(strlen(fields)) + 1

 for i=0, nfields-1 do $
  begin
   field = cor_get_field(xd, fields[i])
   dim = size(field, /dim)
   if(n_elements(dim) EQ 1) then dim = [dim,1]
   if(dim[0] EQ 0) then dim[0] = 1

   field_base = widget_base(sub_base, /col)
   for j=0, dim[1]-1 do $
    begin
     field_row_base = widget_base(field_base, /row)
     label = widget_label(field_row_base)
     if(j EQ 0) then $
       widget_control, label, $
             set_value=str_pad(fields[i]+':', label_size, align=1.0) $
     else $
       widget_control, label, $
             set_value=str_pad(' ', label_size, align=1.0) 
  
     text_size = 18 / (0.75*dim[0]) > 4 < 18
     for k=0, dim[0]-1 do $
        text = widget_text(field_row_base, xsize=text_size, ysize=1, /ed)
    end
     
  end

 widget_control, sub_base, /map

 return, sub_base
end
;=============================================================================



;=============================================================================
; dred_switch_class
;
;=============================================================================
pro dred_switch_class, data, class

 sub_bases = *data.sub_bases_p
 class_buttons = *data.class_buttons_p
 classes = *data.classes_p

 ;-----------------------------
 ; clear state
 ;-----------------------------
 for i=0, n_elements(classes)-1 do $
  begin
   widget_control, sub_bases[i], map=0
   widget_control, class_buttons[i], sensitive=1
  end

 ;-------------------------------------
 ; set new class
 ;-------------------------------------
 w = (where(classes EQ class))[0]
 widget_control, sub_bases[w], map=1
 widget_control, class_buttons[w], sensitive=0

end
;=============================================================================



;=============================================================================
; dred_switch_xd
;
;=============================================================================
pro dred_switch_xd, datas, ii

 ;---------------------------------
 ; clear state
 ;---------------------------------
 for i=0, n_elements(datas)-1 do widget_control, datas[i].tab_base, map=0


 ;-----------------------------
 ; set new xd
 ;-----------------------------
 widget_control, datas[ii].tab_base, map=1

 ;-----------------------------------------
 ; set correct class for the new xd
 ;-----------------------------------------
 classes = *datas[ii].classes_p
 class_buttons = *datas[ii].class_buttons_p

class = classes[0]
; for i=0, n_elements(classes)-1 do $
;   if(NOT widget_info(class_buttons[i], /sensitive)) then class = classes[i]

 dred_switch_class, datas[ii], class
end
;=============================================================================



;=============================================================================
; dred_resize
;
;=============================================================================
pro dred_resize, datas

 for i=0, n_elements(datas)-1 do $
  begin
   field_geom = widget_info(datas[i].field_base, /geom)
   base_geom = widget_info(datas[i].base, /geom)
   widget_control, datas[i].field_base, scr_ysize=base_geom.ysize-field_geom.yoffset
  end

end
;=============================================================================



;=============================================================================
; dred_event
;
;=============================================================================
pro dred_event, event

 base = event.top

 widget_control, base, get_uvalue=dat
 datas = dat.datas
 ii = dat.ii
 data = datas[ii]

 struct = tag_names(event, /struct)

 ;-----------------------------------------------
 ; size events
 ;-----------------------------------------------
 if(struct EQ 'WIDGET_BASE') then $
  begin
   widget_control, event.id, xsize=event.x, ysize=event.y
   dred_resize, datas
   return
  end

 ;-----------------------------------------------
 ; switch xd 
 ;-----------------------------------------------
;stop
 if(struct EQ 'WIDGET_DROPLIST') then $
  begin
   ii = event.index
   dred_switch_xd, datas, ii
   return
  end

 widget_control, event.id, get_uvalue=uvalue
 widget_control, event.id, get_value=value

 ;-----------------------------------------------
 ; class buttons
 ;-----------------------------------------------
 if(uvalue = 'class_button') then dred_switch_class, data, value

 datas[ii] = data
 widget_control, base, set_uvalue={ii:ii, datas:datas}

end
;=============================================================================



;=============================================================================
; dred_cleanup
;
;=============================================================================
pro dred_cleanup, base
end
;=============================================================================



;=============================================================================
; dred
;
;=============================================================================
pro dred, xd

 if(NOT keyword_set(xd)) then return
 if(NOT obj_valid(xd[0])) then return

 ;-----------------------------------------------
 ; settings form widget
 ;-----------------------------------------------
 base = widget_base(title = 'DRED', /tlb_size_events, /col, $
            xsize=400, ysize=400, resource_name='dred_base')

 button_base = widget_base(base, /row, /frame)

 apply_button = widget_button(button_base, value='Apply')

 nxd = n_elements(xd)
 index_drop = widget_droplist(button_base, value=cor_name(xd))

 tab_base_base = widget_base(button_base)

 for ii=0, nxd-1 do $
  begin
   map = 1
   if(ii NE 0) then map = 0

   tab_base = widget_base(tab_base_base, /row, /frame, map=map, xoffset=0)
   field_base = widget_base(base, /frame, /scroll, $
                     resource_name='dred_field_base', map=map)
 
   classes = rotate(cor_tree(xd[ii]), 2)
   nclasses = n_elements(classes)

   class_buttons = lonarr(nclasses)
   for i=0, nclasses-1 do $
    class_buttons[i] = widget_button(tab_base, value=classes[i], uvalue='class_button')

   sub_bases = lonarr(nclasses)
   for i=0, nclasses-1 do $
    sub_bases[i] = dred_configure_xd(field_base, cor_extract(xd[ii], classes[i]))

   ;-----------------------------------------------
   ; save data
   ;-----------------------------------------------
   datas = append_array(datas, {_dred_data, $
		xd			:	xd[ii], $
		base			:	base, $
		tab_base		:	tab_base, $
		class_buttons_p		: 	nv_ptr_new(class_buttons), $
		field_base		:	field_base, $
		sub_bases_p		:	nv_ptr_new(sub_bases), $
		classes_p		:	nv_ptr_new(classes) $
		})

   dred_update_form, datas[ii]

  end

 widget_control, base, set_uvalue={ii: 0, datas:datas}, map=0


 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 dred_resize, datas
 widget_control, base, /map


 xmanager, 'dred', base, /no_block, cleanup='dred_cleanup'

 
 dred_switch_xd, datas, 0
 dred_switch_class, datas[0], classes[0]
end
;=============================================================================



