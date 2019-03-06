;=============================================================================
; grim_mode_smooth_bitmap
;
;=============================================================================
function grim_mode_smooth_bitmap

 return, [                               $
                [255B, 255B],                   $
                [255B, 255B],                   $
                [003B, 192B],                   $
                [083B, 213B],                   $
                [171B, 202B],                   $
                [083B, 213B],                   $
                [171B, 202B],                   $
                [083B, 213B],                   $
                [171B, 202B],                   $
                [083B, 213B],                   $
                [171B, 202B],                   $
                [083B, 213B],                   $
                [171B, 202B],                   $
                [003B, 192B],                   $
                [255B, 255B],                   $
                [255B, 255B]                    $
                ]
 

end
;=============================================================================



;=============================================================================
; grim_smooth
;
;=============================================================================
pro grim_smooth, grim_data, plane=plane, box

 max = 30

 data = double(dat_data(plane.dd, abscissa=abscissa))
 size = size(data, /dim)

 if(grim_data.type EQ 'PLOT') then $
  begin
   xx = abscissa & xx = xx[sort(xx)]

   yy = data
   x0 = min(where(xx GE min(box[0,*])))
   x1 = max(where(xx LE max(box[0,*])))

   n = x1-x0
   if(n LT 1) then return

   result = 'Yes'
   if(n GE max) then $
       grim_message, /question, result=result, $
           ['The smoothing kernel is rather large.  Continue anyway?']
   if(result NE 'Yes') then return

   yy = smooth(yy, n)
   data = yy
  end $
 else $
  begin
   dx = max(box[0,*]) - min(box[0,*])
   dy = max(box[1,*]) - min(box[1,*])
   nx = fix(dx)
   ny = fix(dy)
   if((nx LT 1) OR (ny LT 1)) then return

   xmin = (ymin = 0)
   xmax = size[0]-1 & ymax = size[1]-1
   roi_ptd = grim_get_roi(grim_data, plane, /outline)
   roi = lindgen(size[0], size[1])

   if(keyword_set(roi_ptd)) then $
    begin
     roi_pts = round(pnt_points(roi_ptd))

     xmin = min(roi_pts[0,*])-nx > 0
     xmax = max(roi_pts[0,*])+nx < size[0]-1
     ymin = min(roi_pts[1,*])-ny > 0
     ymax = max(roi_pts[1,*])+ny < size[1]-1

     subsize = [xmax-xmin, ymax-ymin] + 1
     roi_pts_sub = roi_pts
     roi_pts_sub[0,*] = roi_pts_sub[0,*] - xmin
     roi_pts_sub[1,*] = roi_pts_sub[1,*] - ymin

     roi = polyfillv(roi_pts[0,*], roi_pts[1,*], size[0], size[1])
    end

   subimage = data[xmin:xmax, ymin:ymax]
   xy = w_to_xy(data, roi)
   xy[0,*] = xy[0,*] - xmin
   xy[1,*] = xy[1,*] - ymin
   roi_sub = xy_to_w(subimage, xy)

   kernel = dblarr(nx, ny)
   kernel[*] = 1d/(double(nx)*double(ny))

   n = max([nx,ny])
   result = 'Yes'
   if(n GE max) then $
       grim_message, /question, result=result, $
           ['The smoothing kernel is rather large.  Continue anyway?']
   if(result NE 'Yes') then return

   subimage = convol(subimage, kernel, /center)
   data[roi] = subimage[roi_sub]
  end

 dat_set_data, plane.dd, data
 
end
;=============================================================================



;=============================================================================
; grim_mode_smooth_mouse_event
;
;=============================================================================
pro grim_mode_smooth_mouse_event, event, data

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 if(struct NE 'WIDGET_DRAW') then return
 if(event.press EQ 2) then return

 if(input_wnum NE grim_data.wnum) then return

 if(event.press EQ 1) then $
     _box = tvrec(p0=[event.x, event.y], color=ctyellow(), aspect=1) $
 else if(event.press EQ 4) then $
     _box = tvrec(p0=[event.x, event.y], color=ctyellow()) $
 else return

 xx = _box[0,*] & yy = _box[1,*]
 box = convert_coord(/device, /to_data, double(xx), double(yy))
 widget_control, /hourglass
 grim_smooth, grim_data, plane=plane, box

end
;=============================================================================



;=============================================================================
; grim_mode_smooth_mode
;
;=============================================================================
pro grim_mode_smooth_mode, grim_data, data_p

 device, cursor_standard = 64
 grim_print, grim_data, 'SMOOTH -- L:Square Kernel R:Rectangular Kernel'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_mode_smooth_button_event
;
;
; PURPOSE:
;	Selects the smooth cursor mode.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	The user selects a box, which is used to determine the kernel
;	size for smoothing the data set.  If a ROI exists, only the data within
;	the ROI are smoothed.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2006
;	
;-
;=============================================================================
pro grim_mode_smooth_button_help_event, event
 text = ''
 nv_help, 'grim_mode_smooth_button_help_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_mode_smooth_button_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Smooth data'
   return
  end

 ;---------------------------------------------------------
 ; otherwise, change mode
 ;---------------------------------------------------------
 widget_control, event.id, get_uvalue=data
 grim_set_mode, grim_data, 'grim_mode_smooth', /new, data_p=data.data_p
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_mode_smooth_init
;
;=============================================================================
pro grim_mode_smooth_init, grim_data, data_p



end
;=============================================================================



;=============================================================================
; grim_mode_smooth
;
;=============================================================================
function grim_mode_smooth, arg
 
data = 0

 return, $
     {grim_user_mode_struct, $
		 name:		'grim_mode_smooth', $
		 event_pro:	'*+grim_mode_smooth_button_event', $
                 bitmap:	 grim_mode_smooth_bitmap(), $
                 menu:		'Smooth', $
                 data_p:	 nv_ptr_new(data) }

end
;=============================================================================
