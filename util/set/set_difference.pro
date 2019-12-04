;=============================================================================
; set_difference
;
;  No duplicate elements allowed in A or B.
; 
;=============================================================================
function set_difference, A, B, subscripts

 result = [A, B]

 h = histogram(result, rev=rr)
 w = where(h EQ 1)
 if(w[0] EQ -1) then return, -1

 subscripts = rr[rr[w]]
 return, result[subscripts]
end
;=============================================================================
