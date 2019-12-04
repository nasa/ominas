;=============================================================================
; x_wnum_to_widget
;
;=============================================================================
function x_wnum_to_widget, wnum
 nmax = 100000

 for id=0, nmax-1 do $
  if(widget_info(id, /valid_id)) then $
   if(widget_info(id, /type) EQ 4) then $ 
    begin 
     widget_control, id, get_value=value
     if(value EQ wnum) then return, id
    end

 return, 0
end
;=============================================================================
