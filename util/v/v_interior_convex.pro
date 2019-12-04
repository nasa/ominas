;=============================================================================
; v_interior_convex
;
;  Determines which unit vectors lie within a set of vertex unit vectors.
;
;=============================================================================
function v_interior_convex, v_vert, v

 nv = n_elements(v_vert)/3

 ;-----------------------------------------------
 ; project onto 2-D plane
 ;-----------------------------------------------
 p_vert = v_project(v_vert, M=M)

 v0 = transpose(total(v_vert,1)/nv) ## make_array(nv,val=1d)
 thetas = v_angle(v0, v_vert)
 threshold = cos(2*max(thetas))

 p = v_project(v, M=M, valid=ww, threshold=threshold)
 if(ww[0] EQ -1) then return, -1

 ;-----------------------------------------------
 ; evaluate 2-D vectors
 ;-----------------------------------------------
 w = p_interior_convex(p_vert, p[*,ww])
 if(w[0] EQ -1) then return, -1

 return, ww[w]
end
;=============================================================================
