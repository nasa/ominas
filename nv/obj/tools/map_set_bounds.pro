;==============================================================================
; map_set_bounds
;
;  bounds = [lat0,lat1, lon0, lon1]
;
;==============================================================================
pro map_set_bounds, md, bounds

 map_corners = [[bounds[0],bounds[2]], $
                [bounds[0],bounds[3]], $
                [bounds[1],bounds[2]], $
                [bounds[1],bounds[3]]]

 image_corners = map_map_to_image(md, map_corners, /nowrap)

; **incomplete**





end
;==============================================================================
