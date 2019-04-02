;=============================================================================
;+
; NAME:
;       image_interp_sinc
;
;
; PURPOSE:
;       Extracts a region from an image using nearest-neighbor interpolation.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = image_interp_sinc(image, grid_x, grid_y)
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
;	     k:		"Half-width" of the convolution window.  The
;			window actually covers the central pixel, plus
;			k pixels in each direction.  Default is 3, which
;			gives a 7x7 window.
;
;	fwhm:		If set, a gaussian with this half width is used for 
;			the psf instead of caling the user-supplied function.
;
;  OUTPUT:
;       NONE
;
;
; KEYORDS:
;  INPUT:
;	psf_fn:		Name of a function to compute the psf:
;
;				psf_fn(psf_data, x,y)
;
;			where x and y are the location relative to the 
;			center, and must accept arrays of any dimension.
;
;	psf_data:	Data for psf function as shown above.
;
;	mask:		Byte image indcating which pixels (value GT 0) should
;			be excluded from the interpolation.
;
;  OUTPUT:
;       NONE
;
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
function image_interp_nearest, image, grid_x, grid_y, mask=mask, zmask=zmask, valid=valid


 s = size(image)

 lgrid_x = long(grid_x)
 lgrid_y = long(grid_y)

 s = size(image)
 sub = lgrid_x + s[1]*lgrid_y

 return, image[sub]
end
;===========================================================================


