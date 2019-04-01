;=============================================================================
; grs_update_form
;
;=============================================================================
pro grs_update_form, grim_data, base

 widget_control, base, get_uvalue=data

 data.grim_data = grim_data


 ;-----------------------------------------------------
 ; set form entries
 ;-----------------------------------------------------
 settings = *grim_data.settings_p
 controls = data.controls
 nsettings = n_elements(settings)

 for i=0, n_elements(settings)-1 do $
  begin
   setting = settings[i]
   control = controls[i]

   tags = tag_names(grim_data)
   w = where(tags EQ setting.name)
   value = grim_data.(w)

   type = widget_info(control, /type)

   case type of
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; base: must be boolean button group
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    0 : widget_control, control, set_value=1-value

    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; slider
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    2 : begin
         widget_control, control, $
             set_slider_min=setting.range[0], set_slider_max=setting.range[1]
         widget_control, control, set_value=value
        end

    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; text
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    3 : widget_control, control, set_value=string(strtrim(value,2))

    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; droplist
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    8 : widget_control, control, set_droplist_select=value

    else :
   endcase
  end


end
;=============================================================================



;=============================================================================
; grs_cleanup
;
;=============================================================================
pro grs_cleanup, base
common grim_settings_block, tops

 widget_control, base, get_uvalue=data

 w = where(tops EQ data.top)
 if(w[0] NE -1) then tops = rm_list_item(tops, w, only=-1)

end
;=============================================================================



;=============================================================================
; grs_apply_settings
;
;=============================================================================
pro grs_apply_settings, data
@grim_constants.common

 grim_data = data.grim_data
 if(NOT grim_exists(grim_data)) then return

 settings = *grim_data.settings_p
 controls = data.controls
 nsettings = n_elements(settings)

 for i=0, n_elements(settings)-1 do $
  begin
   setting = settings[i]
   control = controls[i]

   tags = tag_names(grim_data)
   w = where(tags EQ setting.name)

   type = widget_info(control, /type)
   typecode = size(grim_data.(i), /type)

   case type of
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; base: must be boolean button group
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    0 : begin
         widget_control, control, get_value=value
         value = 1-value
        end

    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; slider
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    2 : widget_control, control, get_value=value

    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; text
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    3 : begin
         widget_control, control, get_value=value
         if(type NE 7) then value = double(value)
        end

    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    ; droplist
    ;- - - - - - - - - - - - - - - - - - - - - - - - - -
    8 : value = widget_info(control, /droplist_select)

    else :
   endcase
 
   grim_data.(w) = value
   settings[i] = setting

;   if(keyword_set(setting.callback)) then $
;                call_procedure, setting.callback, grim_data, setting.data
  end



 grim_set_data, grim_data, grim_data.base
 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
; grs_ok
;
;=============================================================================
pro grs_ok, data, base

 grs_apply_settings, data
 widget_control, base, /destroy

end
;=============================================================================



;=============================================================================
; grim_settings_event
;
;=============================================================================
pro grim_settings_event, event

 if(widget_info(event.id, /type) NE 1) then return

 ;-----------------------------------------------
 ; get form base and data
 ;-----------------------------------------------
 base = event.top
 widget_control, base, get_uvalue=data

 ;-----------------------------------------------
 ; get form value structure
 ;-----------------------------------------------
 widget_control, event.id, get_value=value


 ;-----------------------------------------------
 ; switch on item tag
 ;-----------------------------------------------
 if(size(value, /type) EQ 7) then $
  case strupcase(value) of
   ;---------------------------------------------------------
   ; 'Cancel' button --
   ;  Just destroy the form and forget about it
   ;---------------------------------------------------------
   'CANCEL' :  widget_control, base, /destroy

   ;---------------------------------------------------------
   ; 'Apply' button --
   ;  Apply the current settings.
   ;---------------------------------------------------------
   'APPLY' : grs_apply_settings, data

   ;---------------------------------------------------------
   ; 'Ok' button --
   ;  Apply the current settings and destroy the form.
   ;---------------------------------------------------------
   'OK' : grs_ok, data, base

   else: if(size(event.value, /type) EQ 7) then grs_ok, data, base
  endcase


end
;=============================================================================



;=============================================================================
; grs_array_set
;
;=============================================================================
function grs_array_set, array
 for i=0, n_elements(array)-1 do if(keyword_set(array[i])) then return, 1
 return, 0
end
;=============================================================================



;=============================================================================
; grim_settings
;
;=============================================================================
pro grim_settings, grim_data
common grim_settings_block, tops

 if(NOT keyword_set(tops)) then tops = -1

 ;------------------------------------------------------------
 ; only one overlay settings widget allowed per grim window
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
 ; widgets
 ;-----------------------------------------------
 base = widget_base(/column, $
       title = 'GRIM Settings - grim ' + strtrim(grim_data.grn,2))

 ;- - - - - - - - - - - - - - - -
 ; Settings
 ;- - - - - - - - - - - - - - - -
 settings = *grim_data.settings_p
 nsettings = n_elements(settings)
 settings_base = widget_base(base, /column, /frame)
 controls = lonarr(nsettings)
 for i=0, nsettings-1 do $
  begin
   setting = settings[i]
   setting_base = widget_base(settings_base, /row, /frame)
   label = widget_label(setting_base, value=str_pad(strupcase(setting.name), 16)+':  ')

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Use non-exclusive button for boolean values
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(setting.boolean) then $
     control = cw_bgroup(setting_base, ['On', 'Off'], /exclusive, /row) $

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Use slider if range is specified
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else if(grs_array_set(setting.range)) then $
                                     control = widget_slider(setting_base) $

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Use droplist if options specified
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else if(grs_array_set(setting.options)) then $
             control = widget_droplist(setting_base, value=str_cull(setting.options)) $

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Otherwise use a text widget
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else control = widget_text(setting_base, /editable)

   controls[i] = control
  end


 ;-----------------------------------------------------
 ; controls
 ;-----------------------------------------------------
 button_base = widget_base(base, /row)
 ok_button = widget_button(button_base, value='Ok')
 apply_button = widget_button(button_base, value='Apply')
 cancel_button = widget_button(button_base, value='Cancel')



 ;-----------------------------------------------
 ; save data
 ;-----------------------------------------------
 data = { $
		base			:	base, $
		top			:	top, $
		grim_data		:	grim_data, $
		controls		:	controls, $
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
 grs_update_form, grim_data, base
 widget_control, base, /map


 xmanager, 'grim_settings', base, /no_block, cleanup='grs_cleanup'



end
;=============================================================================



