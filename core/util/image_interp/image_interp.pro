;=============================================================================
;+
; NAME:
;       image_interp
;
;
; PURPOSE:
;       Extracts a region from an image using the desired interpolation.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = image_interp(image, grid_x, grid_y)
;
;
; ARGUMENTS:
;  INPUT:
;        image:         An array of image point arrays.
;
;       grid_x:         The grid of x positions for interpolation
;
;       grid_y:         The grid of y positions for interpolation
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of interpolated points at the (grid_x, grid_y) points.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function image_interp, image, grid_x, grid_y, args, $
		poly=poly, $
		sinc=sinc, k=k, fwhm, $
		cubic=cubic, nearest=nearest, mean=mean, $
                psf_fn=psf_fn, psf_data=psf_data, maxk=maxk, mask=mask, zmask=zmask, valid=valid

 if(keyword_set(args)) then $
  begin
   tags = tag_names(args)
   if((where(tags EQ 'PSF_FN'))[0] NE -1) then psf_fn = args.psf_fn
   if((where(tags EQ 'PSF_DATA'))[0] NE -1) then psf_data = args.psf_data
   if((where(tags EQ 'K'))[0] NE -1) then k = args.k
   if((where(tags EQ 'FWHM'))[0] NE -1) then fwhm = args.fwhm
  end

 if(keyword_set(nearest)) then $
      return, image_interp_nearest(image, grid_x, grid_y, mask=mask, zmask=zmask, valid=valid)

 if(keyword_set(mean)) then $
      return, image_interp_mean(image, grid_x, grid_y, k, fwhm, mask=mask, zmask=zmask, valid=valid)

 if(keyword_set(cubic)) then $
      return, image_interp_cubic(image, grid_x, grid_y, k, fwhm, $
                                        psf_fn=psf_fn, psf_data=psf_data, mask=mask, zmask=zmask, valid=valid)

 if(keyword_set(sinc)) then $
      return, image_interp_sinc(image, grid_x, grid_y, k, fwhm, $
                                        psf_fn=psf_fn, psf_data=psf_data, kmax=maxk, mask=mask, zmask=zmask, valid=valid)

 return, image_interp_poly(image, grid_x, grid_y)
end
;===========================================================================
