;=============================================================================
;+
; NAME:
;	cam_psf_attrib
;
;
; PURPOSE:
;	Computes attributes of a point-spread function.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_psf_attrib, cd, <attribute keywords...>
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	 Camera descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: 
;	fwhm:	Full-width at half maximum of the point-spread function.
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro cam_psf_attrib, cd, fwhm=fwhm
@core.include
 zz = 10.

 psf = cam_psf(cd)
 if(NOT keyword_set(psf)) then return

 dim = size(psf, /dim)
 xgrid = (dindgen(dim[0]*zz)-0.5*(dim[0]*zz))/zz
 ygrid = (dindgen(dim[1]*zz)-0.5*(dim[1]*zz))/zz

 psf = cam_psf(cd, xgrid#make_array(dim[1]*zz,va=1d), $
                   ygrid##make_array(dim[0]*zz,va=1d))
 max = max(psf)
 hmax = 0.5d*max
 ww = where(psf GE hmax)

 xyzz = w_to_xy(dim*zz, ww)
 xyzz[0,*] = xyzz[0,*] - 0.5*(dim[0]*zz)
 xyzz[1,*] = xyzz[1,*] - 0.5*(dim[1]*zz)

 rzz2 = xyzz[0,*]^2 + xyzz[1,*]

 fwhm2zz = max(rzz2)
 fwhm = sqrt(fwhm2zz)/zz
end
;===========================================================================



;=============================================================================
pro __cam_psf_attrib, cd, fwhm=fwhm
@core.include
 zz = 10.

 psf = cam_psf(cd)
 if(NOT keyword_set(psf)) then return

stop
 n = n_elements(psf)
 psf = cam_psf(cd, (dindgen(n*zz)-0.5*(n*zz))/zz)

 max = max(psf)
 hmax = 0.5d*max
 ww = where(psf GE hmax)
 fwhm = (max(ww) - min(ww))/zz
end
;===========================================================================
