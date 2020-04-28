;===========================================================================
;+
; NAME:
;       edge_model_psf_ring
;
;
; PURPOSE:
;	Returns an edge model produced by convolving a sharp edge with
;	a point-spread function.
;
; CATEGORY:
;       NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;       result = edge_model_psf_ring()
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	 zero:  The array element corresponding to the phyiscal edge.
;
;	delta:	The number of pixels represented by each element
;		Currently = 1.0
;
;	cd:	Camera descriptor fromwhich to obtain the PSF.
;
;
; RETURN:
;	An array containing the model.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 6/1998
;
;-
;===========================================================================
function edge_model_psf_ring, cd=cd, zero=zero, delta=delta

 ;-------------------------------------
 ; model parameters
 ;-------------------------------------
 eps = 0.000001

 nn = 15.
 delta0 = 0.25
 n = nn/delta0

 ;-------------------------------------
 ; get the 1-D camera psf
 ;-------------------------------------
 x = (dindgen(n) - n/2.) * delta0
 psf = cam_psf(cd, x)

 ;-------------------------------------
 ; crop the psf
 ;-------------------------------------
; w = where(psf GE eps*max(psf))
; w0 = min(w) & w1 = max(w)
; x = x[w0:w1]
; psf = psf[w0:w1]
; n = n_elements(x) + 2/delta0
; nn = fix(delta0*n)

 ;---------------------------------------------------
 ; make sharp-edge model and convolve with psf
 ;---------------------------------------------------
 model = dblarr(2*n)
 model[0:n] = 1d
 model = convol(model, psf, /center)
 model = model[0.5*n+1:1.5*n]

 ;-----------------------------------------------------------------------
 ; interpolate to one-pixel grid, zero is the half-power point
 ;-----------------------------------------------------------------------
 mm = abs(model - 0.5*(max(model)-min(model)))
 xx = (peak_interp(dindgen(n), -mm, min=min))[0]

 model = interpolate(model, dindgen(nn)/delta0)
 zero = xx*delta0
 delta = 1.0
;stop

 return, model
end
;============================================================================

