;===========================================================================
; tvplot
;
;
;===========================================================================
pro tvplot, image, xrange=xrange, yrange=yrange, color=color, _ref_extra=ex 

 dim = size(image, /dim)

 if(NOT keyword_set(xrange)) then xrange = [0,dim[0]-1]
 if(NOT keyword_set(yrange)) then yrange = [0,dim[1]-1]

 plot, [0], [0], /nodata, xrange=xrange, yrange=yrange, xst=1, yst=1, _extra=ex

 corners = [tr(xrange), tr(yrange)]
 device_corners = data_to_device(corners)
 device_xsize = double(device_corners[0,1] - device_corners[0,0])
 device_ysize = double(device_corners[1,1] - device_corners[1,0])

 device_size = device_corners[*,1] - device_corners[*,0]

 gridx = (dindgen(device_xsize)/device_xsize*(device_size[0]) + device_corners[0,0]) # $
           make_array(device_ysize, val=1d) 
 gridy = (dindgen(device_ysize)/device_ysize*(device_size[1]) + device_corners[1,0]) ## $
           make_array(device_xsize, val=1d) 

 gridxy = [reform(gridx, 1,n_elements(gridx)), reform(gridy, 1,n_elements(gridy))]

 gridxy = device_to_data(gridxy)

 _image = image_interp(image, gridxy[0,*], gridxy[1,*])
 _image = reform(_image, device_size[0], device_size[1])

  tvscl, _image, device_corners[0,0], device_corners[1,0]
  plot, /noerase, _extra=ex, $
     [0], [0], /nodata, xrange=xrange, yrange=yrange, xst=1, yst=1

end
;===========================================================================
