;=================================================================================
; star_psf_gaussian
;
;=================================================================================
function star_psf_gaussian, image, p, width


 np = n_elements(p)/2

 psfs = dblarr(width,width,np)

 for i=0, np-1 do $
  begin 
   sub = subimage(image, p[0,i], p[1,i], width, width)
;   psf = gauss2d_fit(sub, coeff, /tilt)
   psf = gauss2dfit(sub, coeff, /tilt)

   xy = gridgen([width, width], /center, /double, /rec)
   psfs[*,*,i] = gauss2d(xy[0,*,*], xy[1,*,*], coeff[2], coeff[3], coeff[6])

   psfs[*,*,i] = psfs[*,*,i]/total(psfs[*,*,i])
  end


 return, total(psfs,3)/np
end
;=================================================================================
