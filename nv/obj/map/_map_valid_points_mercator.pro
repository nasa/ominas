;=============================================================================
; _map_valid_points_mercator
;
;=============================================================================
function _map_valid_points_mercator, _md, map_pts, image_pts

 nt = n_elements(_md)
 sv = size(image_pts)
 nv = 1
 if(sv[0] GT 1) then nv = sv[2]

 ii = transpose(linegen3z(2,nt,nv), [0,2,1])
 size = double((_md.size)[ii])


 valid = where(image_pts[0,*,*] GE 0 AND image_pts[0,*,*] LE size[0,*,*]-1 AND $
                 image_pts[1,*,*] GE 0 AND image_pts[1,*,*] LE size[1,*,*]-1)

 return, valid
end
;=============================================================================
