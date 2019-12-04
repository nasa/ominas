;===========================================================================
; pad_array
;
;===========================================================================
function pad_array, array, n, pad=pad

 nn = n_elements(array)
 if(n LE nn) then return, array[0:n-1]

 type = size(array, /type)
 if(NOT keyword_set(pad)) then $
  begin
   pad = 0
   if(type EQ 7) then pad = '' $
   else if (type EQ 10) then pad = nv_ptr_new()
  end 

 new_array = make_array(n, val=pad)
 new_array[0:nn-1] = array

 return, new_array
end
;===========================================================================
