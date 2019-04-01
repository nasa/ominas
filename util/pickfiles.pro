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
; pf_ok_callback
;
;=============================================================================
pro pf_ok_callback, _files, _path
common pickfiles_block, files, base, out_path, options_dl, options_i
 if(keyword__set(_files)) then files = _files
 if(keyword__set(_path)) then out_path = _path

 if(keyword_set(options_dl)) then $
                 options_i = widget_info(options_dl, /droplist_select)

 widget_control, base, /destroy
end
;=============================================================================



;=============================================================================
; pickfiles_event
;
;=============================================================================
pro pickfiles_event, event
end
;=============================================================================



;=============================================================================
; pickfiles
;
;=============================================================================
function pickfiles, get_path=get_path, path=path, title=title, one=one, $
    filter=filter, must_exist=must_exist, button_base=button_base, $
    options=options, selected_option=selected_option, default=default, $
    filename=filename, nofile=nofile
common pickfiles_block, files, base, out_path, options_dl, options_i

 files = ''

 base = widget_base(title=title,/column)

 pf_base = widget_base(base)
 pf = widget_pickfiles(pf_base, ok_callback='pf_ok_callback', path=path, $
                       one=one, filter=filter, must_exist=must_exist, $
                       button_base=button_base, default=default, ok_button=ok_button, $
                       filename=filename)

 if(keyword_set(options)) then $
  begin
   options_base = widget_base(button_base, /row)
   options_dl = widget_droplist(options_base, value=options[1:*], title=options[0])
  end

 widget_control, /realize, base
 widget_control, ok_button, /input_focus
 xmanager, 'pickfiles', base

 if(keyword__set(out_path)) then get_path = out_path

 if(defined(options_i) AND keyword_set(options)) then $
                                      selected_option = options[options_i+1] 

 options_dl = 0

 return, str_cull(files)
end
;=============================================================================
