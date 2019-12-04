;=============================================================================
;+
; NAME:
;	image_offset
;
;
; PURPOSE:
;	Searches for the offset (dx,dy) that best locates an image within a 
;	a reference image.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	dxy = image_offset(im0, im)
;
;
; ARGUMENTS:
;  INPUT:
;	im0:		Reference image.
;
;	im:		Test image, must be smaller than im0. 
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	2-element array giving the fit offset as [dx,dy].
;
;
; PROCEDURE:
;	This routine considers every possble image offset by iterating over 
;	various correlation scales.
;
;
; STATUS:
;	Some bugs.
;
;
;
; SEE ALSO:
;	pg_farfit
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2017
;	
;-
;=============================================================================



;===============================================================================
; ioff_peak
;
;===============================================================================
function __ioff_peak, corr, grid
 grid = reform(grid, 2, n_elements(grid)/2)
 w = where(corr EQ max(corr))
 return, grid[*,w]
end
;===============================================================================



;===============================================================================
; ioff_peak
;
;===============================================================================
function ioff_peak, corr, grid
width = 10
sample = 10 

 dim0 = size(corr, /dim) 
 dim = dim0 < width
 dim_2 = dim/2

 nn = width*sample
 gridx = reform(grid[0,*,*])
 gridy = reform(grid[1,*,*])

 gridx_interp = congrid(double(gridx), nn, nn, /interp)
 gridy_interp = congrid(double(gridy), nn, nn, /interp)
 corr_interp = smooth(congrid(corr, nn, nn, /interp), width)

 ii = lindgen(nn,nn)
 ii = ii[width:nn-width-1, width:nn-width-1]
 gridx_interp = gridx_interp[ii]
 gridy_interp = gridy_interp[ii]
 corr_interp = corr_interp[ii]
;stop
;tvscl, congrid(corr,100,100), /order
;tvscl, congrid(corr_interp,100,100), /order

 w = where(corr_interp EQ max(corr_interp))
 xy = [gridx_interp[w[0]], gridy_interp[w[0]]]
;w = where(corr EQ max(corr))
;xy = [gridx[w[0]], gridy[w[0]]]
;image_centroid(corr)

 return, xy
end
;===============================================================================



;===============================================================================
; ioff_variance
;
;
;===============================================================================
function ioff_variance, im0, im
 return, -(float(im0)-float(im))^2
end
;===============================================================================



;===============================================================================
; ioff_ccorr
;
;
;===============================================================================
function ioff_ccorr, im0, im
 return,  float(im0)*float(im)
end
;===============================================================================



;===============================================================================
; ioff_correlate
;
;
;===============================================================================
function ioff_correlate, im0, im, mask, _grid, dxy=dxy

 if(NOT keyword_set(dxy)) then dxy = [0,0]
 dxy = round(dxy)

 grid_dim = (size(_grid, /dim))[1:2]
 ngrid = n_elements(_grid)/2
 grid = reform(_grid, 2, ngrid)

 dxy = dxy#make_array(ngrid,val=1d)

 dim = size(im, /dim)
 dim0 = size(im0, /dim)
 nn0 = n_elements(im0)

 ;----------------------------------------------------
 ; set up array for all possible shifts
 ;----------------------------------------------------
 ii = linegen3z(dim0[0], dim0[1], ngrid)
 im0_match = im0[ii]

 w = xy_to_w(dim0, grid + dxy)
 ww = where(w LT 0)
 if(ww[0] NE -1) then w[ww] = w[ww] + nn0

 jj = w##make_array(dim0[0],val=1l)
 jj = jj[linegen3y(dim0[0], dim0[1], ngrid)]

 iii = (ii+jj) mod nn0

 mask_shift = mask[iii]
 ii = (jj = (iii = 0))


 ;----------------------------------------------------
 ; mask to im 
 ;----------------------------------------------------
 w = where(mask_shift EQ 1)
 im0_match = reform(im0_match[w], dim[0], dim[1], ngrid)


 ;-----------------------------------------------
 ; compute goodness of fit measure
 ;-----------------------------------------------
 gof = ioff_variance(im0_match, im)
; gof = ioff_ccorr(im0_match, im)
 gof = total(gof, 1)
 measure = reform(total(gof, 1), grid_dim)

tvscl, congrid(measure,100,100), /order
 return, measure
end
;===============================================================================



;===============================================================================
; image_offset
;
;
;===============================================================================
function image_offset, _im0, _im
xbin0 = 100
reduction_factor = 2

 ;-------------------------------------------------------------------
 ; normalize images
 ;-------------------------------------------------------------------
 dim0 = size(_im0, /dim)
 dim = size(_im, /dim)
 
 mean0 = mean(_im0)
 mean = mean(_im)

 im0 = bytscl((_im0-mean0)); / sqrt(total((_im0-mean0)^2))
 im = bytscl((_im-mean)); / sqrt(total((_im-mean)^2))

 im0 = im0/stddev(im0)
 im = im/stddev(im)

 ;-------------------------------------------------------------------
 ; construct mask
 ;-------------------------------------------------------------------
 mask = bytarr(dim0)
 ddim = dim0 - dim
 ddim_2 = ddim/2
 mask[ddim_2[0]:ddim_2[0]+dim[0]-1, ddim_2[1]:ddim_2[1]+dim[1]-1] = 1
stop

 ;-------------------------------------------------------------------
 ; iterate over correlation scales
 ;-------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - -
 ; initial binning
 ;- - - - - - - - - - - - - - - - - - - - - -
 scale = (double(dim0[0])/double(xbin0))[0] 

 bin_dim0 = dim0/scale
 bin_dim = dim/scale
 grid_dim = (dim0-dim)/scale


 ;- - - - - - - - - - - - - - - - - - - - - -
 ; iterate up to full resolution
 ;- - - - - - - - - - - - - - - - - - - - - -
 dxy = [0,0]
 repeat $
  begin
   ;- - - - - - - - - - - - - - - - - - - - -
   ; contruct correlation grid
   ;- - - - - - - - - - - - - - - - - - - - -
   ngrid = prod(grid_dim)
   grid = gridgen(grid_dim, /rec, p0=-grid_dim/2)
; grid is still screwed up
; print, grid[0,*,0]

   ;- - - - - - - - - - - - - - - - - - - - -
   ; bin images
   ;- - - - - - - - - - - - - - - - - - - - -
   im0_corr = congrid(im0, bin_dim0[0], bin_dim0[1])
   im_corr = congrid(im, bin_dim[0], bin_dim[1])
   mask_corr = congrid(mask, bin_dim0[0], bin_dim0[1])

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; correlate images, centering the search grid at the current dxy solution
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   corr = ioff_correlate(im0_corr, im_corr, mask_corr, grid, dxy=dxy/scale)

   ;- - - - - - - - - - - - - - - - - - - - -  
   ; find correlation peak
   ;- - - - - - - - - - - - - - - - - - - - -
   dxy = dxy + scale*ioff_peak(corr, grid)

   ;- - - - - - - - - - - - - - - - - - - - -
   ; adjust correlation grid and binning
   ;- - - - - - - - - - - - - - - - - - - - -
   scale = scale / reduction_factor
   grid_dim = grid_dim / scale*.3 > 5
   bin_dim0 = bin_dim0 * reduction_factor < dim0
   bin_dim = bin_dim * reduction_factor < dim

  endrep until(scale LE 1)


 return, dxy
end
;===============================================================================




pro test

 grift, dd=dd, cd=cd, pd=pd, rd=rd, ltd=ltd
 dxy = pg_renderfit(dd, cd=cd, ltd=ltd, bx=[pd,rd], /show)
 pg_repoint, cd=cd, dxy

end




