;=============================================================================
; grim_mode_zoom_plot_bitmap
;
;=============================================================================
function grim_mode_zoom_plot_bitmap

 return, [                               $
                [255B, 255B],                   $
                [001B, 192B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 223B],                   $
                [253B, 159B],                   $
                [253B, 159B],                   $
                [253B, 159B],                   $
                [001B, 128B],                   $
                [255B, 131B],                   $
                [255B, 255B]                    $
                ]
 

end
;=============================================================================



;=============================================================================
; grim_mode_zoom_plot_mouse_event
;
;=============================================================================
pro grim_mode_zoom_plot_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(NOT keyword_set(event.press)) then return
 if(event.press EQ 2) then return

 tvgr, input_wnum, get_info=tvd
 box = tvrec(p0=[event.x, event.y], color=ctred())
 xx = box[0,*] & yy = box[1,*]
 pq = convert_coord(/device, /to_data, double(xx), double(yy))

 minbox = 5
 if(event.press EQ 1) then $
  begin
   xrange = [min(pq[0,*]), max(pq[0,*])]
   yrange = [min(pq[1,*]), max(pq[1,*])]
  end $
 else if(event.press EQ 4) then $
  begin
   box_xrange=[min(pq[0,*]), max(pq[0,*])]
   box_yrange=[min(pq[1,*]), max(pq[1,*])]

   imx = tvd.position[[0,2]]
   imy = tvd.position[[1,3]]
   corners = convert_coord(double(imx), double(imy), /norm, /to_data)
   old_xrange = corners[0,*] &  old_yrange = corners[1,*]	     

   xratio = (old_xrange[1]-old_xrange[0]) / $
        		       (box_xrange[1]-box_xrange[0])
   yratio = (old_yrange[1]-old_yrange[0]) / $
        		       (box_yrange[1]-box_yrange[0])

   xrange = [old_xrange - (box_xrange-old_xrange)*xratio]
   yrange = [old_yrange - (box_yrange-old_yrange)*yratio]

  end $
 else return 

 tvgr, output_wnum
 grim_refresh, grim_data, xrange=xrange, yrange=yrange


end
;=============================================================================



;=============================================================================
; grim_mode_zoom_plot_mode
;
;=============================================================================
pro grim_mode_zoom_plot_mode, grim_data, data_p

 device, cursor_standard = 144
 grim_print, grim_data, 'ZOOM -- L:Increase R:Decrease'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_zoom_plot_button_event
;
;
; PURPOSE:
;	Selects the zoom cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	The image zoom and offset are controlled by selecting
;	a box in the image.  When the box is created using the
;	left mouse button, zoom and offset are changed so that 
;	the contents of the box best fill the current graphics
;	window.  When the right button is used, the contents of
;	the current graphics window are shrunken so as to best
;	fill the box.  In other words, the left button zooms in
;	and the right button zooms out.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_mode_zoom_plot_button_help_event, event
 text = ''
 nv_help, 'grim_mode_zoom_plot_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_zoom_plot_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Zoom in/out'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_zoom_plot', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_zoom_plot_init
;
;=============================================================================
pro grim_mode_zoom_plot_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_zoom_plot
;
;=============================================================================
function grim_mode_zoom_plot, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_zoom_plot', $
		 event_pro:	'%grim_mode_zoom_plot_button_event', $
                 bitmap:	 grim_mode_zoom_plot_bitmap(), $
                 menu:		'Zoom', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
