;===================================================================================
; x_mouse__define
;
;===================================================================================
pro x_mouse__define

 struct = $
   { $
    x		:	0l, $
    y		:	0l, $
    button	:	0l, $
    time	:	0l $
   }

end
;===================================================================================



;=============================================================================
; x_cursor_event
;
;=============================================================================
pro x_cursor_event, event

help, event
return

 base = event.top
 widget_control, base, get_uvalue=x_cursor_data 
 struct = tag_names(event, /struct)



end
;=============================================================================



;===================================================================================
; x_cursor.pro
;
;  Like cursor, but works with a draw widget and sets the !x_mouse varable,
;  which gives the urrent state of the mouse, rather than the parameters of the
;  last change
;
;  Not complete
;
;===================================================================================
pro x_cursor, x, y, _wait, $
    id=id, wnum=wnum, nowait=nowait, wait=wait, $
    change=change, down=down, up=up, $
    data=data, device=device, normal=normal
common x_window_block, __wnums, __ids

 if(NOT keyword_set(wnum)) then wnum = !d.window
 if(NOT keyword_set(id)) then id = x_wnum_to_widget(wnum)




 fn0 = widget_info(id, /event_pro)
 widget_control, id, event_pro='x_cursor_event'

 event = widget_event(id, /nowait)

stop



 widget_control, id, event_pro=fn0

end
;===================================================================================
