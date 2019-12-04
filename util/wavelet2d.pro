;=============================================================================
; wavelet2d
;
;=============================================================================
function wavelet1d, _z, w0, l=l

 if(NOT keyword_set(w0)) then w0 = 2d*!dpi
 i = dcomplex(0,1)
 nn = 3d
 nn = sqrt(2d)

 size = size(_z)
 nx = size[1] & ny = size[2]
 z = dcomplex(double(_z), imaginary(_z))

 ;--------------------------------------------
 ; set up scales, translation
 ;--------------------------------------------
 l = dindgen(n)+1					; wavelengths to sample
l = l/15d
 s = l*w0/2d/!dpi##make_array(n, val=1d)		; convert to scales
 r = dindgen(n)#make_array(n, val=1d)
 



end
;=============================================================================
