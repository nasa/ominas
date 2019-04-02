;=============================================================================
; grim_mode_remove_bitmap
;
;=============================================================================
function grim_mode_remove_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [003B, 224B],                   $
                [003B, 192B],                   $
                [255B, 226B],                   $
                [255B, 225B],                   $
                [255B, 227B],                   $
                [255B, 227B],                   $
                [255B, 227B],                   $
                [255B, 227B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_remove_flash
;
;=============================================================================
pro grim_mode_remove_flash, p
common grim_flash_block, pixmap


 wnum = !d.window
 xs = !d.x_size
 ys = !d.y_size

 x = p[0]
 y = p[1]

 s = 32.
 s2 = s/2.
 if(NOT keyword_set(pixmap)) then $
  begin
   window, /free, /pixmap, xsize=s+2, ysize=s+2
   pixmap = !d.window
  end

 wset, pixmap
 device, copy=[x-s2,y-s2,s,s,0,0,wnum]
 wset, wnum

; plots, p-[5,0], psym=7, symsize=1., col=ctwhite(), /device, th=2

 plots, p-[1,0], psym=4, symsize=1.5, col=ctyellow(), /device, th=4
 plots, p-[5,0], psym=4, symsize=1.0, col=ctyellow(), /device, th=3
 plots, p-[9,0], psym=4, symsize=0.5, col=ctyellow(), /device, th=2

 plots, p-[1,0], psym=4, symsize=1.0, col=ctred(), /device, th=4
 plots, p-[5,0], psym=4, symsize=0.5, col=ctred(), /device, th=3

 plots, p-[5,0], psym=4, symsize=0.5, col=ctyellow(), /device, th=2

 wait, 0.01
 device, copy=[0,0,s,s,x-s2,y-s2,pixmap]

end
;=============================================================================



;=============================================================================
; grim_mode_remove_mouse_event
;
;=============================================================================
pro grim_mode_remove_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 0) then return
 if(event.press EQ 2) then return

 if(input_wnum NE grim_data.wnum) then return

 if(event.press EQ 1) then user = 0 $
 else if(event.press EQ 4) then user = 1

 if(defined(user)) then $
  begin
   grim_mode_remove_flash, [event.x, event.y]
   grim_remove_overlays, grim_data, plane, user=user, [event.x, event.y], $
                                                clicks=event.clicks, stat=stat
   if(stat NE -1) then grim_refresh, grim_data, /use_pixmap, /noglass
  end

end
;=============================================================================


;=============================================================================
; grim_mode_remove_cursor
;
;=============================================================================
pro grim_mode_remove_cursor, swap=swap



 mask = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,0,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,1,1,1,1,1,1,1] ,[1,1,1,1,1,1,1,0]], $
                      [[0,0,0,0,0,0,0,0] ,[1,1,1,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,1,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                      [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 bitmap = byte_to_bit([ [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,1,1,1,1,1,1] ,[1,1,1,1,1,0,0,0]], $
                        [[0,0,1,1,1,1,1,1] ,[1,1,1,1,1,1,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[1,0,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,1,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,1,1,1,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]], $
                        [[0,0,0,0,0,0,0,0] ,[0,0,0,0,0,0,0,0]] ] $
                    )

 device, cursor_mask=swap_endian(mask), cursor_image=swap_endian(bitmap), $
                                                            cursor_xy = [0,11]
;                                                            cursor_xy = [2,13]




end
;=============================================================================



;=============================================================================
; grim_mode_remove_mode
;
;=============================================================================
pro grim_mode_remove_mode, grim_data, data_p

 grim_mode_remove_cursor, swap=swap
 grim_print, grim_data, 'REMOVE OVERLAYS -- L:Standard R:User'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_remove_button_event
;
;
; PURPOSE:
;	Selects the remove cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	A single click on an overlay causes it to be deleted.  A
;       double click causes the entire object to be deleted.  The left
;	button applies to standard overlays; the right button applies 
;	to user overlays.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2006
;	
;-
;=============================================================================
pro grim_mode_remove_button_help_event, event
 text = ''
 nv_help, 'grim_mode_remove_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_remove_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Remove overlays/objects'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_remove', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_remove_init
;
;=============================================================================
pro grim_mode_remove_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_remove
;
;=============================================================================
function grim_mode_remove, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_remove', $
		 event_pro:	'*grim_mode_remove_button_event', $
                 bitmap:	 grim_mode_remove_bitmap(), $
                 menu:		'Remove', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
