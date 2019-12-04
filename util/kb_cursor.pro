;==================================================================================
; kbc_event
;
;
;==================================================================================
pro kbc_event, event
stop


end
;==================================================================================



;==================================================================================
; kb_cursor
;
;  This routine is supposed to work like 'cursor' except that if you give it
; a draw widget, it will also return keyboard events.  I can't get it to
; work, though.
;
;==================================================================================
pro kb_cursor, x, y, wait, change=change, down=down, nowait=nowait, up=up, $
        wait=_wait, data=data, device=device, normal=normal, $
        x0=x0, y0=y0, draw=draw


 ;--------------------------------------------------------------------
 ; if no draw widget specified, then act like regular cursor routine
 ;--------------------------------------------------------------------
; if(NOT keyword_set(draw)) then $
  begin
   cursor, x, y, wait, change=change, down=down, nowait=nowait, up=up, $
        wait=_wait, data=data, device=device, normal=normal
   return
  end


 ;--------------------------------------------------------------------
 ; otherwise we'll use an event handler and enable the keyboard
 ;--------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - -
 ; save old draw widget settings
 ;- - - - - - - - - - - - - - - - - - -
 button_events = widget_info(draw, /draw_button_events)
 motion_events = widget_info(draw, /draw_motion_events)
 event_pro = widget_info(draw, /event_pro)

 ;- - - - - - - - - - - - - - - - - - -
 ; add the events and handler
 ;- - - - - - - - - - - - - - - - - - -
 widget_control, draw, /draw_button_events, /draw_motion_events, $
    event_pro='kbc_event'
 
 base = widget_info(draw,/ parent)
 text_base = widget_base(base, map=0)
 text = widget_text(text_base, /all_events)


 xmanager, 'kb_cursor', text_base, /modal
stop

return






 wait = 0
 if(keyword_set(change)) then wait = 2
 if(keyword_set(down)) then wait = 3
 if(keyword_set(nowait)) then wait = 0 
 if(keyword_set(up)) then wait = 4
 if(keyword_set(_wait)) then wait = _wait

 done = 0

 while(NOT done) do $
  begin
   bb = !mouse.button

   cursor, x, y, 0, data=data, device=device, normal=normal
   if(NOT keyword_set(xx)) then xx = x
   if(NOT keyword_set(yy)) then yy = y

   b = !mouse.button
stop

   c = get_kbrd(1)
   if(keyword_set(c)) then $
    begin
stop

    end

   case wait of
	0 : return	
	1 : if(b NE 0) then return
	2 : if(b NE bb) then return
	3 : if(b GT bb) then return
	4 : if(b LT bb) then return
   endcase



  end
end
;==================================================================================
