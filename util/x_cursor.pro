;===================================================================================
; x_mouse__define
;
;===================================================================================
pro x_mouse__define

 struct = $
   {
    x		:	0l, $
    y		:	0l, $
    button	:	0l, $
    time	:	0l
   }

end
;===================================================================================



;===================================================================================
; x_cursor.pro
;
;  Like cursor, but works with a draw widget and sets the !x_mouse varable,
;  which gives the urrent state of the mouse, rather than the parameters of the
;  last change
;
;===================================================================================
pro x_cursor, x, y, wait, $
    nowait=nowait, wait=wait, $
    change=change, down=down, up=up, $
    data=data, device=device, normal=normal
common x_window_block, __wnums, __ids

 w = where(__wnums EQ !d.window)
 if(w[0] EQ -1) then message, 'Invalid window number.'
 draw = __ids[w]



end
;===================================================================================
