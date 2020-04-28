;=============================================================================
;+
; NAME:
;       gauss_2d
;
;
; PURPOSE:
;       Generates an array containing a 2-dimensional gaussian
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = gauss_2d(x0, y0, w, xsize, ysize)
;
;
; ARGUMENTS:
;  INPUT:
;          x0:  x position of center of gaussian
;
;          y0:  y position of center of gaussian
;
;           w:  half-width of gaussian; i.e., the distance at which the value
;		is 1/e times that at the peak.
;
;       xsize:  size of output array in x
;
;       ysize:  size of output array in y
;
;  OUTPUT:
;       NONE
;
;
; RETURN:
;       An array (xsize,ysize) containing a gaussian of width w centered
;       centered at position (x0,y0)
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
function gauss_2d, x0, y0, w, xsize, ysize

 xsub=findgen(xsize)#make_array(ysize,val=1)-fix(xsize/2)
 ysub=findgen(ysize)##make_array(xsize,val=1)-fix(ysize/2)

 return, exp(-((xsub-x0)^2+(ysub-y0)^2)/(w^2))
end
;===========================================================================
