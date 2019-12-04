;=============================================================================
;+
; NAME:
;	GRIM_COLORTOOL
;
;
; PURPOSE:
;	Tool for adjusting colors in GRIM.
;
;
; CATEGORY:
;	NV/GRIM
;
;
; CALLING SEQUENCE:
;	
;	grim_colortool
;
;
; ARGUMENTS: NONE
;
;
; KEYWORDS: NONE
;
;
; OPERATION:
;	Color table plot:
;		Displays a plot of the current color table, with a color
;		bar at the bottom.
;
;	Stretch Top slider:
;		Controls the top value for the color table stretch.
;
;	Stretch Bottom slider:
;		Controls the bottom value for the color table stretch.
;
;	Gamma slider:
;		Controls the gamma value for the color table stretch.
;
;	Shade slider:
;		Vertial slider on the left side of the tool controlling the 
;		total brightness.
;
;	Color table droplist:
;		Selects IDL color table.
;
;	Auto button:
;		Performs an automatic stretch.
;
;	All button:
;		If set (or activated), the current color table is applied
;		to all GRIM planes.  If 'Auto' is pressed while 'All' is
;		on, the automatic stretch is performed independently for
;		each plane.
;
;
; SEE ALSO:
;	grim
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale 
;	
;-
;=============================================================================



;=============================================================================
; grct_slider_to_gamma
;
;
;=============================================================================
function grct_slider_to_gamma, value
 return, 10d^(value/25d - 2d)
end
;=============================================================================



;=============================================================================
; grct_gamma_to_slider
;
;
;=============================================================================
function grct_gamma_to_slider, value
 return, 25d*(alog10(value) + 2d)
end
;=============================================================================



;=============================================================================
; grct_print_gamma
;
;
;=============================================================================
pro grct_print_gamma, data
  
 widget_control, data.gamma_slider, get_value = value
 widget_control, data.gamma_label, $
                set_value = str_pad(strtrim(grct_slider_to_gamma(value), 2), 7)

end
;=============================================================================



;=============================================================================
; grct_widget_to_descriptor
;
;
;=============================================================================
function grct_widget_to_descriptor, data, cmd

 ctmod, top=top
 n_colors = cmd.n_colors

 widget_control, data.bottom_slider, get_value = value 
 cmd.bottom = value/100d * n_colors
 widget_control, data.top_slider, get_value = value
 cmd.top = value/100d * n_colors

 widget_control, data.gamma_slider, get_value = value
 cmd.gamma = grct_slider_to_gamma(value)

 widget_control, data.shade_slider, get_value = value
 cmd.shade = value/100d

 return, cmd
end
;=============================================================================



;=============================================================================
; grct_descriptor_to_widget
;
;
;=============================================================================
pro grct_descriptor_to_widget, data, cmd, noslide=noslide

 n_colors = cmd.n_colors
 noslide = keyword_set(noslide)

 if(NOT noslide) then $
        widget_control, data.bottom_slider, set_value = cmd.bottom*100d/n_colors
 if(NOT noslide) then $
        widget_control, data.top_slider, set_value = cmd.top*100d/n_colors

 if(NOT noslide) then widget_control, data.gamma_slider,$
                        set_value = grct_gamma_to_slider(cmd.gamma) 

 if(NOT noslide) then $
        widget_control, data.shade_slider, set_value = cmd.shade*100d


 ctmod, top=top, visual=visual

 widget_control, data.base, $
                   tlb_set_title='Grim color tool : ' + grim_title(/primary)
end
;=============================================================================



;=============================================================================
; grct_plot
;
;
;=============================================================================
pro grct_plot, data

 grim_data = grim_get_data(/primary)
 plane = grim_get_plane(grim_data)

 n_colors = plane.cmd.n_colors

 wset, data.wnum
 colormap = compute_colormap(plane.cmd)
 colormap = congrid(colormap, 100) * 255 / n_colors

 ctmod, top=top, visual=visual

 erase, ctblack()
 plot, colormap, xstyle=1, ystyle=1, pos=[0.12,0.2, 0.95,0.95], th=2, $
       col=ctwhite()



 p = convert_coord(0d,0d, /data, /to_device)
 pp = convert_coord(100d,0d, /data, /to_device)

 xs = pp[0] - p[0]

 bar = long(findgen(xs) * float(100) / float(xs))

 yy = 15

 cbar = bar # make_array(yy, val=1)

 if((visual EQ 8)) then $
  begin 
   colorbar = apply_colormap(cbar, colormap)
   tv, colorbar, p[0], 0
  end $
 else $
  begin
   red = apply_colormap(cbar, colormap, channel=0)
   grn = apply_colormap(cbar, colormap, channel=1)
   blu = apply_colormap(cbar, colormap, channel=2)
   tv, red, channel=1, p[0], 0
   tv, grn, channel=2, p[0], 0
   tv, blu, channel=3, p[0], 0
  end


 plots, [p[0], p[0], pp[0]-1, pp[0]-1, p[0]], [0, yy, yy, 0, 0], /device


end
;=============================================================================



;=============================================================================
; grct_cleanup
;
;
;=============================================================================
pro grct_cleanup, base

 widget_control, base, get_uvalue=data
 grim_rm_primary_callback, data.data_p

end
;=============================================================================



;=============================================================================
; grct_update
;
;=============================================================================
pro grct_update, cmd, all=all, auto=auto

 grim_data = grim_get_data(/primary)
 if(NOT keyword_set(grim_data)) then return

 ctmod, visual=visual

 ;--------------------------------------
 ; detect color table change
 ;--------------------------------------
 tvlct, r, g, b, /get
 w = where([r, g, b] - $
           [*grim_data.tv_rp, *grim_data.tv_gp, *grim_data.tv_bp] NE 0)
 if((w[0] NE -1) AND (visual NE 24)) then $
  begin
   *grim_data.tv_rp = r
   *grim_data.tv_gp = g
   *grim_data.tv_bp = b
   return
  end

 ;--------------------------------------
 ; update cmd
 ;--------------------------------------
 planes = grim_get_plane(grim_data, all=all)
 n = n_elements(planes)

 if(keyword_set(auto)) then grim_stretch_plane, grim_data, planes $
 else $
  for i=0, n-1 do $
   begin
    planes[i].cmd = cmd
    grim_set_plane, grim_data, planes[i], pn=planes[i].pn
   end

 grim_set_data, grim_data, grim_data.base
 grim_refresh, grim_data, /no_erase
end
;=============================================================================



;=============================================================================
; grim_colortool_event
;
;
;=============================================================================
pro grim_colortool_event, event

 grim_data = grim_get_data(/primary)
 plane = grim_get_plane(grim_data)

 widget_control, event.top, get_uvalue=data, /hourglass

 struct = tag_names(event, /struct)
 update = 0
 auto = 0

 all = widget_info(data.all_button, /button_set)

 cmd = grct_widget_to_descriptor(data, plane.cmd)


 ;---------------------------
 ; 'All' button
 ;---------------------------
 if(event.id EQ data.all_button) then update = 1 $

 ;---------------------------
 ; 'Auto' button
 ;---------------------------
 else if(event.id EQ data.auto_button) then $
  begin
   auto = 1
   update = 1
  end $

 ;---------------------------
 ; 'Done' button
 ;---------------------------
 else if(event.id EQ data.done_button) then $
  begin
   widget_control, data.base, /destroy
   return
  end $

 ;---------------------------
 ; table droplist
 ;---------------------------
 else if(event.id EQ data.ct_droplist) then $
  begin
   loadct, event.index, /silent
   ctmod, top=top, visual=visual
   update = 1
  end $

 ;---------------------------
 ; draw widget
 ;---------------------------
 else if(event.id EQ data.graph) then $
  begin
   device, cursor_standard = 34
  end $

 ;---------------------------
 ; other widgets
 ;---------------------------
 else $
  begin
   grct_plot, data

   if(event.id EQ data.gamma_slider) then grct_print_gamma, data

   if(struct NE 'WIDGET_SLIDER') then update = 1 $
   else if(NOT event.drag) then update = 1
  end


 ;-------------------------------------
 ; update color table
 ;-------------------------------------
 if(update) then grct_update, cmd, all=all, auto=auto


 widget_control, event.top, set_uvalue=data
end
;=============================================================================



;=============================================================================
; grim_colortool_change
;
;
;=============================================================================
pro grim_colortool_change, base

 grim_data = grim_get_data(/primary)
 plane = grim_get_plane(grim_data)

 widget_control, base, get_uvalue=data

 grct_descriptor_to_widget, data, plane.cmd
 grct_plot, data
 grct_print_gamma, data

end
;=============================================================================



;=============================================================================
; grct_primary_notify
;
;
;=============================================================================
pro grct_primary_notify, data_p

 grim_data = grim_get_data(/primary)
 plane = grim_get_plane(grim_data)

 if(grim_data.type EQ 'plot') then return

 grim_colortool_change, (*data_p).base

end
;=============================================================================



;=============================================================================
; grim_colortool
;
;
;=============================================================================
pro grim_colortool
common grim_colortool_block, base

 grim_data = grim_get_data(/primary)
 plane = grim_get_plane(grim_data)

 if(xregistered('grim_colortool')) then $
  begin
   grim_colortool_change, base
   return
  end


 ;-------------------------------------------------------------------
 ; get color table names and values
 ;-------------------------------------------------------------------
 loadct, get_names=ct_list
 

 ;--------------------------------------------
 ; widgets
 ;--------------------------------------------
 base = widget_base(/col)

 fns = ['Linear', 'Exponential', 'Log']

 col_base = widget_base(base, /col)
 dl_base = widget_base(col_base, /row)
 all_base = widget_base(dl_base, /nonexclusive, /frame)
 all_button = widget_button(all_base, value=' All')
 auto_button = widget_button(dl_base, value='Auto')
 ct_droplist = widget_droplist(dl_base, value=ct_list, title='Color Table:')
 row_base = widget_base(col_base, /row, /frame)


 shade_slider = widget_slider(row_base, ysize=180, /drag, max=100, /vertical, /supp)
 graph = widget_draw(row_base, xsize=220, ysize=180, /tracking, retain=2)
 slider_base = widget_base(row_base, /col, xsize=200)
 top_slider = $
          widget_slider(slider_base, title='Stretch top', xsize=200, $
                                                             max=100, /drag)

 bottom_slider = $
     widget_slider(slider_base, title='Stretch bottom', xsize=200, $
                                                             max=100, /drag)

 gamma_label = widget_label(slider_base, value='---------', /align_center)
 gamma_slider = $
            widget_slider(slider_base, title='Gamma', $
                                               xsize=200, /drag, /suppress)

 done_button = widget_button(base, value='Done')





 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'grim_colortool', base, /no_block, cleanup='grct_cleanup'


 widget_control, graph, get_value=wnum


 ;-----------------------------------------------
 ; main data structure
 ;-----------------------------------------------
 data = { $
		;-------------------
 		; widgets
		;-------------------
		base		:	base, $
		ct_droplist	:	ct_droplist, $
		all_button	:	all_button, $
		auto_button	:	auto_button, $
		graph		:	graph, $
		top_slider	:	top_slider, $
		bottom_slider	:	bottom_slider, $
		gamma_slider	:	gamma_slider, $
		gamma_label	:	gamma_label, $
		shade_slider	:	shade_slider, $
		done_button	:	done_button, $
		wnum		:	wnum, $

		;-------------------
 		; book-keeping
		;-------------------
		data_p		:	nv_ptr_new() $
	     }

 data.data_p = nv_ptr_new(data)

 widget_control, base, set_uvalue = data

 grct_descriptor_to_widget, data, plane.cmd
 grct_plot, data

 grim_add_primary_callback, 'grct_primary_notify', data.data_p
 grct_print_gamma, data

end
;=============================================================================
