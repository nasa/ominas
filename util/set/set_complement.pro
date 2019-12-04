;=============================================================================
; set_complement
; 
;  Duplicate elements allowed, A.
; 
;=============================================================================
function set_complement, _A, U, subscripts

 ;--------------------------------------------------
 ; consider only elements of _A in U
 ;--------------------------------------------------
 A = set_intersection(_A, U)

 ;--------------------------------------------------
 ; determine range
 ;--------------------------------------------------
 U_min = min(U) & U_max = max(U)

 ;--------------------------------------------------
 ; find the complement
 ;--------------------------------------------------
 hA = histogram(A, min=U_min, max=U_max, rev=rrA)
 hU = histogram(U, min=U_min, max=U_max, rev=rrU)

 w = where((hA EQ 0) OR (hU EQ 0))
 if(w[0] EQ -1) then return, -1

 subscripts = rrU[rrU[w]]
 return, U[subscripts]
end
;=============================================================================


