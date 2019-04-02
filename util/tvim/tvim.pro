;=============================================================================
;+
; NAME:
;       tvim
;
;
; PURPOSE:
;       Displays an image in an IDL window, sets display properties
;       (zoom, offset and order) and maintains a data coordinate system for
;       the window.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       tvim, arg1 <, arg2>
;
;
; ARGUMENTS:
;  INPUT:
;           arg1:     Can be window number if argument has 1 dimension, or
;                     an image if argument has 2 dimensions.  If it's an image,
;                     then that image is displayed.  If it's a window number,
;                     then that window becomes the current window.
;
;           arg2:     Same as above, either window number or image.
;                     If no args are given, tvim prints the current window
;                     number.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;         silent:     If set, supresses output of messages.
;
;            new:     If set, creates a new window.
;
;        inherit:     If set, window will inherit the settings of the
;                     current tvim window.
;
;          xsize:     Set the x size of the window to this amount.
;
;          ysize:     Set the y size of the window to this amount.
;
;            all:     If set, print all display properties (not implemented)
;
;        default:     If set, use default properties (zoom=[1,1], offset=[0,0]
;                     order=0 [bottom-up])
;
;         entire:     If set, zoom and offset are set such that the entire 
;                     image is visible in the current window.
;
;       previous:     If set, restore last-used properties.
;
;        restore:     If set, use saved properties.
;
;           home:     If set, set the offset to [0,0].
;
;        channel:     Display plane (1, 2, or 3) to display image in.
;
;        doffset:     Change the offset property by this amount.
;
;           save:     Save the current properties.
;
;           zoom:     2-element array giving the zoom in each direction.
;
;          order:     If set, y coordinate display order is top-down.
;
;          rotate:    If set, coordinates are transformed as in the idl 
;                     'rotate' command.
;
;           flip:     If set, reverse display order.
;
;         offset:     Set the corner of image for display to this value.
;
;  local_scaling:     If set, pixel values are scaled based only on the 
;		      pixel visible with the current tvim settings.
;
;	no_scale:     If set, pixel values are not altered.
;
;            top:     Set the top stretch value to this value.  If not given,
;		      tvim, attempts to use the system variable !ct_top, which
;		      is set by ctmod.
;
;          erase:     If set, erase the display window before displaying image.
;
;         noplot:     If set, do all the calculations but do not display the
;                     image.
;
;         pixmap:     If set and if this is a new window, the window will 
;                     be a pixmap.
;
;    draw_pixmap:     If set, the image will be written to this pixmap
;                     and then copied to the main window.  If /no_copy,
;                     then the image will not be copied to the main window.
;
;        no_copy:     See the " draw_pixmap" keyword.
;
;         retain:     "Retain" value to be passed to the IDL routine
;                     widget_draw.
;
;          title:     Title text for the window frame.
;
;           bufz:     If set, the z-buffer is used.
;
;    force_xsize:     If set, the window is forced to this x-size.
;
;    force_ysize:     If set, the window is forced to this y-size.
;
;          nowin:     If set, then no window is opened.
;
;           list:     If set, the "wnum" keyword will return a list
;                     valid tvim window numbers.
;
;        no_wset:     If set, the window number is not changed.
;
;       no_coord:     If set, the coordinate system is not changed.
;
;
;
;  OUTPUT:
;       wnum:		Window number of current tvim instance.
;
;	get_info:	Returns the tvim data structure for the current
;			window, see tvim_data__define below.
;
;        tvimage:     The scaled image is returned by this keyword.
;
;            min:      Minimum data value in each image plane.
;
;            max:      Maximum data value in each image plane.
;
;
; COMMON BLOCKS:
;      tvim_block:     tvd, tvim_top
;
;
; SEE ALSO:
;       tvzoom, tvmove
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================


;===========================================================================
; tvim_zoom_valid
;
;===========================================================================
function tvim_zoom_valid, zoom
 return, keyword_set(zoom[0]) AND keyword_set(zoom[1])
end
;===========================================================================


;===========================================================================
; tvim_data__define
;
;
;===========================================================================
pro tvim_data__define

 s={tvim_data, $
		wnum:		0, $
		zoom:		dblarr(2), $
		offset:		dblarr(2), $
		order:		byte(0), $
		rotate:		byte(0), $
		force_xsize:	0l, $
		force_ysize:	0l, $
		zoom_save:	dblarr(2), $
		offset_save:	dblarr(2), $
		order_save:	byte(0), $
		rotate_save:	byte(0), $
		zoom_prev:	dblarr(2), $
		offset_prev:	dblarr(2), $
		order_prev:	byte(0), $
		rotate_prev:	byte(0), $
		prev:		byte(0) $
	}

end
;===========================================================================


;=============================================================================
; NAME:
;       tvim_get_index
;
;
; PURPOSE:
;       Returns index into the tvd structure for the specified window.
;       Will also add to the tvd structure if /create specified.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       result = tvim_get_index(wnum, create=create)
;
; ARGUMENTS:
;  INPUT:
;           wnum:     IDL window number
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;         create:     If set, will create a new display window
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Index of tvd structure for given window number.
;
; COMMON BLOCKS:
;      tvim_block:     tvd, tvim_top
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;=============================================================================
function tvim_get_index, wnum, create=create
common tvim_block, tvd, tvim_top

 i=(where(tvd.wnum EQ wnum))[0]
 if(i EQ -1) then $ 
  if(keyword__set(create)) then $
   begin
    tvd=[tvd,{tvim_data}]
    i=n_elements(tvd)-1
    tvd[i].wnum=wnum
   end

 return, i
end
;===========================================================================



;=============================================================================
; NAME:
;       tvim_set
;
;
; PURPOSE:
;       Sets various display parameters.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       tvim_set, current=current, $
;                 zoom=zoom, $
;                 order=order, $
;                 rotate=rotate, $
;                 offset=offset
;
; ARGUMENTS:
;  INPUT:
;           zoom:     zoom factor in each direction
;
;         offset:     x and y pixel offset of corner
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;        current:     Use current saved values for parameters
;
;          order:     If set, y direction displays from top down
;
;  OUTPUT:
;       NONE
;
;
; COMMON BLOCKS:
;      tvim_block:     tvd, tvim_top
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;=============================================================================
pro tvim_set, current=current, $
	zoom=_zoom, $
	order=order, $
	rotate=rotate, $
	offset=_offset, $
	force_xsize=force_xsize, force_ysize=force_ysize, $
	integer_zoom=integer_zoom, $
	xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, no_coord=no_coord
common tvim_block, tvd, tvim_top

 if(keyword_set(_offset)) then offset = double(_offset)
 if(keyword_set(_zoom)) then zoom = double(_zoom)


 i = tvim_get_index(!d.window, /create)

 set_previous=1

 if(keyword_set(current)) then $
  begin
   set_previous = 0
   zoom = tvd[i].zoom
   order = tvd[i].order
   rotate = tvd[i].rotate
   offset = tvd[i].offset
   force_xsize = tvd[i].force_xsize
   force_ysize = tvd[i].force_ysize
  end

 xsize = !d.x_size
 ysize = !d.y_size
 if(keyword_set(force_xsize)) then xsize = force_xsize 
 if(keyword_set(force_ysize)) then ysize = force_ysize

 ;-------------------------
 ; compute window params
 ;-------------------------

 ;- - - - - - - - - - - - -
 ; integer zoom
 ;- - - - - - - - - - - - -
 if(keyword_set(integer_zoom)) then $
  begin
   new_zoom = zoom

   w = where((zoom GT 0.5) AND (zoom LT 1))
   if(w[0] NE -1) then new_zoom[w] = 0.5

   w = where(zoom GT 1)
   if(w[0] NE -1) then new_zoom[w] = double(round(zoom[w]))

   w = where(zoom LT 1)
   if(w[0] NE -1) then new_zoom[w] = 1/double(ceil(1/zoom[w]))

   center = [xsize, ysize] + 0.5
   new_center = center*new_zoom/zoom
   offset = offset - (center - new_center)

   zoom = new_zoom
  end

 ;- - - - - - - - - - - - -
 ; offset, zoom
 ;- - - - - - - - - - - - -
;;; x0 = offset[0] + 0.5
;;; x1 = offset[0] + xsize/zoom[0] - 0.5

;;; y0 = offset[1] + 0.5
;;; y1 = offset[1] + ysize/zoom[1] - 0.5

 x0 = offset[0] - 0.5
 x1 = offset[0] + xsize/zoom[0] - 0.5

 y0 = offset[1] - 0.5
 y1 = offset[1] + ysize/zoom[1] - 0.5

 xmin = double(offset[0])
 xmax = double(x1) + 1l
 ymin = double(offset[1])
 ymax = double(y1) + 1l

 ;- - - - - - - - - - - - -
 ; order
 ;- - - - - - - - - - - - -
 if(keyword_set(order)) then swap, y0, y1

 ;- - - - - - - - - - - - -
 ; rotate -- not working
 ;- - - - - - - - - - - - -
 if(keyword_set(___rotate)) then $
  begin
   xx = [x0,x1]
   yy = [y0,y1]

   case rotate of
    1 : begin
	end
    2 : begin
	 x0 = xsize - xx[0]
	 x1 = xsize - xx[1]
	 y0 = ysize - yy[0]
	 y1 = ysize - yy[1]
	end
    3 : begin
	end
    4 : begin
	end
    5 : begin
	 x0 = xx[1]
	 x1 = xx[0]
	end
    6 : begin
	end
    7 : begin
	 y0 = yy[1]
	 y1 = yy[0]
	end
    else :
   endcase  
  end

 ;-------------------------
 ; set window params
 ;-------------------------
 xystyle = 5
 plot = 1

 w = where(finite([x0,x1,y0,y1]) EQ 0)
 if(w[0] NE -1) then plot = 0

 if(plot) then $
  if(NOT keyword_set(no_coord)) then $
    plot, /data, /nodata, pos=[0,0,1,1], /noerase, [0], $
		xstyle=xystyle, xrange=[x0,x1], yrange=[y0,y1], ystyle=xystyle


 ;-------------------------
 ; save window params
 ;-------------------------
 tvd[i].wnum = !d.window

 if((zoom[0] EQ tvd[i].zoom[0]) $
     AND (zoom[1] EQ tvd[i].zoom[1]) $
     AND (order EQ tvd[i].order) $
     AND (rotate EQ tvd[i].rotate) $
     AND (offset[0] EQ tvd[i].offset[0]) $
     AND (offset[1] EQ tvd[i].offset[1])) then set_previous = 0

 if(set_previous) then $
  begin
   tvd[i].zoom_prev = tvd[i].zoom
   tvd[i].order_prev = tvd[i].order
   tvd[i].rotate_prev = tvd[i].rotate
   tvd[i].offset_prev = tvd[i].offset
   tvd[i].prev = 1
  end

 tvd[i].zoom = zoom
 tvd[i].order = order
 tvd[i].rotate = rotate
 tvd[i].offset = offset
 tvd[i].force_xsize = force_xsize
 tvd[i].force_ysize = force_ysize

end
;===========================================================================


;=============================================================================
; NAME:
;       tvim_set_num
;
;
; PURPOSE:
;       Sets the IDL window number for the current display.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       tvim_set_num, wnum
;
; ARGUMENTS:
;  INPUT:
;           wnum:     IDL window number
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;       NONE
;
;  OUTPUT:
;       NONE
;
;
; COMMON BLOCKS:
;      tvim_block:     tvd, tvim_top
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;=============================================================================
pro tvim_set_num, wnum, no_wset=no_wset, no_coord=no_coord
common tvim_block, tvd, tvim_top

 if(NOT keyword_set(no_wset)) then wset, wnum

 i=tvim_get_index(wnum)
 if(i NE -1) then if(NOT keyword_set(no_coord)) then tvim_set, /current

end
;===========================================================================



;===========================================================================
; tvim
;
;===========================================================================
pro tvim, arg1, arg2, draw_pixmap=draw_pixmap, $
	tvimage=tvimage, retain=retain, title=title, $
	silent=silent, new=new, inherit=inherit, xsize=wxsize, ysize=wysize, $
	all=all, default=default, previous=previous, restore=restore, $
	channel=channel, entire=entire, $
	doffset=doffset, home=home, $
	save=save, min=min, max=max, no_copy=no_copy, $
	zoom=__zoom, bufz=bufz, $
	order=_order, rotate=_rotate, $
	flip=flip, force_xsize=force_xsize, force_ysize=force_ysize, $
	offset=_offset, base=base, $
	local_scaling=_local_scaling, no_scale=no_scale, $
	get_info=get_info, nowin=nowin, $
	top=top, erase=erase, noplot=noplot, integer_zoom=integer_zoom, $
	wnum=_wnum, list=list, pixmap=pixmap, no_wset=no_wset, no_coord=no_coord
common tvim_block, tvd, tvim_top

 if(NOT keyword_set(top)) then $
  begin
   defsysv, 'ct_top', exists=test
   if(test) then tvim_top = !ct_top
  end


 if(keyword__set(__zoom)) then $
  begin
   if(n_elements(__zoom) EQ 1) then _zoom = [__zoom, __zoom] $
   else _zoom = __zoom
  end

 if(keyword__set(_offset)) then _offset = double(_offset)
 if(keyword__set(doffset)) then doffset = double(doffset)

 if(keyword__set(list) AND keyword__set(tvd)) then $
  begin
   _wnum = tvd.wnum
   w = where(_wnum GT 0)
   if(w[0] NE -1) then _wnum = _wnum[w]
   return
  end


 if(n_elements(offset) NE 0 AND n_elements(offset) NE 2) then $
                      message, 'Offset must have the form [xoffset, yoffset].'



 if(NOT keyword_set(tvd)) then tvd={tvim_data}
; on_error, 1
 
; tvim_set_num, !d.window, no_wset=no_wset, no_coord=no_coord

 if(keyword_set(top)) then tvim_top = top


 ;===============================================================
 ; wnum is the scalar arg, image is the 2-d arg.
 ;===============================================================
 if(n_elements(arg1) NE 0) then $
  begin
   s = size(arg1)
   if(s[0] EQ 0) then wnum=arg1 $
   else image=arg1

   if(n_elements(arg2) NE 0) then $
    begin
     s = size(arg2)
     if(s[0] EQ 0) then wnum=arg2 $
     else image=arg2
    end
  end


 ;==============================================
 ; if z-buffer, then transform image
 ;==============================================
 if(keyword_set(bufz)) then $
  begin
   if(keyword_set(order)) then image = rotate(image, 7)

;   image = shift(image, 0,1)
;   image = shift(rotate(image, 7), 0, 1)
   nowin = 1
  end


 ;========================================
 ; if wnum is given, then set the window
 ;========================================
 if(n_elements(wnum) NE 0) then $
           tvim_set_num, wnum, no_wset=no_wset, no_coord=no_coord


 ;================================================================
 ; if /save, then just save the current params and return
 ;================================================================
 if(keyword__set(save)) then $
  begin
   i = tvim_get_index(!d.window, /create)
   tvd[i].zoom_save = tvd[i].zoom
   tvd[i].order_save = tvd[i].order
   tvd[i].rotate_save = tvd[i].rotate
   tvd[i].offset_save = tvd[i].offset
   return
  end

 ;======================
 ; interpret keywords
 ;======================
 window_exists=0
 if(!d.window NE -1 AND NOT keyword__set(new)) then window_exists=1

 if(NOT keyword__set(channel)) then channel = 0
 all = keyword__set(all)
 inherit = keyword__set(inherit)
 default = keyword__set(default)
 entire = keyword__set(entire)
 previous = keyword__set(previous)
 home = keyword__set(home)
 restore = keyword__set(restore)
 local_scaling = keyword__set(local_scaling)
 flip = keyword__set(flip)
 coord_sys = 0

 override_size = 0
 if(keyword_set(wxsize) AND keyword_set(wysize)) then override_size=1


 ;============================================================
 ; if this is a new window or if /default, then use defaults 
 ;============================================================
 if((default OR NOT window_exists) AND NOT inherit) then $
  begin
   zoom = [1d,1d]
   order = 0
   rotate = 0
   offset = [0d,0d]
   new = 1
   force_xsize = (force_ysize = 0)
  end $
 ;======================================================================
 ; otherwise, get window parameters according to /previous, /restore, 
 ; /inherit, /home, and /entire
 ;======================================================================
 else $
  begin
   i = tvim_get_index(!d.window, /create)
   force_xsize = tvd[i].force_xsize
   force_ysize = tvd[i].force_ysize
   if(previous AND tvd[i].prev) then $
    begin
     if(NOT tvim_zoom_valid(tvd[i].zoom_prev)) then return
     zoom = tvd[i].zoom_prev
     order = tvd[i].order_prev
     rotate = tvd[i].rotate_prev
     offset = tvd[i].offset_prev
    end $
   else if(restore AND tvim_zoom_valid(tvd[i].zoom_save)) then $
    begin
     zoom = tvd[i].zoom_save
     order = tvd[i].order_save
     rotate = tvd[i].rotate_save
     offset = tvd[i].offset_save
    end $
   else $
    begin
     zoom = tvd[i].zoom
     order = tvd[i].order
     rotate = tvd[i].rotate
     offset = tvd[i].offset
    end

   if(home) then $
    begin
     zoom = tvd[i].zoom
     order = tvd[i].order
     rotate = tvd[i].rotate
     offset = [0d,0d]
    end

   if(entire) then $
    begin
     s = size(image)
     zz = min([double(!d.x_size)/double(s[1]), double(!d.y_size)/double(s[2])])
     zoom = [zz,zz]
     offset = [0d,0d]
    end
  end


 ;==========================
 ; override parameters
 ;==========================
 if(keyword_set(_zoom)) then zoom = _zoom
 if(n_elements(_order) NE 0) then order = _order
 if(n_elements(_rotate) NE 0) then rotate = _rotate
 if(keyword_set(_offset)) then offset = _offset
 if(keyword_set(doffset)) then offset = offset + doffset
 if(flip) then order = 1 - order


 ;=================================================================
 ; create window if size is overridden and there isn't already one
 ;=================================================================
 if(override_size AND NOT window_exists) then $
  if((NOT keyword_set(no_wset)) AND (NOT keyword__set(nowin))) then $
   begin
    x_window, base=base, /free, xsize=wxsize, ysize=wysize, pixmap=pixmap, retain=retain, title=title
    window_exists=1
   end


 ;============================================================================
 ; if no args are given, then print the current wnum unless /silent
 ;============================================================================
 if(NOT keyword_set(image) AND NOT keyword_set(wnum)) then $
  if(NOT keyword_set(silent)) then $
   begin
    if(NOT all) then print, !d.window $
    else print, tvd.wnum

;    if(NOT all) then wnum=!d.window $
;    else print, wnum=tvd.wnum

;    print, 'wnum   = '+strtrim(wnum,2)
;    print, 'zoom = '+strtrim(tvd.zoom[0],2)+','+strtrim(tvd.zoom[1],2)
;    print, 'offset = '+strtrim(tvd.offset[0],2)+','+strtrim(tvd.offset[1],2)
;    print, 'order  = '+strtrim(keyword__set(tvd.order),2)
;    print, 'rotate  = '+strtrim(keyword__set(tvd.rotate),2)
   end
 _wnum = !d.window


 ;============================
 ; make tvim_info accessible
 ;============================
 i = tvim_get_index(!d.window, /create)
 if(i NE -1) then get_info = tvd[i]


 ;=========================================================================
 ; establish coordinate system  - do it first if a window exists
 ;=========================================================================
 if(window_exists) then $
  begin
;   if(NOT keyword_set(no_coord)) then $
                 tvim_set, zoom=zoom, order=order, rotate=rotate, offset=offset, $
                 xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, $
                 force_xsize=force_xsize, force_ysize=force_ysize, no_coord=no_coord, $
                 integer_zoom=integer_zoom
   coord_sys=1
  end


 ;======================================
 ; go no further if no image given
 ;======================================
 if(NOT keyword_set(image)) then return


 ;======================
 ; get image size
 ;======================
 s = size(image)
 image_xsize = s[1]
 image_ysize = s[2]
 image_zsize = 1
 if(s[0] EQ 3) then image_zsize = s[3]


 ;======================
 ; get min/max values
 ;======================
 if(NOT keyword_set(max)) then $
        for i=0, image_zsize-1 do max = append_array(max, max(image[*,*,i],/nan))
 if(NOT keyword_set(min)) then $
        for i=0, image_zsize-1 do min = append_array(min, min(image[*,*,i],/nan))

 maxx = max(max)
 minn = min(min)


 ;==========================
 ; get image bounds
 ;==========================
 if(NOT window_exists) then $
  begin
   xmin = 0 & xmax = image_xsize-1
   ymin = 0 & ymax = image_ysize-1
  end $
 else $
  begin
   xmin = xmin > 0 
   ymin = ymin > 0 
   xmax = xmax < (image_xsize-1)
   ymax = ymax < (image_ysize-1)
  end


 ;=========================================
 ; create window if it still doesn't exist
 ;=========================================
; ss = size(tvimage)
 ss = size(image)
 if(NOT window_exists) then $
  if(NOT keyword_set(no_wset)) then $
   if(NOT keyword_set(nowin)) then $
     begin  
      tvxsize = round((xmax-xmin+1)*zoom[0]) > 1
;      tvysize = round((xmax-xmin+1)*zoom[1]) > 1
      tvysize = round((ymax-ymin+1)*zoom[1]) > 1

      x_window, base=base, /free, xsize=tvxsize, ysize=tvysize, pixmap=pixmap, title=title
      window_exists=1
     end


 ;=====================================================
 ; establish coordinate system 
 ;=====================================================
; if((NOT coord_sys) AND (NOT keyword_set(no_coord))) then $
 if(NOT coord_sys) then $
      tvim_set, zoom=zoom, order=order, rotate=rotate, offset=offset, $
           force_xsize=force_xsize, force_ysize=force_ysize, no_coord=no_coord, $
           integer_zoom=integer_zoom


 ;======================================
 ; go no further if no image given
 ;======================================
 if(NOT keyword_set(image)) then return



 ;===================================================
 ; get displayed image
 ;===================================================
 if(keyword_set(tvimage)) then tvimage = image $ 
 else $
  begin
   vp = get_viewport_indices([image_xsize, image_ysize], device_indices=vpi)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; go no further if viewing area does not include image
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(erase)) then erase

   if(vp[0] EQ -1) then $
    begin
     if(keyword_set(draw_pixmap)) then erase
     return
    end

   tvimage = make_array(!d.x_size, !d.y_size, image_zsize, /nozero)
   im = make_array(!d.x_size, !d.y_size, /nozero)
   for i=0, image_zsize-1 do $
    begin
     im[*] = 0
     im[vpi] = (image[*,*,i])[vp]
     tvimage[*,*,i] = im
    end
  end


 ;==========================
 ; display image
 ;==========================
 if(NOT keyword_set(rotate)) then rotate = 0 


 ;------------------------------------------------
 ; if draw_pixmap given, then draw on the pixmap
 ;------------------------------------------------
 if(keyword_set(draw_pixmap)) then $
  begin
   save_wnum = !d.window
   wset, draw_pixmap
   erase
  end

 ;--------------------------------------
 ; scale image for display
 ;--------------------------------------
 if(image_zsize EQ 1) then $
  begin
;   if(keyword_set(rotate)) then tvimage = rotate(tvimage, rotate)
   if(NOT keyword_set(no_scale)) then $
    begin
     if(local_scaling) then tvimage = bytscl(tvimage, top=tvim_top) $
     else tvimage = bytscl(tvimage, min=min[0], max=max[0], top=tvim_top)
    end
   if(NOT keyword_set(noplot)) then tv, tvimage, channel=channel, top=tvim_top
  end $
 else if(image_zsize EQ 3) then $
  begin
;   if(keyword_set(rotate)) then $
;    begin
;     tvimage[*,*,0] = rotate(tvimage[*,*,0], rotate)
;     tvimage[*,*,1] = rotate(tvimage[*,*,1], rotate)
;     tvimage[*,*,2] = rotate(tvimage[*,*,2], rotate)
;    end
   if(local_scaling) then $
    begin
     tvimage[*,*,0] = bytscl(tvimage[*,*,0], top=tvim_top)
     tvimage[*,*,1] = bytscl(tvimage[*,*,1], top=tvim_top)
     tvimage[*,*,2] = bytscl(tvimage[*,*,2], top=tvim_top)
   end $
   else if(NOT keyword_set(no_scale)) then $
    begin
;     tvimage[*,*,0] = $
;        bytscl(tvimage[*,*,0], min=min[0], max=max[0], top=tvim_top)
;     tvimage[*,*,1] = $
;        bytscl(tvimage[*,*,1], min=min[1], max=max[1], top=tvim_top)
;     tvimage[*,*,2] = $
;        bytscl(tvimage[*,*,2], min=min[2], max=max[2], top=tvim_top)
     tvimage[*,*,0] = $
        bytscl(tvimage[*,*,0], min=minn, max=maxx, top=tvim_top)
     tvimage[*,*,1] = $
        bytscl(tvimage[*,*,1], min=minn, max=maxx, top=tvim_top)
     tvimage[*,*,2] = $
        bytscl(tvimage[*,*,2], min=minn, max=maxx, top=tvim_top)
   end

   if(NOT keyword_set(noplot)) then $
    begin
     tv, tvimage[*,*,0], channel=1, top=tvim_top
     tv, tvimage[*,*,1], channel=2, top=tvim_top
     tv, tvimage[*,*,2], channel=3, top=tvim_top
    end
  end $
 else message, 'Image must have either one or three planes.'

 ;------------------------------------------------
 ; if draw_pixmap given, then copy to main window
 ;------------------------------------------------
 if(keyword_set(draw_pixmap) AND (NOT keyword_set(no_copy))) then $
  begin
   wset, save_wnum
   device, copy=[0,0, !d.x_size-1,!d.y_size-1, 0,0, draw_pixmap]
  end


end
;===========================================================================
