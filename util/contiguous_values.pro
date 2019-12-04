;===================================================================================
; contiguous_values
;
;===================================================================================
function contiguous_values, array, val

 w = where(array EQ val)
 if(w[0] EQ -1) then return, -1

 ww = where((array[w] EQ array[w+1]) AND (array[w] EQ array[w-1]))
 www = w[ww]

 return, www
end
;===================================================================================
