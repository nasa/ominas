;============================================================================
; smooth_on_curve
;
;============================================================================
function smooth_on_curve, cd, image, p, width

 dim = size(image, /dim)

 ;- - - - - - - - - - - - - - -
 ; create mask about curve
 ;- - - - - - - - - - - - - - -
 mask = bytarr(dim)
 mask[p[0,*], p[1,*]] = 255 

 mask = smooth(mask, width) < 1
 sub = where(mask NE 0)


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - 
 ; use psf to smooth entire image; very inefficient
 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 n = 5
 xx = dindgen(n)#make_array(n,val=1d) - n/2 - 1
 yy = transpose(xx)

 psf = cam_psf(cd, xx, yy)

 sim = convol(image, psf)


 ;- - - - - - - - - - - - - - - - - - -
 ; insert smoothed points into image
 ;- - - - - - - - - - - - - - - - - - -
 image[sub] = sim[sub]


 return, image
end
;============================================================================




;============================================================================
; smooth_on_curve
;
;============================================================================
function _smooth_on_curve, image, p, width
stop

 icv_compute_directions, p, cos_alpha=cos_alpha, sin_alpha=sin_alpha
 strip = icv_strip_curve(0, image, p, 50, 50, cos_alpha, sin_alpha, $
                                               grid_x=grid_x, grid_y=grid_y)


 kx = 11
 ky = 5

 xx = dindgen(kx)#make_array(ky,val=1d)
 yy = dindgen(ky)##make_array(kx,val=1d)

 kernel = gauss2d(xx, yy, 1.3d, 0.1d, /norm)

; kernel = make_array(1,nk, val=1d)
 s = convol(strip, kernel)

 image[grid_x, grid_y] = s

 return, image
end
;============================================================================

