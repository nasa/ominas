;=============================================================================
;+
; NAME:
;       tvpan
;
;
; PURPOSE:
;       Move a displayed image by an offset determined by the cursor; show
;	the image during the drag.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       tvpan, image, wnum, new=new, erase=erase
;
;
; ARGUMENTS:
;  INPUT:
;         image:        Image to display
;
;          wnum:        window number of display
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;	new:	If set, creates a new window
;
;	erase:	If set, erases display first
;
;	noplot:	If set, the image is not redisplayed.
;
;
;	p0:	First point.  If set, then the routine
;		immediately begins to drag from that point until a
;		button is released.
;
;	cursor:	Device code of cursor to use.  Default is a custom cursor.
;
;	hourglass_id:	If set, this is used as the widget id of a draw
;			window in which to set the hourglass cursor after
;			the line has been selected until the procedure 
;			is complete.	
;  OUTPUT:
;       NONE
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 9/7/05
;
;-
;=============================================================================



;=============================================================================
; tvpan_draw
;
;=============================================================================
pro tvpan_draw, data, xarr, yarr, pixmap, win_num
 
 wn = !d.window

 pm = data.pm
 edge = data.edge
;edge = [3,3,3,3]
 xor_graphics=data.xor_graphics

 dx = xarr[1] - xarr[0] + edge[0]
 dy = yarr[1] - yarr[0] + edge[2]


 wset, pm
 device, copy=[edge[0],edge[2], $
               !d.x_size-(edge[0]+edge[1]),!d.y_size-(edge[2]+edge[3]), dx,dy, pixmap]

 wset, wn
 device, copy=[edge[0],edge[2], $
             !d.x_size-(edge[0]+edge[1]),!d.y_size-(edge[2]+edge[3]), edge[0],edge[2], pm]

 if(keyword_set(data.callback)) then $
                call_procedure, data.callback, data.cb_data, xarr, yarr

end
;=============================================================================



;=============================================================================
; tvpan_erase
;
;=============================================================================
pro tvpan_erase, data, oldxarr, oldyarr, pixmap, win_num

 wn = !d.window
 wset, data.pm
 erase
 wset, wn

end
;=============================================================================



;=============================================================================
; tvpan
;
;=============================================================================
pro tvpan, image, wnum=wnum, new=new, erase=erase, p0=p0, cursor=cursor, $
                   hourglass_id=hourglass_id, noplot=noplot, $
                   output_wnum=output_wnum, color=color, edge=edge, $
                   notvim=notvim, doffset=doffset, pixmap=_pixmap, $
                   xor_graphics=xor_graphics, $
                   callback=callback, cb_data=cb_data, dxy=dxy

 xor_graphics = keyword_set(xor_graphics)
 if(NOT keyword_set(gr)) then gr = 3
 if(n_elements(edge) EQ 1) then edge = make_array(4, val=edge) $
 else if(NOT keyword_set(edge)) then edge = lonarr(4)
 if(n_elements(wnum) NE 0) then wset, wnum
 if(NOT keyword_set(callback)) then callback = ''
 if(NOT keyword_set(callback_data)) then callback_data = ''

 ;-------------------------------
 ; setup pixmap
 ;-------------------------------
 wn = !d.window
 window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
 pixmap = !d.window
 wset, wn

 ;-------------------------------
 ; get offset by dragging image
 ;-------------------------------
 if(keyword_set(cursor)) then tvcursor, /set, cursor=cursor
 if(xor_graphics) then device, set_graphics=6 
 ln = tvline(wnum, /restore, p0=p0, color=color, /nodraw, pixmap=_pixmap, $
               fn_draw='tvpan_draw', fn_erase='tvpan_erase', $
                      fn_data={pm:pixmap, edge:edge, xor_graphics:xor_graphics, $
                               callback:callback, cb_data:cb_data})
 if(xor_graphics) then device, set_graphics=3 
 if(keyword_set(cursor)) then tvcursor, /restore
 if(keyword_set(hourglass_id)) then widget_control, hourglass_id, /hourglass

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 line = convert_coord(double(ln[0,*]), double(ln[1,*]), /device, /to_data)
 dx = line[0,0]-line[0,1]
 dy = line[1,0]-line[1,1]

 ;---------------------------------
 ; derive tvim parameters
 ;---------------------------------
 dxy = [dx,dy]

 ;---------------------------------
 ; display moved image
 ;---------------------------------
 if(keyword_set(output_wnum)) then wset, output_wnum
 if(NOT keyword_set(notvim)) then $
  if((dxy[0] NE 0) OR (dxy[1] NE 0)) then $
    tvim, image, /silent, doffset=dxy, /inherit, new=new, erase=erase, noplot=noplot, $
                                                   xsize=!d.x_size, ysize=!d.y_size

 wdelete, pixmap
end
;=====================================================================================
