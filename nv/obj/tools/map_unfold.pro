;=============================================================================
; map_unfold
;
;=============================================================================
function map_unfold, md0, map0, md=md

 size0 = map_size(md0)
 size = 3*size0
 
 map = make_array(size, type=size(map0, /type))

 md = nv_clone(md0)
 map_set_size, md, size
 map_set_origin, md, map_origin(md0) + size0
 map_set_scale, md, map_scale(md0)/3d

 return, map
end
;=============================================================================
