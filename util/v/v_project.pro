;=============================================================================
; v_project
;
;  Projects 3D unit vectors onto a 2D plane.
;
;=============================================================================
function v_project, v, M=M, valid=valid, threshold=threshold

 if(NOT keyword_set(threshold)) then threshold = 0

 ;-----------------------------------------------
 ; build rotation matrix
 ;-----------------------------------------------
 if(NOT keyword_set(M)) then $
  begin
   n = n_elements(v)/3
   v0 = v_unit(v_mean(v))

   v00 = v0##make_array(n, val=1d)
 
   max = max(v_inner(v00, v), w)
   v2 = v_unit(v_cross(v0, v[w,*]))
   v1 = v_unit(v_cross(v2, v0))

   M = transpose([v0,v1,v2])
  end
 
 ;-----------------------------------------------
 ; project
 ;-----------------------------------------------
 vv = M##v

 if(arg_present(valid)) then valid = where(vv[*,0] GT threshold)
 return, transpose(vv[*,1:2])
end
;=============================================================================

