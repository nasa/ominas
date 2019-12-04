;======================================================================================
; ctcolor
;
;======================================================================================
function ctcolor, _color, shade

 color = _color
; type = size(color[0], /type)
; if(type NE 7) then color = ctlookup(color)

 nc = n_elements(color)
 nshade = n_elements(shade)

 if(nshade EQ 0) then shade = make_array(nc, val=1.)


 if(nc EQ 1) then return, call_function('ct'+color[0], shade)

 col = lonarr(nc)
 for i=0, nc-1 do col[i] = call_function('ct'+color[i], shade[i])
 return, col
end
;======================================================================================




;======================================================================================
; ctcolor
;
;======================================================================================
function ___ctcolor, color, shade
 nc = n_elements(color)
 if(NOT keyword_set(shade)) then shade = make_array(nc, val=1.)

 col = lonarr(nc)
 for i=0, nc-1 do col[i] = call_function('ct'+color[i], shade[i])
 return, col
end
;======================================================================================
