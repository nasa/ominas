;=============================================================================
; grim_mode_trim_bitmap
;
;=============================================================================
function grim_mode_trim_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [223B, 255B],                   $
                [003B, 192B],                   $
                [131B, 239B],                   $
                [031B, 240B],                   $
                [223B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_trim_mouse_event
;
;=============================================================================
pro grim_mode_trim_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 if(input_wnum NE grim_data.wnum) then return


 if(event.press EQ 1) then $
  begin
   region = pg_select_region(0, $
		p0=[event.x,event.y], $
		/autoclose, /silent, color=ctred(), $
		cancel_button=2, end_button=-1, select_button=1) 
   grim_trim_overlays, grim_data, plane=plane, region
  end $
 else if(event.press EQ 4) then $
  begin
   region = pg_select_region(0, $
		p0=[event.x,event.y], $
		/autoclose, /silent, color=ctpurple(), $
		cancel_button=2, end_button=-1, select_button=4)
   grim_trim_user_overlays, grim_data, plane=plane, region
  end $
 else return

 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================


;=============================================================================
; grim_mode_trim_cursor
;
;=============================================================================
pro grim_mode_trim_cursor, swap=swap



 mask = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,1,1,1,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,0,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,0,0,0]], $
                      [[0,0,0,0,1,1,1,1] ,[1,1,1,1,0,0,0,0]], $
                      [[0,0,0,0,1,1,1,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 bitmap = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,1,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,1,1,1,1] ,[1,1,1,1,1,1,0,0]], $
                        [[0,0,1,1,1,1,1,0] ,[0,0,0,0,1,0,0,0]], $
                        [[0,0,0,0,0,1,1,1] ,[1,1,1,1,0,0,0,0]], $
                        [[0,0,0,0,0,1,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )


 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [15,10]


end
;=============================================================================



;=============================================================================
; grim_mode_trim_mode
;
;=============================================================================
pro grim_mode_trim_mode, grim_data, data_p

 grim_mode_trim_cursor, swap=swap
 grim_print, grim_data, 'TRIM OVERLAYS -- L:Standard M:Cancel R:User'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_trim_button_event
;
;
; PURPOSE:
;	Selects the trim cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Overlay points are trimmed by clicking and dragging and curve around
;	the desired points.  The left button trims standard overlays, the right 
;	trims user overlay points.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2006
;	
;-
;=============================================================================
pro grim_mode_trim_button_help_event, event
 text = ''
 nv_help, 'grim_mode_trim_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_trim_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Trim overlays'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_trim', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_trim_init
;
;=============================================================================
pro grim_mode_trim_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_trim
;
;=============================================================================
function grim_mode_trim, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_trim', $
		 event_pro:	'*grim_mode_trim_button_event', $
                 bitmap:	 grim_mode_trim_bitmap(), $
                 menu:		'Trim', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
