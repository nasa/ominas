;=============================================================================
; image_gaussfit
;
;=============================================================================
function image_gaussfit, map, level=f, coeff=AA, sample=sample

 if(NOT keyword_set(f)) then f = 0.5d
 if(NOT keyword_set(sample)) then sample = 30


 ;---------------------------------
 ; fit 2d gaussian
 ;---------------------------------
 smap = gauss2dfit(map, AA, /tilt)
 A0 = AA[0]
 A1 = AA[1]
 a = AA[2]
 b = AA[3]
 h = AA[4]
 k = AA[5]
 T = AA[6]


 ;-----------------------------------
 ; sample fit guassian on fine grid
 ;-----------------------------------
 dim = size(map, /dim)*sample
 x = dindgen(dim[0])#make_array(dim[1],val=1)/sample
 y = dindgen(dim[1])##make_array(dim[0],val=1)/sample

 xx = (x-h)*cos(T) - (y-k)*sin(T)
 yy = (x-h)*sin(T) + (y-k)*cos(T)
 U = (xx/a)^2 + (yy/b)^2
 ssmap = A0 + A1*exp(-U/2d)


 ;-----------------------------------------------------------
 ; compute contour points at defined edge
 ;-----------------------------------------------------------
 mmap = rebin(map, dim[0], dim[1], /sample)
 mmap = shift(mmap, -sample/2, -sample/2)

 contour, ssmap, /overplot, level=A0 + A1*f, /path_double, path_xy=xy, /path_data
 nxy = n_elements(xy)/2
 im_pts = xy/sample

 return, im_pts
end
;=============================================================================
