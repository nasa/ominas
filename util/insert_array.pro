;==============================================================================
; insert_array
;
;
;==============================================================================
function insert_array, dim, insert, offset

 idim = size(insert, /dim)
 itype = size(insert, /type)

 result = make_array(dim, type=itype)

 result[offset[0]:offset[0]+idim[0]-1, offset[1]:offset[1]+idim[1]-1] = insert

 return, result
end
;==============================================================================

