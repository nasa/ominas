;=============================================================================
; _map_valid_points_stereographic
;
;=============================================================================
function _map_valid_points_stereographic, _md, map_pts, image_pts

 nt = n_elements(_md)
 sv = size(image_pts)
 nv = 1
 if(sv[0] GT 1) then nv = sv[2]

 valid = lindgen(nv*nt)

 return, valid
end
;=============================================================================
