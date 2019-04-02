;=============================================================================
;+-+
; NAME:
;	brim
;
;
; PURPOSE:
;	Image browser.
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	brim, files
;
;
; ARGUMENTS:
;  INPUT:
;	files:	List of filenames and file specifications.  Only files whose
;		filetypes can be detected are loaded.  If this argument is not
;		given, the user is prompted for a list of files.  An array of
;		data descriptors may also be specified.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	thumbsize:	Size of the thumbnal images.  Default is 100 pixels.
;			Thumbnail images are alwasy square.
;
;	labels:		Labels to use for each thumbnail.  If none given, the
;			filename is used, if one exists.
;
;	left_fn:	Name of a procedure to call when the left mouse button
;			is clicked on a thumbnail.  The
;			user procedure is called as follows: 
;
;			   left_fn, brim_data, fn_data, i, dd, status=status
;
;			brim_data is the brim data structure, required by 
;			calls to brim functions, fn_data is supplied by the 
;			caller through the fn_data keyword, i is the index of 
;			the thumbnail, dd is the thumbnail data descriptor, 
;			and status should return 0 if successful and nonzero 
;			otherwise.
;
;	middle_fn:	Name of a procedure to call when the middle mouse button
;			is clicked on a thumbnail.  There is no default.
;
;	right_fn:	Name of a procedure to call when the right mouse button
;			is clicked on a thumbnail.  There is no default.
;
;	fn_data:	Data to be supplied to the above user procedures.
;
;	path:		Initial path to use for the file selection widget, 
;			which appears only if the file argument is not given. 
;
;	modal:		If set, only the brim widget may be used until it
;			is closed.
;
;	title:		Title to use for the brim widget instead of 'brim'.
;
;	order:		Display order for thumbnails.  Default is 0.
;
;	filter:		Initial filter to use when loading files.
;
;  OUTPUT:
;	get_path:	Final path selected in the file selection widget.
;
;	select:		On return, select contains the file names of the selected
;			images.  If there are no selections, its value will be
;			the null string.
;
;
; RETURN:
;	NONE
;
;
; PROCEDURE:
;	brim may be run standalone or from within grim.  If no files or data
;	descriptors are given, brim first prompts the user to select a list of
;	files.  brim then displays thumbnails of all valid files.  Files may be
;	selected by clicking with the left mouse button.  By default, the image
;	is opened in a new grim window.  Alternate actions may be defined
;	through procedures supplied by the caller.
;
;
; EXAMPLES:
;	To load files into brim using a file-selection widget:
;
;	 IDL> brim
;
;
;	To load all recognizeable images in the current directory into brim:
;
;	 IDL> brim, '*'
;
;
;	To browse a set of data descriptors:
;
;	 IDL> dd = dat_read('*')
;	 IDL> brim, dd
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================



;=============================================================================
; brim_image
;
;
;=============================================================================
function brim_image, brim_data, ii, abscissa=abscissa, full=full
;full=1

 dd = brim_data.dd[ii]
 if(keyword_set(full)) then return, dat_data(dd, abscissa=abscissa)

 ;----------------------------------------------
 ; get image parameters
 ;----------------------------------------------
 dim = dat_dim(dd)
 if(NOT keyword_set(dim)) then return, 0
 dim = dim[0:1]
 max = max(dat_max(dd))

 ;------------------------------------------------------------------------
 ; set tvim coordinate system
 ;  Constrain to integer or 1/integer zoom to avoid aliasing in the 
 ;  sampling grid.  This allows for queries on file types the support
 ;  simple off/stepsize queries, e.g., w10n.
 ;------------------------------------------------------------------------
 zoom = min([double(!d.x_size)/dim[0], double(!d.y_size)/dim[1]])
 if(zoom GT 1) then zoom = long(zoom) $ 
 else if(zoom LT 1)  then zoom = 1d/(double(long(1/zoom)-1))
help, zoom
 tvim, /silent, zoom=zoom

 ;----------------------------------------------
 ; sample image
 ;----------------------------------------------
 vp = get_viewport_indices(dim, p=sample, $
                              device_indices=vpi, device_size=device_size)
 if(n_elements(vp) EQ 1) then return, 0

 image = dat_data(dd, sample=sample, abscissa=abscissa)
 thumbnail = make_array(type=size(image, /type), dim=device_size)
 thumbnail[vpi] = image

 return, thumbnail
end
;=============================================================================



;=============================================================================
; brim_display
;
;
;=============================================================================
pro brim_display, brim_data, ii

 dd = brim_data.dd
 size = brim_data.thumbsize
 if(NOT defined(ii)) then ii = lindgen(n_elements(dd))
 if(ii[0] EQ -1) then return

 ;----------------------------------------------
 ; determine label strings
 ;----------------------------------------------
 labels = brim_data.labels
 if(NOT keyword_set(labels)) then labels = cor_name(dd)

 ;----------------------------------------------
 ; display images
 ;----------------------------------------------
 for j=0, n_elements(ii)-1 do $ 
  begin
   i = ii[j]

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; get thumbnail
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   image = cor_udata(dd[i], 'BRIM_THUMBNAIL')
   if(NOT keyword_set(image)) then $
                      image = brim_image(brim_data, i, abscissa=abscissa)

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; display thumbnail
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ndim = n_elements(size(image, /dim))
   if(ndim EQ 1) then tvgr, brim_data.wnums[i], abscissa, image $
   else $
    begin
     if(ndim EQ 3) then image = total(image,3)

     dim = size(image, /dim) 
     zoom = min(float(size)/float(dim))

     if(brim_data.order NE -1) then order = brim_data.order
     tvim, brim_data.wnums[i], order=order, image, zoom=zoom
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; save thumbnail
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   cor_set_udata, dd[i], 'BRIM_THUMBNAIL', image
   widget_control, brim_data.label_widgets[i], set_value=labels[i]
  end

end
;=============================================================================



;=============================================================================
; brim_data_event
;
;=============================================================================
pro brim_data_event, event
;print, 'brim_data_event'

; data = *event.data_p

; brim_data = data.data
; dd = data.dd



end
;=============================================================================



;=============================================================================
; brim_register_data_events
;
;=============================================================================
pro brim_register_data_events, brim_data, dd

 for i=0, n_elements(dd)-1 do $
   nv_notify_register, dd[i], 'brim_data_event', data={data:brim_data, dd:dd[i]}

end
;=============================================================================



;=============================================================================
; brim_configure
;
;=============================================================================
function brim_configure, dd, base=base, $
     thumbsize=thumbsize, labels=labels, $
     left_fn=left_fn, middle_fn=middle_fn, right_fn=right_fn, fn_data=fn_data, $
     path=path, get_path=get_path, $
     modal=modal, title=title, order=order

 label_ysize = 30
; label_ysize = 22
 nmore = 0
 n = n_elements(dd)

 ;------------------------------------
 ; widgets
 ;------------------------------------
 if(nmore LT 0) then $
  begin
   widget_control, /destroy, brim_data.draw_bases[n-1]
   draw_bases = brim_data.draw_bases[0:n-2]
   draw_widgets = brim_data.draw_widgets[0:n-2]
   label_widgets = brim_data.label_widgets[0:n-2]
   wnums = brim_data.wnums[0:n-2]
  end

 if(keyword_set(base) OR (nmore GT 0)) then $
  begin
;   done_button = widget_button(base, value='Done')

   scroll_base = widget_info(base, /child)
   widget_control, scroll_base, get_uvalue=nx

   nn = n + nmore
   ny = nn/nx + (nn mod nx NE 0)

   xsize = 600 < nx*thumbsize * 1.1
   ysize = 800 < (ny*(thumbsize + label_ysize) * 1.1)

   widget_control, scroll_base, scr_xsize=xsize, scr_ysize=ysize
;   widget_control, base, scr_xsize=xsize, scr_ysize=ysize

   nnn = nn
   if(keyword_set(brim_data)) then nnn = nmore
   for i=0, nnn-1 do $
    begin
     draw_base = widget_base(scroll_base, xpad=0, ypad=0, $
                     xsize=thumbsize, ysize=thumbsize+label_ysize, /frame, /col)
     draw_bases = append_array(draw_bases, draw_base)

     draw_widget = $
         widget_draw(draw_base, xsize=thumbsize, ysize=thumbsize, $
                 /button_events, event_pro='brim_draw_event', /motion_events,  $
                 retain=2, /tracking_events)
     draw_widgets = append_array(draw_widgets, draw_widget)

     label_widget = $
;          widget_label(draw_base, /align_left, xsize=thumbsize, value=' ')
          widget_text(draw_base, /align_left, xsize=thumbsize, value=' ')
     label_widgets = append_array(label_widgets, label_widget)
    end


   widget_control, /realize, base
   wnums = lonarr(nn)
   for i=0, nn-1 do $
    begin
     widget_control, draw_widgets[i], get_value=wnum
     wnums[i] = wnum
    end

  end

 ;----------------------------------
 ; data structure
 ;----------------------------------
 if(NOT keyword_set(base)) then base = brim_data.base

 brim_data = { $
		base			:	base, $
		select_dd_p		:	nv_ptr_new(obj_new()), $
		left_fn			:	left_fn, $
		middle_fn		:	middle_fn, $
		right_fn		:	right_fn, $
		fn_data			:	fn_data, $
		images_p		:	nv_ptr_new(), $
		wnums			:	wnums, $
		draw_bases		:	draw_bases, $
		scroll_base		:	scroll_base, $
		draw_widgets		:	draw_widgets, $
		label_widgets		:	label_widgets, $
		labels			:	labels, $
		dd			:	dd, $
		order			:	order, $
		base_xsize		:	0l, $
		base_ysize		:	0l, $
		scroll_xsize		:	0l, $
		scroll_ysize		:	0l, $
		thumbsize		:	thumbsize $
	}

 geom = widget_info(base, /geom)
 brim_data.base_xsize = geom.xsize
 brim_data.base_ysize = geom.ysize

 geom = widget_info(scroll_base, /geom)
 brim_data.scroll_xsize = geom.scr_xsize
 brim_data.scroll_ysize = geom.scr_ysize

 widget_control, base, set_uvalue=brim_data

 ;----------------------------------
 ; load and display images
 ;----------------------------------
 widget_control, /hourglass
 brim_display, brim_data
 brim_register_data_events, brim_data, dd

 return, brim_data
end
;=============================================================================



;=============================================================================
; brim_frame
;
;
;=============================================================================
pro brim_frame, brim_data, i

 wset, brim_data.wnums[i]
 xs = !d.x_size-2
 ys = !d.y_size-2
 plots, [1,xs,xs,1,1], [1,1,ys,ys,1], /device, col=ctred(), th=3

end
;=============================================================================



;=============================================================================
; brim_select
;
;
;=============================================================================
pro brim_select, brim_data, i, select=select, deselect=deselect, clear=clear

 select_dd = *brim_data.select_dd_p

 ;-------------------------------------
 ; clear selections
 ;-------------------------------------
 if(keyword_set(clear)) then $
  begin
   w = [-1]
   if(keyword_set(select_dd)) then w = nwhere(brim_data.dd, select_dd)
   brim_display, brim_data, w
   *brim_data.select_dd_p = obj_new()
   return
  end


 ;-------------------------------------
 ; determine which thumbs are selected
 ;-------------------------------------
 w = where(select_dd EQ brim_data.dd[i])


 ;-------------------------------------
 ; implement selection/deselection
 ;-------------------------------------
 if(keyword_set(select) OR (w[0] EQ -1)) then $
  begin
   select_dd = append_array(select_dd, brim_data.dd[i])
   brim_frame, brim_data, i
  end

 if(keyword_set(deselect) OR (w[0] NE -1)) then $
  begin
   select_dd = rm_list_item(select_dd, w, only=obj_new(), /scalar)
   brim_display, brim_data, i
  end

 *brim_data.select_dd_p = select_dd
 widget_control, brim_data.base, set_uvalue=brim_data
end
;=============================================================================



;=============================================================================
; brim_grim
;
;=============================================================================
pro brim_grim, brim_data, dd

 widget_control, /hourglass

 if(brim_data.order NE -1) then order = brim_data.order
; grim, /new, dd, order=order
 grim, /new, dat_filename(dd), order=order

end
;=============================================================================



;=============================================================================
; brim_fn_left
;
;=============================================================================
pro brim_fn_left, brim_data, data, i, dd, status=status

 status = 0
 event = data

 if(event.clicks EQ 2) then $
  begin
   brim_select, brim_data, /clear
   brim_select, brim_data, i, /select
   select_dd = *brim_data.select_dd_p
   dd = unique(append_array(brim_data.dd[i], select_dd))
   brim_grim, brim_data, dd
  end $
 else brim_select, brim_data, i

end
;=============================================================================



;=============================================================================
; brim_fn_right
;
;=============================================================================
pro brim_fn_right, brim_data, data, i, dd, status=status

end
;=============================================================================



;=============================================================================
; brim_event
;
;=============================================================================
pro brim_event, event

 base = event.top
 widget_control, base, get_uvalue=brim_data 
 struct = tag_names(event, /struct)

 ;-----------------------------------------------
 ; adjust base size
 ;-----------------------------------------------
 if(struct EQ 'WIDGET_BASE') then $
  begin
   dx = event.x - brim_data.base_xsize
   dy = event.y - brim_data.base_ysize

   widget_control, brim_data.scroll_base, $
         scr_xsize=brim_data.scroll_xsize+dx, scr_ysize=brim_data.scroll_ysize+dy

   geom = widget_info(base, /geom)
   brim_data.base_xsize = geom.xsize
   brim_data.base_ysize = geom.ysize

   geom = widget_info(brim_data.scroll_base, /geom)
   brim_data.scroll_xsize = geom.scr_xsize
   brim_data.scroll_ysize = geom.scr_ysize

   widget_control, base, set_uvalue=brim_data
   return
  end


 widget_control, brim_data.base, /destroy

end
;=============================================================================



;=============================================================================
; brim_draw_event
;
;=============================================================================
pro brim_draw_event, event


 widget_control, event.top, get_uvalue=brim_data 

 i = (where(event.id EQ brim_data.draw_widgets))[0]

 struct = tag_names(event, /struct)

; if(struct EQ 'WIDGET_TRACKING') then $
;  if(event.enter) then $
;   begin
;    brim_select, brim_data, i
;    return
;   end
 if(struct EQ 'WIDGET_TRACKING') then return

 ;--------------------------
 ; motion events
 ;--------------------------
 if(event.type EQ 2) then $
  begin
   wset, brim_data.wnums[i]
   device, cursor_standard=60
  end

 ;--------------------------
 ; button-press events
 ;--------------------------
 if(event.type NE 0) then return 

 fn_data = brim_data.fn_data
 if(NOT keyword_set(fn_data)) then fn_data = event

 case event.press of
  1 : if(keyword__set(brim_data.left_fn)) then $
           call_procedure, brim_data.left_fn, brim_data, fn_data, i, $
                                          brim_data.dd[i], status=status
  2 : if(keyword__set(brim_data.middle_fn)) then $
           call_procedure, brim_data.middle_fn, brim_data, fn_data, i, $
                                          brim_data.dd[i], status=status
  4 : if(keyword__set(brim_data.right_fn)) then $
           call_procedure, brim_data.right_fn, brim_data, fn_data, i, $
                                          brim_data.dd[i], status=status
  else:
 endcase


end
;=============================================================================



;=============================================================================
; brim
;
;=============================================================================
pro brim, arg, thumbsize=thumbsize, labels=labels, $
     left_fn=left_fn, middle_fn=middle_fn, right_fn=right_fn, fn_data=fn_data, $
     path=path, get_path=get_path, picktitle=picktitle, $
     modal=modal, title=title, order=order, filter=filter, $
     base=base, select=select

 if(NOT keyword_set(arg)) then arg = ''
 if(NOT defined(left_fn)) then left_fn = 'brim_fn_left'
 if(NOT defined(middle_fn)) then middle_fn = ''
 if(NOT defined(right_fn)) then right_fn = 'brim_fn_right'
 if(NOT keyword_set(fn_data)) then fn_data = ''
 if(NOT keyword_set(labels)) then labels = ''
 if(NOT keyword_set(order)) then order = -1
 if(NOT keyword_set(thumbsize)) then thumbsize = 100
 if(NOT keyword_set(picktitle)) then picktitle = 'Select files to load'

 sep = path_sep()

 ;-------------------------------------------------------------------------
 ; test for dd or filename inputs
 ;-------------------------------------------------------------------------
 if(size(arg, /type) EQ 11) then dd = arg $
 else $
  begin
   filespecs = arg

   ;----------------------------------
   ; select files if none given
   ;----------------------------------
   if(NOT keyword_set(filespecs)) then $
    begin
     files = $
      pickfiles(get_path=get_path, title=picktitle, $
                                               path=path, filter=filter)
     if(NOT keyword_set(files[0])) then return
    end $
   ;--------------------------------------------------------------------
   ; Otherwise determine filetypes and resolve any file specifications 
   ;--------------------------------------------------------------------
   else $
    for i=0, n_elements(filespecs)-1 do $
     begin
      filetype = dat_detect_filetype(filename=filespecs[i])
      if(keyword_set(filetype)) then $
                files = append_array(files, dat_expand(filetype, filespecs[i]))
     end

   w = where(files NE '')
   if(w[0] EQ -1) then return
   files = files[w]

   w = where(strpos(files,sep) NE -1)
   if(w[0] EQ -1) then return
   files = files[w]

   if(NOT keyword_set(files)) then return

   dd = dat_read(files, maintain=2)
  end


 ;----------------------------------
 ; geometry
 ;----------------------------------
 n = n_elements(dd) 

 nx = sqrt(n)
 if((nx mod 1) NE 0) then nx = fix(nx) + 1

 ;----------------------------------
 ; widgets
 ;----------------------------------
 if(NOT keyword_set(title)) then title = 'BRIM'

; base = widget_base(title=title, /column, /tlb_size_events)
 base = widget_base(title=title, /tlb_size_events, resource_name='brim_base')

 scroll_base = widget_base(base, xpad=0, ypad=0, /scroll, col=nx, space=0)
 widget_control, scroll_base, set_uvalue=nx

 brim_data = brim_configure(dd, base=base, $
     thumbsize=thumbsize, labels=labels, $
     left_fn=left_fn, middle_fn=middle_fn, right_fn=right_fn, fn_data=fn_data, $
     path=path, get_path=get_path, $
     modal=modal, title=title, order=order)

 no_block = 1
 if(keyword_set(modal)) then no_block = 0
 xmanager, 'brim', base, no_block=no_block


 ;----------------------------------
 ; menu
 ;----------------------------------
; menu_desc = [ '1\File' , $
;               '0\Load                \brim_menu_file_load_event', $
;               '0\Open                \brim_menu_file_open_event', $
;               '2\<null>              \brim_menu_delim_event']
;bb = widget_base(group_leader=base, /floating, tlb_frame_attr=6)
;menu = cw__pdmenu(bb, menu_desc)
;widget_control, bb, /realize



 ;----------------------------------
 ; output selections
 ;----------------------------------
 select_dd = *brim_data.select_dd_p
 if(keyword_set(select_dd)) then $
  begin
   nselect = n_elements(select_dd)
   select = strarr(nselect)
   for i=0, nselect-1 do select[i] = dat_filename(select_dd[i])
  end
end
;=============================================================================
