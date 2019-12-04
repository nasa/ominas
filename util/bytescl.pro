;==================================================================================
; bytescl
;
;
;==================================================================================
function bytescl, x, top=top, max=max, min=min, double=double

 dim = size(x, /dim)

 if(NOT keyword_set(max)) then max = max(x)
 if(NOT keyword_set(min)) then min = 0
 if(NOT keyword_set(top)) then top = 255

 xrange = double(max - min)
 if(xrange EQ 0) then return, make_array(dim=dim)

 result = double((x - min))/xrange * top
 if(NOT keyword_set(double)) then esult = byte(result)

 w = where(x GT max)
 if(w[0] NE -1) then result[w] = top

 w = where(x LT min)
 if(w[0] NE -1) then result[w] = 0

 return, result
end
;==================================================================================
