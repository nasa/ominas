;=============================================================================
; grim_mode_target_bitmap
;
;=============================================================================
function grim_mode_target_bitmap

 return, [                               $
		[255B, 255B],			$
		[127B, 255B],			$
		[127B, 255B],			$
		[095B, 253B],			$
		[111B, 251B],			$
		[119B, 247B],			$
		[255B, 255B],			$
		[065B, 193B],			$
		[255B, 255B],			$
		[119B, 247B],			$
		[111B, 251B],			$
		[095B, 253B],			$
		[127B, 255B],			$
		[127B, 255B],			$
		[255B, 255B],			$
		[255B, 255B]			$
                ]


end
;=============================================================================



;=============================================================================
; grim_mode_target_cursor
;
;=============================================================================
pro grim_mode_target_cursor, swap=swap



 mask = byte_to_bit([ [[0,0,0,0,0,0,1,1] ,[1,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,1,0,1,1] ,[1,0,1,0,0,0,0,0]], $
                      [[0,0,0,1,1,0,1,1] ,[1,0,1,1,0,0,0,0]], $
                      [[0,0,1,1,1,0,1,1] ,[1,0,1,1,1,0,0,0]], $
                      [[0,1,1,1,0,0,1,1] ,[1,0,0,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,1] ,[0,0,0,0,0,0,0,0]], $
                      [[1,1,1,1,1,0,0,0] ,[0,0,1,1,1,1,1,0]], $
                      [[1,1,1,1,1,1,0,0] ,[0,1,1,1,1,1,1,0]], $
                      [[1,1,1,1,1,0,0,0] ,[0,0,1,1,1,1,1,0]], $
                      [[0,0,0,0,0,0,0,1] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,0,0,1,1] ,[1,0,0,1,1,1,0,0]], $
                      [[0,0,1,1,1,0,1,1] ,[1,0,1,1,1,0,0,0]], $
                      [[0,0,0,1,1,0,1,1] ,[1,0,1,1,0,0,0,0]], $
                      [[0,0,0,0,1,0,1,1] ,[1,0,1,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,1,1] ,[1,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 bitmap = byte_to_bit([ [[0,0,0,0,0,0,1,0] ,[1,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,1,1,1,0] ,[1,1,1,0,0,0,0,0]], $
                        [[0,0,0,1,0,1,1,0] ,[1,1,0,1,0,0,0,0]], $
                        [[0,0,1,0,1,0,1,0] ,[1,0,1,0,1,0,0,0]], $
                        [[0,1,0,1,0,0,1,0] ,[1,0,0,1,0,1,0,0]], $
                        [[0,1,1,0,0,0,0,1] ,[0,0,0,0,1,1,0,0]], $
                        [[1,1,1,1,1,0,0,0] ,[0,0,1,1,1,1,1,0]], $
                        [[0,0,0,0,0,1,0,0] ,[0,1,0,0,0,0,0,0]], $
                        [[1,1,1,1,1,0,0,0] ,[0,0,1,1,1,1,1,0]], $
                        [[0,1,1,0,0,0,0,1] ,[0,0,0,0,1,1,0,0]], $
                        [[0,1,0,1,0,0,1,0] ,[1,0,0,1,0,1,0,0]], $
                        [[0,0,1,0,1,0,1,0] ,[1,0,1,0,1,0,0,0]], $
                        [[0,0,0,1,0,0,1,0] ,[1,0,0,1,0,0,0,0]], $
                        [[0,0,0,0,1,1,1,0] ,[1,1,1,0,0,0,0,0]], $
                        [[0,0,0,0,0,1,1,0] ,[1,1,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [7,8]
;                                                            cursor_xy = [2,13]


end
;=============================================================================



;=============================================================================
; grim_mode_target_pointer
;
;=============================================================================
pro grim_mode_target_pointer, grim_data, plane, event
 cd = grim_xd(plane, /cd)
 p = (convert_coord(/device, /to_data, [event.x, event.y]))[0:1]
 pg_repoint, cd=cd, image_to_inertial(cd, p)
end
;=============================================================================



;=============================================================================
; grim_mode_target_body
;
;=============================================================================
pro grim_mode_target_body, grim_data, plane, event
 cd = grim_xd(plane, /cd)
 pp = (convert_coord(/device, /to_data, [event.x, event.y]))[0:1]
 xds = grim_get_body_by_point(grim_data, plane, pp)
 if(cor_name(xds[0]) EQ 'SKY') then return
 p = inertial_to_image_pos(cd, bod_pos(xds[0]))
 pg_repoint, cd=cd, image_to_inertial(cd, p)
end
;=============================================================================



;=============================================================================
; grim_mode_target_mouse_event
;
;=============================================================================
pro grim_mode_target_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 if(NOT keyword_set(grim_xd(plane, /cd))) then return



 if(event.press EQ 1) then grim_mode_target_pointer, grim_data, plane, event $
 else if(event.press EQ 4) then grim_mode_target_body, grim_data, plane, event


; need to update view...
end
;=============================================================================



;=============================================================================
; grim_mode_target_mode
;
;=============================================================================
pro grim_mode_target_mode, grim_data, data_p

 grim_mode_target_cursor, swap=swap
 grim_print, grim_data, $
      'Target CAMERA -- L:Target Cursor R:Target Body '

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_target_button_event
;
;
; PURPOSE:
;	Selects the target cursor mode.  
;
;	 Camera orientation: 
;	   Left button:		Repoints the optic axis at the cursor.
;
;	   Right button:	Repoints the optic axis at the center of the
;				nearest selected body.
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Repoints the camera at the cursor position or a selected body.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================
pro grim_mode_target_button_help_event, event
 text = ''
 nv_help, 'grim_mode_target_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_target_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Point Camera at Cursor or Body'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_target', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_target_init
;
;=============================================================================
pro grim_mode_target_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_target
;
;=============================================================================
function grim_mode_target, arg

 data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_target', $
		 event_pro:	'grim_mode_target_button_event', $
                 bitmap:	 grim_mode_target_bitmap(), $
                 menu:		'Target', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
