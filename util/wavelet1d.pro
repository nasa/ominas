;=============================================================================
; wavelet1d
;
;=============================================================================
function wavelet1d, _x, w0, ll=ll, kk=kk, lmax=lmax, kmax=kmax, psi=psi, aspect=aspect, descale=descale

 n = n_elements(_x)

 lmin = 0d
 kmin = 0d

 if(NOT keyword_set(kmax)) then kmax = 0.25d
 if(NOT keyword_set(lmax)) then lmax = n/5d
 if(NOT keyword_set(aspect)) then aspect = 1d
 if(NOT keyword_set(w0)) then w0 = 2d*!dpi

 i = dcomplex(0,1)

 wns = !dpi		; half width of wavelet envelope (number of scales)
wns = 2.5d


 ns = n/aspect

 x = dcomplex(double(_x), imaginary(_x))

 ;--------------------------------------------
 ; set up scales, translation
 ;--------------------------------------------
 l = (dindgen(ns+1)/double(ns+1)*(lmax-lmin)+lmin)[1:ns] ; wavelengths(in samples) to sample
 s = l*w0/2d/!dpi ## make_array(n, val=1d)		 ; convert to scales
 r = dindgen(n) # make_array(ns, val=1d)


 ;--------------------------------------------
 ; set up morlet daughter wavelets
 ;--------------------------------------------
 r0 = (n-1)/2d
 psi = sqrt(s)*sqrt(sqrt(!dpi)) * exp(i*w0*(r-r0)/s - (r-r0)^2/2d/s^2)


 ;--------------------------------------------
 ; apply the transform
 ;--------------------------------------------
 result = complexarr(n,ns)
 for j=0, ns-1 do $
  begin
   ss = s[0,j]
   r1 = r0-wns*ss > 1
   r2 = r0+wns*ss < n-2 > (r1+1)
   kernel = psi[r1:r2,j]
   result[*,j] = convol(x, kernel, /center)
  end
 ll = l


 ;--------------------------------------------
 ; remap to k space if desired
 ;--------------------------------------------
 if(arg_present(kk)) then $
  begin
   kk = (dindgen(ns+1)/double(ns+1)*(kmax-kmin) + kmin)[1:ns]	; radians/sample
   ll = 2d*!dpi/kk

   i = lindgen(ns)
   ii = interpol(i, l, ll)

   xx = dindgen(n)#make_array(ns, val=1d)
   yy = ii##make_array(n, val=1d)

   result = image_interp(result, xx, yy)
  end


 return, result
end
;=============================================================================


pro test
 n=1024d
 yy = sin(dindgen(n)/n*2d*!dpi*100d) + $
      sin(dindgen(n)/n*2d*!dpi*17d)

 yy = sin(dindgen(n)/n*dindgen(n)) + sin(dindgen(n)/n*dindgen(n)*2d)

 hh = exp(dindgen(n)/n/0.4d)*2d*!dpi*1d
 yy = sin(hh)
 plot, yy

 ff = wavelet1d(yy, kk=k)
 pk = double(ff*conj(ff))			; power
 phik = atan(imag(ff),real(ff))			; phase

 tvim, alog10(pk)>1, z=0.5, /new
end



