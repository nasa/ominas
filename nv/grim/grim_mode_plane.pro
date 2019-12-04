;=============================================================================
; grim_mode_plane_bitmap
;
;=============================================================================
function grim_mode_plane_bitmap

 return, [                               $
		[255B, 255B],			$
		[255B, 255B],			$
		[127B, 128B],			$
		[035B, 252B],			$
		[027B, 208B],			$
		[011B, 220B],			$
		[011B, 208B],			$
		[007B, 220B],			$
		[019B, 208B],			$
		[033B, 222B],			$
		[067B, 223B],			$
		[167B, 223B],			$
		[203B, 223B],			$
		[251B, 223B],			$
		[003B, 192B],			$
		[255B, 255B]			$
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_plane_mouse_event
;
;=============================================================================
pro grim_mode_plane_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 if(grim_data.n_planes EQ 1) then return

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 xy = convert_coord(double(event.x), double(event.y), /device, /to_data)
 grim_wset, grim_data, output_wnum

 if(event.press EQ 1) then $
  begin
   jplane = grim_get_plane_by_xy(grim_data, xy)
   use_pixmap = (noglass = 1)
  end $
 else if(event.press EQ 4) then $
   jplane = grim_get_plane_by_overlay(grim_data, xy) $
 else return

 if(NOT keyword_set(jplane)) then return

 grim_jump_to_plane, grim_data, jplane.pn
 grim_refresh, grim_data, use_pixmap=use_pixmap, noglass=noglass
end
;=============================================================================



;=============================================================================
; grim_mode_plane_mode
;
;=============================================================================
pro grim_mode_plane_mode, grim_data, data_p

 device, cursor_standard = 59
 grim_print, grim_data, $
          'SELECT PLANE -- L:By Data R:By Overlay'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_plane_button_event
;
;
; PURPOSE:
;	Selects the plane cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	Planes can be selected by clicking in the image window.  This option
;	is not useful unless planes other than the current plane are visible.
;	If more than one plane under the cursor contains data, the one with
;	the lowest plane number is selected, unless one of them is the current
;	plane.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2008
;	
;-
;=============================================================================
pro grim_mode_plane_button_help_event, event
 text = ''
 nv_help, 'grim_mode_plane_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_plane_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Change plane'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_plane', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_plane_init
;
;=============================================================================
pro grim_mode_plane_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_plane
;
;=============================================================================
function grim_mode_plane, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_plane', $
		 event_pro:	'*grim_mode_plane_button_event', $
                 bitmap:	 grim_mode_plane_bitmap(), $
                 menu:		'Plane', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
