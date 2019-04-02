;===========================================================================
; textedit_event
;
;===========================================================================
pro textedit_event, event


 ;-----------------------------------------------------
 ; base resize event
 ;-----------------------------------------------------
 if(tag_names(event, /str) EQ 'WIDGET_BASE') then $
  begin
   txt = widget_info(event.id, /child)
   widget_control, txt, scr_xsize=event.x, scr_ysize=event.y
   return
  end


 ;-----------------------------------------------------
 ; callback
 ;-----------------------------------------------------
 widget_control, event.id, get_uvalue = struct
 if(NOT keyword_set(struct)) then return
 call_procedure, struct.callback, event.id, struct.data

end
;===========================================================================



;===========================================================================
; textedit
;
;===========================================================================
function textedit, text, xsize=xsize, ysize=ysize, base=base, $
   resource_prefix=resource_prefix, title=title, $
   callback=callback, data=data

 if(NOT keyword_set(title)) then title = ''
 if(NOT keyword__set(xsize)) then xsize = 80
 if(NOT keyword__set(ysize)) then ysize = 25

 editable = keyword_set(callback)

 ;------------------------------
 ; widgets
 ;------------------------------
 base = widget_base(/tlb_size_events, $
                         resource_name=resource_prefix + '_base', title=title)
 txt = widget_text(base, xsize=xsize, ysize=ysize, $
                    /scroll, /wrap, /all_events, editable=editable, $
                         resource_name=resource_prefix + '_text')

 widget_control, txt, set_value=text
 if(keyword_set(callback)) then $
        widget_control, txt, set_uvalue = {callback:callback, data:data}

; if(editable) then $
;  begin
;   button_base = widget_base(base, /row)
;   commit_button = widget_button(button_base, value='Commit')
;  end

 widget_control, base, /realize
 xmanager, 'textedit', base, /no_block

 return, txt
end
;===========================================================================
