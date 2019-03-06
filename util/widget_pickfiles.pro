;=============================================================================
; NOTE: Remove the second '+' on the following line for this file to be
;       included in the reference guide.
;++
; NAME:
;	xx
;
;
; PURPOSE:
;	xx
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = xx(xx, xx)
;	xx, xx, xx
;
;
; ARGUMENTS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; KEYWORDS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; ENVIRONMENT VARIABLES:
;	xx:	xx
;
;	xx:	xx
;
;
; RETURN:
;	xx
;
;
; COMMON BLOCKS:
;	xx:	xx
;
;	xx:	xx
;
;
; SIDE EFFECTS:
;	xx
;
;
; RESTRICTIONS:
;	xx
;
;
; PROCEDURE:
;	xx
;
;
; EXAMPLE:
;	xx
;
;
; STATUS:
;	xx
;
;
; SEE ALSO:
;	xx, xx, xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	xx, xx/xx/xxxx
;	
;-
;=============================================================================



;=============================================================================
; wpf_clean
;
;=============================================================================
function wpf_clean, path

 clean_path = path

 repeat $
  begin
   p = strpos(clean_path, '//')
   if(p NE -1) then clean_path = $
                strmid(clean_path, 0, p) + $
                           strmid(clean_path, p+1, strlen(clean_path)-p-1)
  endrep until(p EQ -1)


 return, clean_path
end
;=============================================================================



;=============================================================================
; wpf_get_dirs
;
;=============================================================================
pro wpf_get_dirs, data

 sep = path_sep()

 ;-------------------------------
 ; get directories
 ;-------------------------------
 dirs = file_search(data.path + '/*', /test_dir)
 dirs = str_flip(str_nnsplit(str_flip(dirs), sep))
 dirs = append_array('..', dirs) + sep 

 ;-------------------------------
 ; set list widget
 ;-------------------------------
  widget_control, data.dir_list, set_value=dirs
 *data.dirs_p = dirs


 ;-------------------------------
 ; set file widget
 ;-------------------------------
 widget_control, data.sel_list, get_value=file
 if(keyword_set(file[0])) then $
      widget_control, data.sel_list, set_value=dir_rep(file, data.path + sep)

end
;=============================================================================



;=============================================================================
; wpf_get_files
;
;=============================================================================
pro wpf_get_files, data


 sep = path_sep()
 
 ;-------------------------------
 ; get filter
 ;-------------------------------
 widget_control, data.filter_text, get_value=filter
 if(strmid(filter, strlen(filter)-1, 1) EQ sep) then filter = filter + '*'

 ;-------------------------------
 ; get files
 ;-------------------------------
 files = findfile(filter[0])

 w = where(strpos(files, sep) NE -1)
 if(w[0] NE -1) then files = files[w] $
 else files = ''


 w = where(strpos(files, ':') EQ -1)
 if(w[0] NE -1) then files = files[w] $
 else files = ''



 split_filename, files, dirs, names
 files = names


 ;-------------------------------
 ; set list widget
 ;-------------------------------
 widget_control, data.file_list, set_value=files
 *data.files_p = files

end
;=============================================================================



;=============================================================================
; wpf_filter_event
;
;=============================================================================
pro wpf_filter_event, event

 base = widget_info(event.top, find_by_uname='pickfiles_base')
 widget_control, base, get_uvalue=data

 widget_control, data.filter_text, get_value=filter
 split_filename, filter, dir, name

 data.path = wpf_clean(dir[0])
 widget_control, base, set_uvalue=data


 wpf_get_dirs, data
 wpf_get_files, data



end
;=============================================================================



;=============================================================================
; wpf_call_ok
;
;=============================================================================
pro wpf_call_ok, data

 if(NOT data.one) then files = *data.sel_p $
 else widget_control, data.sel_list, get_value=files

 if(data.one AND data.must_exist) then $
  begin
   if(NOT keyword__set(findfile(files[0]))) then $
    begin
     junk = dialog_message('File does not exist.', /error)
     return
    end
  end

 call_procedure, data.ok_callback, files, data.path
end
;=============================================================================



;=============================================================================
; wpf_sel_text_event
;
;=============================================================================
pro wpf_sel_text_event, event

 base = widget_info(event.top, find_by_uname='pickfiles_base')
 widget_control, base, get_uvalue=data

 widget_control, data.sel_list, get_value=file
 *data.sel_p = file

 wpf_call_ok, data
end
;=============================================================================



;=============================================================================
; wpf_sel_list_event
;
;=============================================================================
pro wpf_sel_list_event, event

 base = widget_info(event.top, find_by_uname='pickfiles_base')
 widget_control, base, get_uvalue=data


 ;----------------------------------
 ; get selected indices
 ;----------------------------------
 w = widget_info(data.sel_list, /list_select)
 if(w[0] EQ -1) then return

 files = rm_list_item(*data.sel_p, w, only='')

 ;----------------------------------
 ; set selections list
 ;----------------------------------
 widget_control, data.sel_list, set_value=files
 *data.sel_p = files

end
;=============================================================================



;=============================================================================
; wpf_file_list_event
;
;=============================================================================
pro wpf_file_list_event, event

 base = widget_info(event.top, find_by_uname='pickfiles_base')
 widget_control, base, get_uvalue=data

 ;------------------------------------
 ; double click is like 'OK'
 ;------------------------------------
 if(event.clicks EQ 2) then $
  begin
   wpf_call_ok, data
   return
  end


 ;----------------------------------
 ; get selected files
 ;----------------------------------
 w = widget_info(data.file_list, /list_select)
 files = ''
 if(w[0] NE -1) then files = data.path + path_sep() + (*data.files_p)[w]


 ;----------------------------------
 ; set selections list
 ;----------------------------------
 if(keyword_set(data.sel_list)) then $
                   widget_control, data.sel_list, set_value=files
 *data.sel_p = files

end
;=============================================================================



;=============================================================================
; wpf_dir_list_event
;
;=============================================================================
pro wpf_dir_list_event, event

 if(event.clicks EQ 1) then return

 base = widget_info(event.top, find_by_uname='pickfiles_base')
 widget_control, base, get_uvalue=data

 sep = path_sep()

 ;----------------------------------
 ; contruct new path
 ;----------------------------------
 dirs = *data.dirs_p
 dir = dirs[event.index]

 if(dir EQ './') then return
 if(dir EQ '../') then $
  begin
   s = strmid(data.path, 0, strlen(data.path)-1)
   split_filename, s, dd, nn
   data.path = dd
  end $
 else data.path = data.path + sep + dir

 data.path = wpf_clean(data.path)

 ;----------------------------------
 ; contruct new filter
 ;----------------------------------
 widget_control, data.filter_text, get_value=filter
 split_filename, filter, dir, spec
 filter = data.path + sep + spec
 widget_control, data.filter_text, set_value=filter

 ;----------------------------------
 ; update files and directories
 ;----------------------------------
 wpf_get_dirs, data
 wpf_get_files, data

 widget_control, base, set_uvalue=data
end
;=============================================================================



;=============================================================================
; wpf_cancel_event
;
;=============================================================================
pro wpf_cancel_event, event
 widget_control, event.top, /destroy
end
;=============================================================================



;=============================================================================
; wpf_button_event
;
;=============================================================================
pro wpf_button_event, event

 base = widget_info(event.top, find_by_uname='pickfiles_base')
 widget_control, base, get_uvalue=data

 widget_control, event.id, get_value=button

 case strupcase(button) of 
  'CANCEL'	: call_procedure, data.cancel_callback, event
  'OK' 		: wpf_call_ok, data
  else:
 endcase

end
;=============================================================================



;=============================================================================
; widget_pickfiles
;
;=============================================================================
function widget_pickfiles, parent, path=_path, one=one, filter=filter, $
        cancel_callback=cancel_callback, ok_callback=ok_callback, $
        must_exist=must_exist, button_base=button_base, default=_default, $
        ok_button=ok_button, nofile=nofile, filename=filename

 if(NOT keyword__set(cancel_callback)) then cancel_callback = 'wpf_cancel_event'
 if(NOT keyword__set(ok_callback)) then ok_callback = ''
 if(NOT keyword__set(_path)) then cd, current = _path
 if(NOT keyword__set(filter)) then filter = '*'

 sep = path_sep()

 if(keyword_set(_path)) then path = (file_search(_path, /fully_qualify_path))[0]
 if(keyword_set(_default)) then $
  begin
   default = _default
   if(keyword_set(must_exist)) then $
                default = (file_search(_default, /fully_qualify_path))[0]
  end

 if(NOT keyword_set(path)) then path = ''
 sel = path + sep
 if(keyword_set(default)) then sel = default

 one = keyword__set(one)
 must_exist = keyword__set(must_exist)

 multi = 1
 if(one) then $
  begin
   multi = 0
  end

 ;--------------------------------------
 ; widgets
 ;--------------------------------------
 base = widget_base(parent, /col, uname='pickfiles_base')

 filter_label = widget_label(base, value='Filter:', /align_left)
 filter_text = widget_text(base, ysize=1, $
                   value=path + sep + filter, /editable, $
                                             event_pro='wpf_filter_event')


 list_base = widget_base(base, /row)

 dir_base = widget_base(list_base, /col)
 dir_label = widget_label(dir_base, value='Directories:', /align_left)
 dir_list = widget_list(dir_base, xsize=35, ysize=10, $
                                             event_pro='wpf_dir_list_event')

 file_base = widget_base(list_base, /col)
 file_label = widget_label(file_base, value='Files:', /align_left)
 file_list = widget_list(file_base, xsize=35, ysize=10, multi=multi, $
                                             event_pro='wpf_file_list_event')
 if(keyword_set(nofile)) then widget_control, file_list, sensitive=0

 sel_list = 0

 sel_label = widget_label(base, value='File Name:', /align_left)
 if(one) then $
    sel_list = widget_text(base, ysize=1, /editable, $
                                          event_pro='wpf_sel_text_event') $
 else $
    sel_list = widget_text(base, ysize=5, /editable, $
                                          event_pro='wpf_sel_text_event')
; else $
;    sel_list = widget_list(base, ysize=5, multi=multi, $
;                                           event_pro='wpf_sel_list_event')




 button_base = widget_base(base, /row)
 ok_button = widget_button(button_base, value='OK', $
                                               event_pro='wpf_button_event')
 cancel_button = widget_button(button_base, value='Cancel', $
                                               event_pro='wpf_button_event')

 ;--------------------------------------
 ; data structure
 ;--------------------------------------
 data = { $
	;---------------
	; widgets
	;---------------
		base		:	base, $
		filter_text	:	filter_text, $
		dir_list	:	dir_list, $
		file_list	:	file_list, $
		sel_list	:	sel_list, $

	;---------------
	; callbacks
	;---------------
		cancel_callback	:	cancel_callback, $
		ok_callback	:	ok_callback, $

	;---------------
	; bookkeeping
	;---------------
		must_exist	:	must_exist, $
		one		:	one, $
		sel_p		:	nv_ptr_new(sel), $
		dirs_p		:	nv_ptr_new(0), $
		files_p		:	nv_ptr_new(0), $
		path		:	path $
	}

 widget_control, base, set_uvalue=data

 ;--------------------------------------
 ; initial directories
 ;--------------------------------------
 wpf_get_dirs, data
 wpf_get_files, data

 if(keyword_set(sel_list)) then widget_control, sel_list, set_value=sel



 return, base
end
;=============================================================================



