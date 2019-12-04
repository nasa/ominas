;=============================================================================
; grim_mode_mask_bitmap
;
;=============================================================================
function grim_mode_mask_bitmap

 return, [                               $
		[255B, 255B],			$
		[255B, 255B],			$
		[251B, 239B],			$
		[131B, 224B],			$
		[123B, 239B],			$
		[119B, 247B],			$
		[143B, 248B],			$
		[247B, 255B],			$
		[247B, 255B],			$
		[247B, 255B],			$
		[247B, 255B],			$
		[247B, 255B],			$
		[247B, 255B],			$
		[247B, 255B],			$
		[255B, 255B],			$
		[255B, 255B]			$
                ]

end
;=============================================================================



;=============================================================================
; grim_mode_mask_mouse_event
;
;=============================================================================
pro grim_mode_mask_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return


 grim_wset, grim_data, input_wnum
 p = convert_coord(double(event.x), double(event.y), /device, /to_data)
 grim_wset, grim_data, output_wnum


 if(event.press EQ 1) then $
  begin
   grim_add_mask, grim_data, p[0:1]
   grim_draw, grim_data, /mask, /nopoints
  end $
 else if(event.press EQ 4) then $
  begin
   grim_rm_mask, grim_data, p[0:1], pp=pp

   grim_refresh, grim_data, /use_pixmap
;   if(keyword_set(pp)) then $
;    begin
;     pp = convert_coord(pp[0,*], pp[1,*], /data, /to_device)
;      grim_display, grim_data, /use_pixmap, $
;	           pixmap_box_center=[pp[0],pp[1]], pixmap_box_side=30
;      grim_draw, grim_data, /mask, /nopoints
;      grim_refresh, grim_data, /use_pixmap
;     end
  end


end
;=============================================================================


;=============================================================================
; grim_mode_mask_mode
;
;=============================================================================
pro grim_mode_mask_mode, grim_data, data_p

 device, cursor_standard = 22
 grim_print, grim_data, 'MASK -- L:Add Pixels R:Remove Pixels'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_mask_button_event
;
;
; PURPOSE:
;	Selects the mask cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Allowqs the user to select pixel to include in the mask.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_mode_mask_button_help_event, event
 text = ''
 nv_help, 'grim_mode_mask_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_mask_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Mask pixels'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_mask', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_mask_init
;
;=============================================================================
pro grim_mode_mask_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_mask
;
;=============================================================================
function grim_mode_mask, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_mask', $
		 event_pro:	'*grim_mode_mask_button_event', $
                 bitmap:	 grim_mode_mask_bitmap(), $
                 menu:		'Mask', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
