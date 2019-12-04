;=============================================================================
;+
; NAME:
;	widget_parm
;
;
; PURPOSE:
;	Generic widget interface for varying parameters.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	base = widget_parm(parm, callback=callback)
;
;
; ARGUMENTS:
;  INPUT:
;	parm:	Structure specifying the parameters to vary.  Format is:
;
;		{<name>: <value>, [opt1]_<name>:<items>, [opt2]_<name>:<items>, ...}
;
;		where <name> is the parameter name, <value> is the initial
;		value, [opt] depends on the type of parameter, and <items>
;		is an array of items specific to the option.  Parameter types are
;		as follows:
;
;		Numeric:	Input is varied via a slider widget.  Options are:
;				 RANGE:	Upper and lower bounds for the slider.
;				 UNITS:	Value to convert units for display.
;
;		String input:	Input is given using a text widget.  There is 
;				no [option].
;
;		String select:	Input is given using droplist whose items are 
;				given by the <items> array with the [option]
;				'OPTION'.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	callback:	String giving the name of a prodcedure to be called
;			whenever the parameters are updated.
;
;	data:		Data to be passed to the callback procedure as the
;			sole argument.
;
;	title:		String giving the title for the widget base.
;
;	xsize:		Width of widget in pixels.
;
;  OUTPUT: NONE
;
;
; RETURN: Widget ID of the base widget.
;
;
; OPERATION:
;	Widget_parm operates in two modes: continuous and manual, toggled using
;	the CONTINUOUS button.  In continuous mode, the callback procedure is
;	call whenever any parameter is changed.  In manual mode, the callback
;	procedure is called only when the UPDATE button is preseed.  
;
;
; EXAMPLE:
;	base = widget_parm( $
;	           { x:10,		range_x:[0,100], $
;		     y:5,		range_y:[0,10], units_y: !dpi/180, $
;		     s:'test', $
;		     ss:'option 1',	options_ss:['option 1', 'option 2'] }, $
;		    callback='test_callback')
;
;
; STATUS:
;	Complete
;
;

; MODIFICATION HISTORY:
; 	Written by:	Spitale		5/2017
;	
;-
;=============================================================================



;=============================================================================
; wprm_widget_to_value
;
;=============================================================================
function wprm_widget_to_value, id, display=display

 type = widget_info(id, /name)
 widget_control, id, get_uvalue=dat

 if(type EQ 'SLIDER') then $
  begin
   widget_control, id, get_value=value
   val = double(value)/100d * (dat.range[1]-dat.range[0]) + dat.range[0]
   if(keyword_set(display)) then val = val * dat.units
   return, val
  end

 if(type EQ 'TEXT') then $
  begin
   widget_control, id, get_value=value
   return, value
  end

 if(type EQ 'DROPLIST') then $
  begin
   widget_control, id, get_value=options
   index = widget_info(id, /droplist_select)
   return, options[index]
  end


end
;=============================================================================




;=============================================================================
; wprm_value_to_widget
;
;=============================================================================
pro wprm_value_to_widget, id, parm

 type = widget_info(id, /name)

 widget_control, id, get_uvalue=dat
 val = struct_get(parm, dat.name)

 if(type EQ 'SLIDER') then $
  begin
   value = (val - dat.range[0]) * 100d / (dat.range[1]-dat.range[0])
   widget_control, id, set_value=value
   widget_control, dat.label, set_value=strtrim(val,2)
   return
  end

 if(type EQ 'TEXT') then $
  begin
   widget_control, id, set_value=val
   return
  end

 if(type EQ 'DROPLIST') then $
  begin
   widget_control, id, get_value=options
   w = where(options EQ val)
   widget_control, id, set_droplist_select=w
   return
  end

end
;=============================================================================




;=============================================================================
; wprm_parm_to_widget
;
;=============================================================================
pro wprm_parm_to_widget, data, parm

 for i=0, n_elements(data.controls)-1 do $
  begin
   widget_control, data.controls[i], get_uvalue=dat
   wprm_value_to_widget, data.controls[i], parm
  end

end
;=============================================================================




;=============================================================================
; wprm_widget_to_parm
;
;=============================================================================
function wprm_widget_to_parm, data

 for i=0, n_elements(data.controls)-1 do $
  begin
   widget_control, data.controls[i], get_uvalue=dat
   value = wprm_widget_to_value(data.controls[i])
   parm = append_struct(parm, create_struct(dat.name, value))
  end

 return, parm
end
;=============================================================================




;=============================================================================
; wprm_update
;
;=============================================================================
pro wprm_update, data

 call_procedure, $
     data.update_callback, wprm_widget_to_parm(data), data.callback_data
end
;=============================================================================




;=============================================================================
; widget_parm_event
;
;=============================================================================
pro widget_parm_event, event

 widget_control, event.top, get_uvalue=data

 ;--------------------------------------
 ; Any slider -- update label
 ;--------------------------------------
 if(tag_names(event, /structure) EQ 'WIDGET_SLIDER') then $
  begin
   widget_control, event.id, get_uvalue=dat
   widget_control, dat.label, $
          set_value=strtrim(wprm_widget_to_value(event.id, /display),2)

   if(event.drag) then return
  end $

 ;--------------------------------------
 ; CONTINUOUS button
 ;--------------------------------------
 else if(event.id EQ data.continuous_button) then $
  begin
   widget_control, data.update_button, sensitive=1-event.select
   if(NOT event.select) then return
  end $

 ;--------------------------------------
 ; UPDATE button
 ;--------------------------------------
 else if(event.id EQ data.update_button) then $
  begin
   wprm_update, data
   return
  end
 

 if(widget_info(data.continuous_button, /button_set)) then wprm_update, data
end
;=============================================================================



;=============================================================================
; wprm_get_value
;
;=============================================================================
function wprm_get_value, parm0, prefix, name, default=default
 if(NOT keyword_set(default)) then default = 0d

 w = where(tag_names(parm0) EQ prefix + name)
 if(w[0] EQ -1) then return, default
 return, parm0.(w)
end
;=============================================================================



;=============================================================================
; widget_parm
;
;=============================================================================
function widget_parm, parm0, title=title, xsize=xsize, $
            callback=update_callback, data=callback_data

 if(NOT keyword_set(xsize)) then xsize = 300
 if(NOT keyword_set(callback_data)) then callback_data = 0

 ;--------------------------------------
 ; parse parm structure
 ;--------------------------------------
 parm = parm0
 ranges = struct_extract(parm, 'RANGE_', rem=parm)
 options = struct_extract(parm, 'OPTIONS_', rem=parm)
 units = struct_extract(parm, 'UNITS_', rem=parm)

 parm_names = tag_names(parm)
 nparm = n_elements(parm_names)

 ;--------------------------------------
 ; widgets
 ;--------------------------------------
 base = widget_base(/col, title=title, uname='widget_parm_base')

 lablen = max(strlen(parm_names))+1

 for i=0, nparm-1 do $
  begin
   parm_base = widget_base(base, /row)
   parm_label = widget_label(parm_base, value=str_pad(parm_names[i]+':',lablen))

   value = parm.(i)
   type = size(value, /type)

   ;- - - - - - - - - - - - - - - - - -
   ; string type
   ;- - - - - - - - - - - - - - - - - -
   case type of
    7: $
	begin
	 option = wprm_get_value(parm0, 'OPTIONS_', parm_names[i])

	 ;- - - - - - - - - - - - - - - - - -
	 ; drop list
	 ;- - - - - - - - - - - - - - - - - -
	 if(keyword_set(option)) then $
	  begin
	   controls = append_array(controls, $
                         widget_droplist(parm_base, value=option, $
	                                            uvalue={name:parm_names[i]}))
	  end $
	 ;- - - - - - - - - - - - - - - - - -
	 ; text box
	 ;- - - - - - - - - - - - - - - - - -
	 else $
	  begin
	   controls = append_array(controls, $
                       widget_text(parm_base, scr_xsize=xsize, /editable, $
	                                           uvalue={name:parm_names[i]}))
	  end 

	end

   ;- - - - - - - - - - - - - - - - - -
   ; numeric type
   ;- - - - - - - - - - - - - - - - - -
    else: $
	begin
	 _base = widget_base(parm_base, /column)
	 label = append_array(parm_slider_labels, $
                               widget_label(_base, xsize=xsize, /align_center))
	 controls = append_array(controls, $
             widget_slider(_base, /suppress, /drag, xsize=xsize, $
                 uvalue={name:  parm_names[i], $
                	 label: label, $
                	 units: wprm_get_value(parm0, 'UNITS_', parm_names[i], def=1d), $
                	 range: wprm_get_value(parm0, 'RANGE_', parm_names[i])}))
	end
   endcase

  end

 button_base = widget_base(base, /row)

 continuous_base = widget_base(button_base, /nonexclusive)
 continuous_button = widget_button(continuous_base, value='CONTINUOUS')

 update_button = widget_button(button_base, value='UPDATE')


 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'widget_parm', base, /no_block


 ;--------------------------------------
 ; data structure
 ;--------------------------------------
 data = { $
	;---------------
	; widgets
	;---------------
		base			:	base, $
		controls		:	controls, $
		continuous_button	:	continuous_button, $
		update_button		:	update_button, $
		update_callback		:	update_callback, $
		callback_data		:	callback_data $
	}

 widget_control, base, set_uvalue=data

 wprm_parm_to_widget, data, parm


 return, base
end
;=============================================================================



