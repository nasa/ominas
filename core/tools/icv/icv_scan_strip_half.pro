;=============================================================================
;+
; NAME:
;	icv_scan_strip_half
;
;
; PURPOSE:
;	At each point along an image strip, finds a sharp edge using the
;	half-power method.
;
;
; CATEGORY:
;	NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;	result = icv_scan_strip_half(strip, model, szero, mzero)
;
;
; ARGUMENTS:
;  INPUT:
;	strip:	Image strip (n_points,ns) to be scanned.  Output from
;		icv_strip_curve ns must be even.
;
;	model:	Not used.
;
;	szero:	Zero-offset position in the strip.
;
;	mzero:	Not used.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	cc:	Not used, hardwired to 0.9999999d.
;
;	sigma:	Offset uncertainty for each point on the curve, computed as
;		one half of the half-width of the half-power peak. 
;
;
; RETURN:
;	Offset of half-power points at each point on the curve.
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function icv_scan_strip_half, strip, model, szero, mzero, arg=inner, $
       cc=cc, sigma=sigma, center=center

 mzero = 0.

 ;-----------------
 ; get sizes
 ;-----------------
 s = size(strip)
 n = s[1]
 ns = s[2]
 half_ns = ns/2

 ;----------------------------------
 ; compute gradients
 ;----------------------------------
 hp_all = 0.5*(nmax(strip, 1) + nmin(strip, 1)) # make_array(ns, val=1d)
 hp_all = -abs(hp_all - strip)

 ;-----------------------------------------------------------------
 ; Find indices near half power and extract 3 pixels about peak.
 ; Also, find half widths of hp peaks.
 ;-----------------------------------------------------------------
 scan_indices = dblarr(n,/nozero)
 sigma = make_array(n, val=ns)

 hp_peak = dblarr(n,3)
 for i=0, n-1 do $
  begin
   hp = 0.5*(max(strip[i,*]) + min(strip[i,*]))

   scan_indices[i] = (where(hp_all[i,*] EQ max(hp_all[i,*])))[0]
   if((scan_indices[i] GT 0) AND (scan_indices[i] LT ns)) then $
    begin
     hp_peak[i,*] = hp_all[i, scan_indices[i]+indgen(3)-1]

     ;- - - - - - - - - - - - - - - - - - - - -
     ; approx. half-width
     ;- - - - - - - - - - - - - - - - - - - - -
     w = where(hp_all[i,*] GT hp_peak[i,1]/2.)
     nw = n_elements(w)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; if there are multiple peaks, then this scan offset is meaningless
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     bad = 0
;     if(nw LT 5) then bad = 1
;     if(w[nw-1] - w[0] NE nw-1) then bad = 1

     if(bad) then sigma[i] = ns $
     else sigma[i] = 1. > (max([max(w)-scan_indices[i], scan_indices[i]-min(w)]))
    end

  end


 ;----------------------------------------------------------------------
 ; use 3-point polynomial interpolation to find hp for each point
 ;----------------------------------------------------------------------
 Ea = hp_peak[*,0]/2 - hp_peak[*,1] + hp_peak[*,2]/2
 Eb = 3*hp_peak[*,0]/2 - 2*hp_peak[*,1] + hp_peak[*,2]/2
 Eg = hp_peak[*,0]



 ;-------------------
 ; compute peaks
 ;-------------------
 xm = Eb/(2*Ea)
 hp = Ea*xm^2 - Eb*xm + Eg

 w = where(sigma EQ ns)
 if(w[0] NE -1) then hp[w] = 0

 scan_indices = scan_indices + xm - 1


 ;--------------------------------
 ; convert to scan offsets
 ;--------------------------------
 scan_offsets = (scan_indices+mzero) - szero


 ;--------------------------------------------------------
 ; ensure that all points are accepted by the software
 ;--------------------------------------------------------
 cc = make_array(n, val=0.9999999d)


 return, scan_offsets
end
;=============================================================================
