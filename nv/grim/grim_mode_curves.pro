;=============================================================================
; grim_mode_curves_bitmap
;
;=============================================================================
function grim_mode_curves_bitmap

 return, [                               $
                [255B, 255B],                   $
                [249B, 207B],                   $
                [241B, 199B],                   $
                [227B, 227B],                   $
                [199B, 241B],                   $
                [015B, 248B],                   $
                [223B, 253B],                   $
                [001B, 253B],                   $
                [223B, 253B],                   $
                [015B, 248B],                   $
                [199B, 241B],                   $
                [227B, 227B],                   $
                [241B, 199B],                   $
                [249B, 207B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_curves_mouse_event
;
;=============================================================================
pro grim_mode_curves_mouse_event, event, data

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
   p = pg_select_region(0, /points, /data, $
		p0=[event.x,event.y], $
		/autoclose, /noclose, /silent, color=ctgreen(), $
		cancel_button=2, select_button=1)
   if(n_elements(p) GT 1) then $
    begin
     grim_add_curve, grim_data, p
     grim_draw, grim_data, /curves, /nopoints
    end $
   else grim_refresh, grim_data, /use_pixmap
  end $
 else if(event.press EQ 4) then $
  begin
   grim_wset, grim_data, input_wnum
   p = convert_coord(double(event.x), double(event.y), /device, /to_data)
   grim_wset, grim_data, output_wnum
   grim_rm_curve, grim_data, p[0:1], flabel=flabel
   if(keyword_set(flabel)) then grim_refresh, grim_data, /use_pixmap
  end


end
;=============================================================================


;=============================================================================
; grim_mode_curves_cursor
;
;=============================================================================
pro grim_mode_curves_cursor, swap=swap



   mask = byte_to_bit([ [[1,1,0,0,0,0,0,0] ,[0,0,0,0,0,1,1,0]], $
                        [[1,1,1,0,0,0,0,0] ,[0,0,0,0,1,1,1,0]], $
                        [[0,1,1,1,0,0,0,0] ,[0,0,0,1,1,1,0,0]], $
                        [[0,0,1,1,1,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,0,0,1,1,1,0,0] ,[0,1,1,1,0,0,0,0]], $
                        [[0,0,0,0,1,1,0,0] ,[0,1,1,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,1] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,1,1,0,0] ,[0,1,1,0,0,0,0,0]], $
                        [[0,0,0,1,1,1,0,0] ,[0,1,1,1,0,0,0,0]], $
                        [[0,0,1,1,1,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,1,1,1,0,0,0,0] ,[0,0,0,1,1,1,0,0]], $
                        [[1,1,1,0,0,0,0,0] ,[0,0,0,0,1,1,1,0]], $
                        [[1,1,0,0,0,0,0,0] ,[0,0,0,0,0,1,1,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ])

   bitmap = byte_to_bit([ [[0,1,0,0,0,0,0,0] ,[0,0,0,0,0,1,0,0]], $
                          [[1,0,1,0,0,0,0,0] ,[0,0,0,0,1,0,1,0]], $
                          [[0,1,0,1,0,0,0,0] ,[0,0,0,1,0,1,0,0]], $
                          [[0,0,1,0,1,0,0,0] ,[0,0,1,0,1,0,0,0]], $
                          [[0,0,0,1,0,1,0,0] ,[0,1,0,1,0,0,0,0]], $
                          [[0,0,0,0,1,1,0,0] ,[0,1,1,0,0,0,0,0]], $
                          [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                          [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                          [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                          [[0,0,0,0,1,1,0,0] ,[0,1,1,0,0,0,0,0]], $
                          [[0,0,0,1,0,1,0,0] ,[0,1,0,1,0,0,0,0]], $
                          [[0,0,1,0,1,0,0,0] ,[0,0,1,0,1,0,0,0]], $
                          [[0,1,0,1,0,0,0,0] ,[0,0,0,1,0,1,0,0]], $
                          [[1,0,1,0,0,0,0,0] ,[0,0,0,0,1,0,1,0]], $
                          [[0,1,0,0,0,0,0,0] ,[0,0,0,0,0,1,0,0]], $
                          [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ])




 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [7,8]
;                                                            cursor_xy = [2,13]



end
;=============================================================================



;=============================================================================
; grim_mode_curves_mode
;
;=============================================================================
pro grim_mode_curves_mode, grim_data, data_p

 grim_mode_curves_cursor, swap=swap
 grim_print, grim_data, 'CURVE -- L:Add M:Cancel R:Remove'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_curves_button_event
;
;
; PURPOSE:
;	Selects the curves cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	curves are added using the left mouse button and deleted 
;	using the right button.  
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;=============================================================================
pro grim_mode_curves_button_help_event, event
 text = ''
 nv_help, 'grim_mode_curves_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_curves_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Add/Delete curves'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_curves', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_curves_init
;
;=============================================================================
pro grim_mode_curves_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_curves
;
;=============================================================================
function grim_mode_curves, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_curves', $
		 event_pro:	'+*grim_mode_curves_button_event', $
                 bitmap:	 grim_mode_curves_bitmap(), $
                 menu:		'Curves', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
