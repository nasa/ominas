;=============================================================================
; grim_mode_zoom_bitmap
;
;=============================================================================
function grim_mode_zoom_bitmap

 return, [                               $
                [255B, 255B],                   $
                [001B, 192B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 159B],                   $
                [253B, 159B],                   $
                [253B, 159B],                   $
                [001B, 128B],                   $
                [255B, 131B],                   $
                [255B, 255B]                    $
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_zoom_mouse_event
;
;=============================================================================
pro grim_mode_zoom_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 minbox = 5
 aspect = double(!d.y_size)/double(!d.x_size)

 if(event.press EQ 1) then $
      tvzoom, [1], input_wnum, /noplot, $
	       p0=[event.x,event.y], cursor=78, hour=event.id, $
	       output=output_wnum, minbox=minbox, aspect=aspect, $ 
	       color=ctred() $
 else if(event.press EQ 4) then $
       tvunzoom, [1], input_wnum, /noplot, $
		  p0=[event.x,event.y], cursor=78, hour=event.id, $
		  output=output_wnum, minbox=minbox, aspect=aspect, $
		  color=ctred() $
 else return

 grim_wset, grim_data, output_wnum
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
; grim_mode_zoom_mode
;
;=============================================================================
pro grim_mode_zoom_mode, grim_data, data_p

 device, cursor_standard = 144
 grim_print, grim_data, 'ZOOM -- L:Increase R:Decrease'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_zoom_button_event
;
;
; PURPOSE:
;	Selects the zoom cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	The image zoom and offset are controlled by selecting
;	a box in the image.  When the box is created using the
;	left mouse button, zoom and offset are changed so that 
;	the contents of the box best fill the current graphics
;	window.  When the right button is used, the contents of
;	the current graphics window are shrunken so as to best
;	fill the box.  In other words, the left button zooms in
;	and the right button zooms out.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_mode_zoom_button_help_event, event
 text = ''
 nv_help, 'grim_mode_zoom_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_zoom_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Zoom in/out'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_zoom', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_zoom_init
;
;=============================================================================
pro grim_mode_zoom_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_zoom
;
;=============================================================================
function grim_mode_zoom, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_zoom', $
		 event_pro:	'*grim_mode_zoom_button_event', $
                 bitmap:	 grim_mode_zoom_bitmap(), $
                 menu:		'Zoom', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
