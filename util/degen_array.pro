;=============================================================================
; degen_array
;
;  Removes trailing elements of value 1.
;
;=============================================================================
function degen_array, array

 w = where(array EQ 1)
 if(w[0] EQ -1) then return, array

 ww = w - shift(w,1)
 www = max(where(ww NE 1))

 return, array[0:w[www]-1]
end
;=============================================================================
