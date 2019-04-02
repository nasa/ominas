;=============================================================================
; grim_mode_activate_bitmap
;
;=============================================================================
function grim_mode_activate_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [001B, 254B],                   $
                [063B, 252B],                   $
                [015B, 248B],                   $
                [063B, 240B],                   $
                [015B, 240B],                   $
                [063B, 224B],                   $
                [015B, 200B],                   $
                [127B, 132B],                   $
                [255B, 194B],                   $
                [255B, 229B],                   $
                [255B, 243B],                   $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_activate_mouse_event
;
;=============================================================================
pro grim_mode_activate_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)

 if(struct NE 'WIDGET_DRAW') then return
 if(input_wnum NE grim_data.wnum) then return
 if(event.press EQ 2) then return
 if(event.press EQ 0) then return

 if(event.press EQ 1) then $
     grim_activate_select, $
	 grim_data, plane, [event.x, event.y], clicks=event.clicks $
 else if(event.press EQ 4) then $
     grim_activate_select, $
	grim_data, plane, [event.x, event.y], /deactivate, clicks=event.clicks $
 else return

 grim_refresh, grim_data, /noglass, /no_image;, /update

end
;=============================================================================



;=============================================================================
; grim_mode_activate_mode
;
;=============================================================================
pro grim_mode_activate_mode, grim_data, data_p

 device, cursor_standard = 60
 grim_print, grim_data, 'ACTIVATE OVERLAYS -- L:Activate R:Deactivate'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_activate_button_event
;
;
; PURPOSE:
;	Selects the activate cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
; 	Overlay objects may be activated or deactivated by clicking 
;	and/or dragging using the left or right mouse buttons 
;	respectively.  This activation mechanism allows the user to 
;	select which among a certain type of objects should be used 
;	in a given menu selection.  A left click on an overlay
;	activates that overlay and a right click deactivates it.  A 
;	double click activates or deactivates all overlays associated 
;	with a given descriptor, or all stars.  Active overlays appear 
;	in the colors selected in the 'Overlay Settings' menu selection.  
;	Inactive overlays appear in gray.  A descriptor is active
;	whenever any of its overlays are active.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_mode_activate_button_help_event, event
 text = ''
 nv_help, 'grim_mode_activate_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_activate_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Activate/Deactivate overlays and objects'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_activate', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_activate_init
;
;=============================================================================
pro grim_mode_activate_init, grim_data, data_p


end
;=============================================================================



;=============================================================================
; grim_mode_activate
;
;=============================================================================
function grim_mode_activate, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_activate', $
		 event_pro:	'*grim_mode_activate_button_event', $
                 bitmap:	 grim_mode_activate_bitmap(), $
                 menu:		'Activate', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
