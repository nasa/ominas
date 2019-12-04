;===============================================================================
; cim_variance
;
;
;===============================================================================
function cim_variance, im0, im
 return, -(float(im0)-float(im))^2
end
;===============================================================================



;===============================================================================
; cim_ccorr
;
;
;===============================================================================
function cim_ccorr, im0, im
 return,  float(im0)*float(im)
end
;===============================================================================



;===============================================================================
; correlate_images
;
;
;===============================================================================
function correlate_images, _im0, _im, fn=fn, size=size

 if(NOT keyword_set(fn)) then fn = 'cim_ccorr'

 ;----------------------------------------------------
 ; normalize input images **** should normalize shifted im0's
 ;----------------------------------------------------
 im0 = (_im0 - mean(_im0)) / total(_im0)
 im = (_im - mean(_im)) / total(_im)

 ;----------------------------------------------------
 ; set up grid covering all offsets of im within im0
 ;----------------------------------------------------
 dim = size(im, /dim)
 dim0 = size(im0, /dim)
 nn0 = n_elements(im0)

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; dxy offset grid
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 dxy_dim = dim0 - dim
 dxy = gridgen(dxy_dim)
 ndxy = n_elements(dxy)/2
 dx = (dxy[0,*])[gen3z(dim[0], dim[1], ndxy)]
 dy = (dxy[1,*])[gen3z(dim[0], dim[1], ndxy)]

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; im pixel grid
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 imxy = gridgen(dim, /rec)
 imx = (reform(imxy[0,*,*]))[linegen3z(dim[0], dim[1], ndxy)]
 imy = (reform(imxy[1,*,*]))[linegen3z(dim[0], dim[1], ndxy)]

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; offset im grid into im0
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 x = imx + dx
 y = imy + dy
 xy = [transpose(x[*]), transpose(y[*])]

 w = reform(xy_to_w(dim0, xy), dim[0], dim[1], ndxy)
 im0_shift = im0[w]
 im_match = im[linegen3z(dim[0], dim[1], ndxy)]

 size = dim[0]*dim[1]*ndxy

 ;-----------------------------------------------
 ; compute correlation measure at each xy offset
 ;-----------------------------------------------
 gof = call_function(fn, im_match, im0_shift)
 gof = total(gof, 1)
 measure = reform(total(gof, 1), dxy_dim)

 return, measure
end
;===============================================================================
