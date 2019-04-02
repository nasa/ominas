;=============================================================================
; grim_mode_pan_plot_bitmap
;
;=============================================================================
function grim_mode_pan_plot_bitmap

 return, [                               $
                [255B, 255B],                   $
                [127B, 254B],                   $
                [063B, 252B],                   $
                [031B, 248B],                   $
                [127B, 254B],                   $
                [119B, 238B],                   $
                [115B, 206B],                   $
                [001B, 128B],                   $
                [001B, 128B],                   $
                [115B, 206B],                   $
                [119B, 238B],                   $
                [127B, 254B],                   $
                [031B, 248B],                   $
                [063B, 252B],                   $
                [127B, 254B],                   $
                [255B, 255B]                    $
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_pan_plot_mouse_event
;
;=============================================================================
pro grim_mode_pan_plot_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 tvgr, input_wnum
 if(event.press EQ 1) then $
  begin
   ln = tvline(p0=[event.x, event.y], col=ctred())
   line = convert_coord(double(ln[0,*]), double(ln[1,*]), /device, /to_data)
   dx = line[0,0]-line[0,1]
   dy = line[1,0]-line[1,1]
   tvgr, output_wnum
   grim_refresh, grim_data, dx=dx, dy=dy
  end $
 else if(event.press EQ 4) then $
  begin
   p = convert_coord(double(event.x), double(event.y), /device, /to_data)
   tvgr, output_wnum
   cx = !d.x_size/2
   cy = !d.y_size/2
   q = convert_coord(double(cx), double(cy), /device, /to_data)
   grim_refresh, grim_data, dx=p[0]-q[0], dy=p[1]-q[1]
  end

end
;=============================================================================



;=============================================================================
; grim_mode_pan_plot_mode
;
;=============================================================================
pro grim_mode_pan_plot_mode, grim_data, data_p

 device, cursor_standard = 52
 grim_print, grim_data, 'PAN -- L:Pan R:Recenter'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_pan_plot_button_event
;
;
; PURPOSE:
;	Selects the pan cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	The image offset is controlled by selecting an offset vector
;	using the left mouse button, or the middle button may be
;	used to center the image on a selected point.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_mode_pan_plot_button_help_event, event
 text = ''
 nv_help, 'grim_mode_pan_plot_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_pan_plot_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Recenter image'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_pan_plot', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_pan_plot_init
;
;=============================================================================
pro grim_mode_pan_plot_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_pan_plot
;
;=============================================================================
function grim_mode_pan_plot, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_pan_plot', $
		 event_pro:	'%grim_mode_pan_plot_button_event', $
                 bitmap:	 grim_mode_pan_plot_bitmap(), $
                 menu:		'Pan', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
