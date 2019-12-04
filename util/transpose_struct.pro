;=================================================================================
; transpose_struct
;
;=================================================================================
function transpose_struct, s, order

 dim = size(s, /dim)
 ndim = n_elements(dim)
 n = n_elements(s)

 ii = make_array(dim=dim, /long)
 ii[*] = lindgen(n)

 if(NOT keyword_set(order)) then ii = transpose(ii) $
 else ii = transpose(ii, order) 
 
 return, s[ii]
end
;=================================================================================
