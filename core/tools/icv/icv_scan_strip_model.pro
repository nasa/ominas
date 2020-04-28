;=============================================================================
;+
; NAME:
;	icv_scan_strip_model
;
;
; PURPOSE:
;	At each point along an image strip, determines the subpixel offset at
;	which the correlation coefficient between a specified model and the
;	image is maximum.
;
;
; CATEGORY:
;	NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;	result = icv_scan_strip_model(strip, model, szero, mzero)
;
;
; ARGUMENTS:
;  INPUT:
;	strip:	Image strip (n_points,ns) to be scanned.  Output from
;		icv_strip_curve ns must be even.
;
;	model:	Model (n_points,nm) to correlate with strip at each point 
;		on the curve.  Must have nm < ns.
;
;	szero:	Zero-offset position in the strip.
;
;	mzero:	Zero-offset position in the model.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	cc:	Maximum correlation coefficient at each point on the curve.
;
;	sigma:	Offset uncertainty for each point on the curve, computed as
;		one half of the half-width of the correlation peak. 
;
;
; RETURN:
;	Offset of best correlation at each point on the curve.
;
;
; PROCEDURE:
;	At every point on the curve, a correlation coefficient is computed
;	for every offset at which the model completely overlays the strip.
;	In other words, the model is swept across the strip.
;
;	At each point, Lagrange interpolation is used on the three correlations
;	surrounding the correlation peak to find the subpixel offset of maximum
;	correlation.
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function icv_scan_strip_model, strip, model, szero, mzero, arg=arg, cc=cc, $
               sigma=sigma, center=center

 ;-----------------
 ; get sizes
 ;-----------------
 s = size(strip)
 n = s[1]
 ns = s[2]
 half_ns = ns/2

 s = size(model)
 nm = s[2]

 nn = ns-nm

 ;----------------------------------
 ; compute correlation coefficients
 ;----------------------------------
 sbar = total(strip,2)/ns
 sa = strip - sbar#make_array(ns,val=1)

 mbar = total(model,2)/nm
 ma = model - mbar#make_array(nm,val=1)

 norm = sqrt(total(sa^2,2)*total(ma^2,2))

 flat_sub = where(norm EQ 0)
 if(flat_sub[0] NE -1) then norm[flat_sub] = 1.0

 cc_all = dblarr(n,ns-nm)
; for i=0, nn-1 do cc_all[*,i] = total(ma*sa[*,i:i+nm], 2)/norm
 for i=0, nn-1 do cc_all[*,i] = total(ma*sa[*,i:i+nm-1], 2)/norm



 ;-----------------------------------------------------------------
 ; Find indices of max correlation and extract 3 pixels about peak.
 ; Also, find half widths of correlation peaks.
 ;-----------------------------------------------------------------
 scan_indices = dblarr(n,/nozero)
 sigma = dblarr(n)

 cc_peak = dblarr(n,3)
 for i=0, n-1 do $
  begin
   scan_indices[i] = (where(cc_all[i,*] EQ max(cc_all[i,*])))[0]
   if((scan_indices[i] GT 0) AND (scan_indices[i] LT nn)) then $
    begin
     cc_peak[i,*] = cc_all[i, scan_indices[i]+indgen(3)-1]

     w = where(cc_all[i,*] GT cc_peak[i,1]/2.)
     nw = n_elements(w)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; if there are multiple peaks, then this scan offset is meaningless
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     bad = 0
     if(nw LT 5) then bad = 1
     if(w[nw-1] - w[0] NE nw-1) then bad = 1

     if(bad) then sigma[i] = ns $
     else sigma[i] = max([max(w)-scan_indices[i], scan_indices[i]-min(w)])
    end

  end


 ;----------------------------------------------------------------------
 ; use 3-point polynomial interpolation to find max cc for each point
 ;----------------------------------------------------------------------
 Ea = cc_peak[*,0]/2 - cc_peak[*,1] + cc_peak[*,2]/2
 Eb = 3*cc_peak[*,0]/2 - 2*cc_peak[*,1] + cc_peak[*,2]/2
 Eg = cc_peak[*,0]

 ;--------------------------------------------------------
 ; weed out various potential arithmetic errors
 ;--------------------------------------------------------
 if(flat_sub[0] NE -1) then Ea[flat_sub] = 1.0

 zero_sub = where(Ea EQ 0)
 if (zero_sub[0] NE -1) then Ea[zero_sub] = 1.0

 ;-------------------
 ; compute peaks
 ;-------------------
 xm = Eb/(2*Ea)
 cc = Ea*xm^2 - Eb*xm + Eg

 w = where(sigma EQ ns)
 if(w[0] NE -1) then cc[w] = 0

 scan_indices = scan_indices + xm - 1


 ;--------------------------------
 ; convert to scan offsets
 ;--------------------------------
 scan_offsets = (scan_indices+mzero) - szero
;stop


 return, scan_offsets
end
;===========================================================================






; window, /free
; ii=40
; x = dindgen(ns-nm)
; plot, x, cc_all[ii,*]

; plot, ma[ii,*]
; plot, sa[ii,*]
; plot, scan_offsets
; plot, scan_indices

; tvscl, strip
; plots, lindgen(n), scan_offsets+szero, /device, col=255

; tvscl, cc_all
; plots, lindgen(n), scan_indices, /device, col=255

; ii=12
; plot, cc_peak[ii,*], /yno
; print, xm[ii], cc[ii]
; x = dindgen(90)/30
; oplot, x, Ea[ii]*x^2 - Eb[ii]*x + Eg[ii], col=255



