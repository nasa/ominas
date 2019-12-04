;=============================================================================
; grim_mode_region_bitmap
;
;=============================================================================
function grim_mode_region_bitmap

 return, [                               $
                [255B, 255B],                   $
                [031B, 248B],                   $
                [231B, 231B],                   $
                [251B, 223B],                   $
                [253B, 223B],                   $
                [253B, 191B],                   $
                [253B, 191B],                   $
                [251B, 191B],                   $
                [251B, 191B],                   $
                [199B, 223B],                   $
                [063B, 224B],                   $
                [255B, 249B],                   $
                [255B, 253B],                   $
                [127B, 254B],                   $
                [159B, 255B],                   $
                [255B, 255B]                    $
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_region_mouse_event
;
;=============================================================================
pro grim_mode_region_mouse_event, event, data

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
   roi = pg_select_region(/box, 0, $
  	      p0=[event.x,event.y], $
  	      /silent, color=ctblue(), image_pts=p)
  end $
 else if(event.press EQ 4) then $
  begin
   roi = pg_select_region(0, $
  	      p0=[event.x,event.y], $
  	      /autoclose, /silent, color=ctblue(), $
  	      cancel_button=2, end_button=-1, select_button=4, $
  	      image_pts=p)
  end $
 else return

 if(n_elements(roi) GT 1) then $
  begin
   xx = p[0,*] & yy = p[1,*]
   pp = convert_coord(/device, /to_data, double(xx), double(yy))
   grim_set_roi, grim_data, roi, pp[0:1,*]
  end

 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
; grim_mode_region_mode
;
;=============================================================================
pro grim_mode_region_mode, grim_data, data_p

 device, cursor_standard = 32
 grim_print, grim_data, 'DEFINE REGION -- L:Rectangular R:Irregular'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_region_button_event
;
;
; PURPOSE:
;	Selects the 'region' cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	An image region is defined by clicking and dragging a box or curve.  
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2014
;	
;-
;=============================================================================
pro grim_mode_region_button_help_event, event
 text = ''
 nv_help, 'grim_mode_region_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_region_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Define region'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_region', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_region_init
;
;=============================================================================
pro grim_mode_region_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_region
;
;=============================================================================
function grim_mode_region, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_region', $
		 event_pro:	'+*grim_mode_region_button_event', $
                 bitmap:	 grim_mode_region_bitmap(), $
                 menu:		'Region', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
