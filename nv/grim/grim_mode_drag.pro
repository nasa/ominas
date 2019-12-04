;=============================================================================
; grim_mode_drag_bitmap
;
;=============================================================================
function grim_mode_drag_bitmap

 return, [                               $
                [255B, 255B],                   $
                [031B, 128B],                   $
                [223B, 191B],                   $
                [127B, 190B],                   $
                [079B, 178B],                   $
                [079B, 178B],                   $
                [015B, 240B],                   $
                [011B, 128B],                   $
                [009B, 128B],                   $
                [009B, 128B],                   $
                [097B, 155B],                   $
                [001B, 128B],                   $
                [001B, 128B],                   $
                [003B, 192B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
               ]


end
;=============================================================================



;=============================================================================
; grim_mode_drag_translate
;
;=============================================================================
pro grim_mode_drag_translate, data, xarr, yarr, pixmap, win_num

 dxy = [xarr[1]-xarr[0], yarr[1]-yarr[0]]

 device, set_gr=7
 device, copy=[0,0, !d.x_size,!d.y_size, dxy[0],dxy[1], data.pixmap]
 device, set_gr=3
end
;=============================================================================



;=============================================================================
; grim_mode_drag_mouse_event
;
;=============================================================================
pro grim_mode_drag_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 if(event.press EQ 1) then $
  begin
   grim_refresh, grim_data, plane=plane, current=1, /no_objects, /no_axes, $
          /no_context, /no_callback, /no_back, /no_coord, /no_copy, /noglass

   p0 = [event.x, event.y]
   fn = ''
   fn_data = {grim_data:grim_data, pixmap:grim_data.redraw_pixmap}

   fn = 'translate'
   if(keyword_set(fn)) then $
        pp = tvline(p0=p0, fn_draw='grim_mode_drag_'+fn, fn_data=fn_data)

   xy = (convert_coord(double(pp[0,*]), double(pp[1,*]), /device, /to_data))[0:1,*]
   dxy = xy[*,0] - xy[*,1]
   grim_reposition, grim_data, plane, cd=grim_xd(plane, /cd), -dxy
  end



end
;=============================================================================



;=============================================================================
; grim_mode_drag_mode
;
;=============================================================================
pro grim_mode_drag_mode, grim_data, data_p

 device, cursor_standard = 52
 grim_print, grim_data, $
;      'DRAG IMAGE -- L:Translate, R:Rotate'
      'DRAG IMAGE -- L:Translate'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_drag_button_event
;
;
; PURPOSE:
;	Selects the drag cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Allow the user to drag the image.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2009
;	
;-
;=============================================================================
pro grim_mode_drag_button_help_event, event
 text = ''
 nv_help, 'grim_mode_drag_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_drag_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Drag image'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_drag', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_drag_init
;
;=============================================================================
pro grim_mode_drag_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_drag
;
;=============================================================================
function grim_mode_drag, arg

 data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_drag', $
		 event_pro:	'*grim_mode_drag_button_event', $
                 bitmap:	 grim_mode_drag_bitmap(), $
                 menu:		'Drag', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
