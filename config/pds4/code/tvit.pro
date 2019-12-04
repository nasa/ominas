PRO TVIT,img,zero,stretchv,zoomf=zoomf
;-----------------------------------------------------------------
;
;+
; NAME:
;	TVIT
;
; PURPOSE:
;	Send a scaled, zoomed/compressed 2-d array to the graphics window
;	It resizes the image to fit the window size and rescales the image
;	with a new zero point.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	TVIT, img, zero, stretchv[, zoomf=zoomf]
;
; INPUTS:
;	img - a 2-d image array
;
;	zero - value in image to be displayed at minimum in color table.
;
;	stretchv - the difference in value between maximum and minimum.
;
; KEYWORDS:
;	zoomf - output of the zoomfactor that is applied to get the array to fit the window.
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [11/1/12]
;
;-
;-----------------------------------------------------------------

IF (N_PARAMS() lt 3) THEN BEGIN
	PRINT,' Usage: TV1,img,zero, stretch'
	PRINT, ' Displays img with zero and stretch within optional box'
	RETURN
ENDIF
xwinsize = !d.x_size
ywinsize = !d.y_size
zmax = zero + stretchv
tvimg = byte(0 > ((img-zero)*(255./stretchv)) < 255 ) 
sz = size(tvimg)
nx = sz(1)
ny = sz(2)
originx = 0
originy = 0
zoomf = 1
nlong = nx > ny
IF (nlong GT xwinsize) THEN BEGIN
	zoomf = xwinsize/float(nlong)
	tvimg = congrid(tvimg,nx*zoomf,ny*zoomf)
	zoomf = float(xwinsize)/nlong
ENDIF 
IF (nlong LE xwinsize/2) THEN BEGIN
	zoomf = xwinsize/nlong
	tvimg = congrid(tvimg,nx*zoomf,ny*zoomf)
ENDIF 
ERASE
TV,tvimg 
END
