;=============================================================================
; grim_mode_notes_bitmap
;
;=============================================================================
function _grim_mode_notes_bitmap

 return, [                               $
		[255B, 255B],			$
		[255B, 239B],			$
		[255B, 199B],			$
		[255B, 131B],			$
		[255B, 205B],			$
		[255B, 238B],			$
		[127B, 247B],			$
		[191B, 251B],			$
		[223B, 253B],			$
		[239B, 254B],			$
		[119B, 255B],			$
		[187B, 255B],			$
		[217B, 255B],			$
		[225B, 255B],			$
		[241B, 255B],			$
		[255B, 255B]			$
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_notes_bitmap
;
;=============================================================================
function grim_mode_notes_bitmap

 return, [                               $
		[255B, 255B],			$
		[255B, 255B],			$
		[095B, 245B],			$
		[015B, 240B],			$
		[239B, 247B],			$
		[047B, 245B],			$
		[239B, 247B],			$
		[175B, 244B],			$
		[239B, 247B],			$
		[175B, 246B],			$
		[239B, 247B],			$
		[047B, 244B],			$
		[239B, 247B],			$
		[015B, 240B],			$
		[255B, 255B],			$
		[255B, 255B]			$
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_notes_mouse_event
;
;=============================================================================
pro grim_mode_notes_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)

 if(struct NE 'WIDGET_DRAW') then return
 if(input_wnum NE grim_data.wnum) then return
 if(event.press EQ 2) then return
 if(event.press EQ 0) then return



 p = convert_coord(event.x, event.y, /device, /to_data)
 ptd = grim_nearest_overlay(plane, p, grim_ptd(plane))

 if(event.press EQ 4) then $
  begin
   if(NOT keyword_set(ptd)) then xd = grim_xd(plane, /cd) $
   else xd = pnt_assoc_xd(ptd)
  end
 if(event.press EQ 1) then $
  begin
   if(NOT keyword_set(ptd)) then return
   xd = ptd
  end
 if(NOT keyword_set(xd)) then return

 base = cor_udata(xd, 'GRIM_NOTES_BASE')
 text = grim_edit_notes(xd, base=base)
 cor_set_udata, xd, 'GRIM_NOTES_BASE', base
 if(keyword_set(text)) then cor_set_udata, xd, 'GRIM_NOTES_TEXT', text


end
;=============================================================================



;=============================================================================
; grim_mode_notes_mode
;
;=============================================================================
pro grim_mode_notes_mode, grim_data, data_p

 device, cursor_standard = 85
 grim_print, grim_data, 'NOTES -- L:Overlay R:Geometry Object'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_notes_button_event
;
;
; PURPOSE:
;	Selects the notes cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	CORE notes may be edited for either overlays or their associated
;	geometry descriptors using the left and right mouse buttons
;	respectively.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2018
;	
;-
;=============================================================================
pro grim_mode_notes_button_help_event, event
 text = ''
 nv_help, 'grim_mode_notes_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_notes_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Edit object notes'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_notes', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_notes_init
;
;=============================================================================
pro grim_mode_notes_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_notes
;
;=============================================================================
function grim_mode_notes, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_notes', $
		 event_pro:	'*grim_mode_notes_button_event', $
                 bitmap:	 grim_mode_notes_bitmap(), $
                 menu:		'Notes', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
