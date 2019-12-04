;=============================================================================
; grim_mode_magnify_bitmap
;
;=============================================================================
function grim_mode_magnify_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 241B],                   $
                [255B, 238B],                   $
                [127B, 223B],                   $
                [127B, 223B],                   $
                [127B, 223B],                   $
                [255B, 238B],                   $
                [127B, 241B],                   $
                [191B, 255B],                   $
                [223B, 255B],                   $
                [239B, 255B],                   $
                [247B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_magnify_cursor
;
;=============================================================================
pro grim_mode_magnify_cursor, swap=swap



 mask = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[1,1,1,1,1,0,0,0]], $
                      [[0,0,0,0,0,0,0,1] ,[1,0,0,0,1,1,0,0]], $
                      [[0,0,0,0,0,0,1,1] ,[0,0,0,0,0,1,1,0]], $
                      [[0,0,0,0,0,0,1,1] ,[0,0,0,0,0,1,1,0]], $
                      [[0,0,0,0,0,0,1,1] ,[0,0,0,0,0,1,1,0]], $
                      [[0,0,0,0,0,0,0,1] ,[1,0,0,0,1,1,0,0]], $
                      [[0,0,0,0,0,0,1,1] ,[1,1,1,1,1,0,0,0]], $
                      [[0,0,0,0,0,1,1,1] ,[0,1,1,1,0,0,0,0]], $
                      [[0,0,0,0,1,1,1,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,1,1,1,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,1,1,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,1,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 bitmap = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,1,1,1,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[1,0,0,0,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,1] ,[0,0,0,0,0,1,0,0]], $
                        [[0,0,0,0,0,0,0,1] ,[0,0,0,0,0,1,0,0]], $
                        [[0,0,0,0,0,0,0,1] ,[0,0,0,0,0,1,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[1,0,0,0,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,1] ,[0,1,1,1,0,0,0,0]], $
                        [[0,0,0,0,0,0,1,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,1,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,1,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,1,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [8,10]
;                                                            cursor_xy = [2,13]


end
;=============================================================================



;=============================================================================
; grim_mag_erase
;
;=============================================================================
pro grim_mag_erase, grim_data, wnum
@grim_constants.common

 size_device = MAG_SIZE_DEVICE
 half_size_device = size_device/2

; x0 = grim_data.mag_last[0] - half_size_device > 0
; y0 = grim_data.mag_last[1] - half_size_device > 0

 wset, wnum
; device, copy=[0,0, size_device,size_device, x0,y0, $
 device, copy=[0,0, size_device,size_device, $
                  grim_data.mag_last_x0,grim_data.mag_last_y0, $
                                                grim_data.mag_redraw_pixmap]

 grim_mode_magnify_cursor, swap=grim_get_cursor_swap(grim_data)
end
;=============================================================================



;=============================================================================
; grim_mag_frame
;
;=============================================================================
pro grim_mag_frame
@grim_constants.common

 size_device = MAG_SIZE_DEVICE

 plots, /device, [0,size_device-1,size_device-1,0,0], $
                 [0,0,size_device-1,size_device-1,0], color=ctgreen()


end
;=============================================================================



;=============================================================================
; grim_magnify
;
;=============================================================================
pro grim_magnify, grim_data, plane, p_device, data=data
@grim_constants.common

 size_data = MAG_SIZE_DATA
 half_size_data = fix(size_data/2)


 wnum = !d.window
 xmax = !d.x_size
 ymax = !d.y_size

 wset, grim_data.mag_pixmap
 size_device = MAG_SIZE_DEVICE
 half_size_device = fix(size_device/2)

 ;--------------------------------
 ; magnify current region
 ;--------------------------------
 x0 = p_device[0] - half_size_data
 y0 = p_device[1] - half_size_data

 x0 = x0 > 0 < (xmax - size_data)
 y0 = y0 > 0 < (ymax - size_data)

 pp = [x0 + half_size_data, y0 + half_size_data]

 ;- - - - - - - - - - - - - - - - - - - - -
 ; different behavior depending on mode
 ;- - - - - - - - - - - - - - - - - - - - -
 wset, wnum
 if(keyword_set(data)) then $
  begin
   dim = dat_dim(plane.dd)

   p_data = round(convert_coord(double(p_device[0]), double(p_device[1]), /device, /to_data))
   x0 = p_data[0] - half_size_data
   y0 = p_data[1] - half_size_data

   x0 = x0 > 0 < (dim[0]-1 - size_data - 1)
   y0 = y0 > 0 < (dim[1]-1 - size_data - 1)

   x1 = x0 + size_data - 1
   y1 = y0 + size_data - 1

   region = grim_scale_image(grim_data, $
        xrange=[x0,x1], yrange=[y0,y1], top=top, no_scale=no_scale, plane=plane)

region = region[*,*,0]	; need to be able to handle multi-channel image!!!

   if(grim_data.mag_last_x0 GE 0) then grim_mag_erase, grim_data, wnum

   mag_region = congrid(region, size_device, size_device)

   grim_wset, grim_data, wnum, get_info=tvd
   wset, grim_data.mag_pixmap

   erase 
   tvscl, mag_region, order=tvd.order, top=top
  end $
 else $
  begin
   if(grim_data.mag_last_x0 GE 0) then grim_mag_erase, grim_data, wnum
   region1 = congrid(tvrd(x0, y0, size_data, size_data, channel=1), size_device, size_device)
   region2 = congrid(tvrd(x0, y0, size_data, size_data, channel=2), size_device, size_device)
   region3 = congrid(tvrd(x0, y0, size_data, size_data, channel=3), size_device, size_device)

   grim_wset, grim_data, wnum, get_info=tvd
   wset, grim_data.mag_pixmap

   erase 
   tv, region1, channel=1
   tv, region2, channel=2
   tv, region3, channel=3
  end

 grim_mag_frame


 ;- - - - - - - - - - - - - - -
 ; save current region
 ;- - - - - - - - - - - - - - -
 x0 = pp[0] - half_size_device
 y0 = pp[1] - half_size_device

 x0 = x0 > 0 < (xmax - size_device)
 y0 = y0 > 0 < (ymax - size_device)
 wset, grim_data.mag_redraw_pixmap
 device, copy=[x0,y0, size_device,size_device, 0,0, wnum]


 ;- - - - - - - - - - - - - - -
 ; overlay magnified region
 ;- - - - - - - - - - - - - - -
 wset, wnum
 device, copy=[0,0, size_device,size_device, x0,y0, grim_data.mag_pixmap]

 grim_data.mag_last_x0 = x0
 grim_data.mag_last_y0 = y0
 grim_set_data, grim_data, grim_data.base

 grim_no_cursor
end
;=============================================================================



;=============================================================================
; grim_mode_magnify_mouse_event
;
;=============================================================================
pro grim_mode_magnify_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 ;----------------------------------
 ; button press
 ;----------------------------------
 if(event.type EQ 0) then data.pressed = event.press

 if(input_wnum NE grim_data.wnum) then return


 ;----------------------------------
 ; motion
 ;----------------------------------
 if(data.pressed NE 0) then $
  begin
   widget_control, grim_data.draw, draw_motion_events=1
   dat = (data.pressed EQ 4) ? 0 : 1

   grim_magnify, data=dat, grim_data, plane, [event.x, event.y]
  end


 ;----------------------------------
 ; button release
 ;----------------------------------
 if(event.type EQ 1) then $
  begin
   grim_set_tracking, grim_data
   data.pressed = 0

   if((event.release EQ 1) OR (event.release EQ 4)) then $
    begin
     grim_mag_erase, grim_data, !d.window
     grim_data.mag_last_x0 = -1
     grim_set_data, grim_data, grim_data.base
    end
  end


end
;=============================================================================


;=============================================================================
; grim_mode_magnify_mode
;
;=============================================================================
pro grim_mode_magnify_mode, grim_data, data_p

 grim_mode_magnify_cursor, swap=swap
 grim_print, grim_data, 'MAGNIFY -- L:Magnify Data R:Magnify Display'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_magnify_button_event
;
;
; PURPOSE:
;	Selects the magnify cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Image pixels in the graphics window may be magnifed using 
;	either the left or right mouse buttons.  The left button 
;	magnifies the displayed pixels, directly from the graphics 
;	window.  The right button magnifies the data itself, without 
;	the overlays.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_mode_magnify_button_help_event, event
 text = ''
 nv_help, 'grim_mode_magnify_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_magnify_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Magnifying glass'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_magnify', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_magnify_init
;
;=============================================================================
pro grim_mode_magnify_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_magnify
;
;=============================================================================
function grim_mode_magnify, arg
 
 data = {grim_mode_magnify_struct, pressed:0}

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_magnify', $
		 event_pro:	'*grim_mode_magnify_button_event', $
                 bitmap:	 grim_mode_magnify_bitmap(), $
                 menu:		'Magnify', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
