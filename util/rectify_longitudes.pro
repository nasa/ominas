;=================================================================================
; rectify_longitudes
;
;=================================================================================
pro rectify_longitudes, lonmin, lonmax

 if((lonmin - (lonmax-2d*!dpi)) LT (lonmax-lonmin)) then $
  begin
   swap, lonmin, lonmax
   lonmin = lonmin - (2d*!dpi)
  end

end
;=================================================================================
