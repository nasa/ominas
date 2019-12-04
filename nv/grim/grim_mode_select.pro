;=============================================================================
; grim_mode_select_bitmap
;
;=============================================================================
function grim_mode_select_bitmap

 return, [                               $
		[255B, 255B],			$
		[255B, 239B],			$
		[255B, 231B],			$
		[255B, 227B],			$
		[255B, 225B],			$
		[255B, 242B],			$
		[127B, 253B],			$
		[191B, 254B],			$
		[095B, 255B],			$
		[175B, 255B],			$
		[215B, 255B],			$
		[235B, 255B],			$
		[245B, 255B],			$
		[249B, 255B],			$
		[255B, 255B],			$
		[255B, 255B]			$
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_select_mouse_event
;
;=============================================================================
pro grim_mode_select_mouse_event, event, data

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
              /autoclose, /silent, color=ctgreen(), $
              cancel_button=2, end_button=-1, select_button=1)
   grim_select_overlay_points, grim_data, plane=plane, region
  end $
 else if(event.press EQ 4) then $
  begin
   region = pg_select_region(0, $
              p0=[event.x,event.y], $
              /autoclose, /silent, color=ctred(), $
              cancel_button=2, end_button=-1, select_button=4)
   grim_select_overlay_points, grim_data, plane=plane, region, /deselect
  end $
 else return

 grim_refresh, grim_data, /use_pixmap
 grim_refresh, grim_data, /no_image

end
;=============================================================================


;=============================================================================
; grim_mode_select_cursor
;
;=============================================================================
pro grim_mode_select_cursor, swap=swap



 mask = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,1,1,0,0]], $
             	      [[0,0,0,0,0,0,0,0] ,[0,0,0,1,1,1,0,0]], $
             	      [[0,0,0,0,0,0,0,0] ,[0,0,1,1,1,1,0,0]], $
             	      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,1,0,0]], $
             	      [[0,0,0,0,0,0,0,0] ,[1,1,1,1,1,1,0,0]], $
             	      [[0,0,0,0,0,0,0,1] ,[1,1,1,1,1,1,0,0]], $
             	      [[0,0,0,0,0,0,1,1] ,[1,1,1,1,1,0,0,0]], $
             	      [[0,0,0,0,0,1,1,1] ,[1,1,0,0,0,0,0,0]], $
             	      [[0,0,0,0,1,1,1,1] ,[1,0,0,0,0,0,0,0]], $
             	      [[0,0,0,1,1,1,1,1] ,[0,0,0,0,0,0,0,0]], $
             	      [[0,0,1,1,1,1,1,0] ,[0,0,0,0,0,0,0,0]], $
             	      [[0,1,1,1,1,1,0,0] ,[0,0,0,0,0,0,0,0]], $
             	      [[1,1,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
             	      [[1,1,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
             	      [[1,1,1,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 bitmap = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[1,0,1,1,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,1] ,[0,1,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,1,0] ,[1,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,1,0,1] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,1,0,1,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,1,0,1,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,0,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,1,0,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,1,1,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )


 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [14,15]


end
;=============================================================================



;=============================================================================
; grim_mode_select_mode
;
;=============================================================================
pro grim_mode_select_mode, grim_data, data_p

 grim_mode_select_cursor, swap=swap
 grim_print, grim_data, $
       'SELECT WITHIN OVERLAYS -- L:Select M:Cancel R:Deselect'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_select_button_event
;
;
; PURPOSE:
;	Selects the 'select' cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Overlay points are selected by clicking and dragging and curve around
;	the desired points.  The left button selects overlay points, the right 
;	deselects overlay points.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2014
;	
;-
;=============================================================================
pro grim_mode_select_button_help_event, event
 text = ''
 nv_help, 'grim_mode_select_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_select_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Select overlay points'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_select', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_select_init
;
;=============================================================================
pro grim_mode_select_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_select
;
;=============================================================================
function grim_mode_select, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_select', $
		 event_pro:	'*grim_mode_select_button_event', $
                 bitmap:	 grim_mode_select_bitmap(), $
                 menu:		'Select', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
