;==============================================================================
; strip_idl_comments.pro
;
;==============================================================================
function strip_idl_comments, inlines

 lines = inlines

 p = strpos(inlines, ';')

 w = where(p EQ -1)
 if(w[0] NE -1) then lines[w] = inlines[w]

 w = where(p NE -1)
 if(w[0] NE -1) then lines[w] = str_nnsplit(inlines[w], ';')

 return, lines
end
;==============================================================================
