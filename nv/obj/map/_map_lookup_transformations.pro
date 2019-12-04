;===========================================================================
; _map_lookup_transformations
;
;
;===========================================================================
pro _map_lookup_transformations, _md, fn_map_to_image, fn_image_to_map

 n = n_elements(_md)
 fn_map_to_image = strarr(n)
 fn_image_to_map = strarr(n)


 for i=0, n-1 do $
  begin
   case _md[i].projection of
    'RECTANGULAR' : $
	begin
	 fn_map_to_image[i] = 'map_map_to_image_rectangular'
	 fn_image_to_map[i] = 'map_image_to_map_rectangular'
	end

    'EQUATORIAL_RING' : $
        begin
         fn_map_to_image[i] = 'map_map_to_image_equatorial_ring'
         fn_image_to_map[i] = 'map_image_to_map_equatorial_ring'
        end

    'RING' : $
        begin
         fn_map_to_image[i] = 'map_map_to_image_ring'
         fn_image_to_map[i] = 'map_image_to_map_ring'
        end

    'MERCATOR' : $
	begin
	 fn_map_to_image[i] = 'map_map_to_image_mercator'
	 fn_image_to_map[i] = 'map_image_to_map_mercator'
	end


    else: $
	begin
	 fn_map_to_image[i] = ''
	 fn_image_to_map[i] = ''
	end
   endcase
  end


end
;===========================================================================
