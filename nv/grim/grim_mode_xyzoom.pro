;=============================================================================
; grim_mode_xyzoom_bitmap
;
;=============================================================================
function grim_mode_xyzoom_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [001B, 192B],                   $
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
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_xyzoom_mouse_event
;
;=============================================================================
pro grim_mode_xyzoom_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 minbox = 5
 if(event.press EQ 1) then $
      tvzoom, [1], input_wnum, /noplot, $
	       p0=[event.x,event.y], cursor=78, hour=event.id, $
	       output=output_wnum, minbox=minbox, $ 
	       color=ctred(), /xy $
 else if(event.press EQ 4) then $
       tvunzoom, [1], input_wnum, /noplot, $
		  p0=[event.x,event.y], cursor=78, hour=event.id, $
		  output=output_wnum, minbox=minbox, $
		  color=ctred(), /xy $
 else return

 grim_wset, grim_data, output_wnum
 grim_refresh, grim_data

end
;=============================================================================


;=============================================================================
; grim_mode_xyzoom_cursor
;
;=============================================================================
pro grim_mode_xyzoom_cursor, swap=swap



 mask = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 bitmap = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,1,1,1,1] ,[1,1,1,1,1,1,0,0]], $
                        [[0,0,1,1,1,1,1,1] ,[1,1,1,1,1,1,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [2,9]
;                                                            cursor_xy = [2,13]


end
;=============================================================================



;=============================================================================
; grim_mode_xyzoom_mode
;
;=============================================================================
pro grim_mode_xyzoom_mode, grim_data, data_p

 grim_mode_xyzoom_cursor, swap=swap
 grim_print, grim_data, 'XYZOOM -- L:Increase R:Decrease'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_xyzoom_button_event
;
;
; PURPOSE:
;	Selects the xy-zoom cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Same as 'zoom' mode, except the aspect ratio is set by the 
;	proportions of the selected box.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_mode_xyzoom_button_help_event, event
 text = ''
 nv_help, 'grim_mode_xyzoom_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_xyzoom_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'XY Zoom in/out'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_xyzoom', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_xyzoom_init
;
;=============================================================================
pro grim_mode_xyzoom_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_xyzoom
;
;=============================================================================
function grim_mode_xyzoom, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_xyzoom', $
		 event_pro:	'*grim_mode_xyzoom_button_event', $
                 bitmap:	 grim_mode_xyzoom_bitmap(), $
                 menu:		'XY Zoom', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
