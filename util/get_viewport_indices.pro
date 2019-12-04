;==================================================================================
; get_viewport_indices
;
;
;==================================================================================
function get_viewport_indices, dim, p=data_xy, $
                    device_indices=iii, device_size=device_size, $
                    xrange=xrange, yrange=yrange, noclip=noclip


 ;----------------------------------------------------------------------
 ; if data ranges given, set up a 1:1 output grid covering only the 
 ; given range
 ;----------------------------------------------------------------------
 if(keyword_set(xrange)) then $
  begin
   data_size = [xrange[1]-xrange[0]+1, yrange[1]-yrange[0]+1]
   data_xy = gridgen(data_size, p0=[xrange[0],yrange[0]], /double)
   ndata = n_elements(data_xy)/2

   ii = xy_to_w(dim, data_xy)
   device_size = data_size
   iii = lindgen(ndata)

   return, ii
  end


 ;----------------------------------------------------------------------
 ; otherwise construct the output grid over the current viewing area
 ;----------------------------------------------------------------------
 device_size = [!d.x_size,!d.y_size]
 device_xy = gridgen(device_size)

 data_xy = (convert_coord(device_xy, /device, /to_data, /double))[0:1,*]
 data_xy_test = round(data_xy)
 n = n_elements(data_xy)/2

 ii = xy_to_w(dim, data_xy_test)
 iii = xy_to_w(device_size, device_xy)

 if(NOT keyword_set(noclip)) then $
  begin
   w = where( (data_xy_test[0,*] GE 0) AND (data_xy_test[0,*] LT dim[0]) AND $
              (data_xy_test[1,*] GE 0) AND (data_xy_test[1,*] LT dim[1]) )
   if(w[0] EQ -1) then return, -1

   ii = ii[w]
   iii = iii[w]
   data_xy = data_xy[*,w]
  end

 return, ii
end
;==================================================================================



