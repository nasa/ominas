;=============================================================================
; set_union
; 
;  Duplicate elements allowed.
; 
;=============================================================================
function set_union, A, B, subscripts

 result = [A, B]

 h = histogram(result, rev=rr)
 w = where(h GT 0)

 subscripts = rr[rr[w]]
 return, result[subscripts]
end
;=============================================================================


