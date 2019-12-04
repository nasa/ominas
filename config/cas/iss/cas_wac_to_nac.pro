;=============================================================================
;+
; NAME:
;       cas_wac_to_nac
;
;
; PURPOSE:
;	This procedure converts Cassini ISS WAC pixel locations into
;	ISS NAC pixel locations.
;
;
; CATEGORY:
;       UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;       result = cas_wac_to_nac(points)
;
;
; ARGUMENTS:
;  INPUT:
;       points:     Array of Position of sample (x) and line (y)
;
;
;  OUTPUT:
;       NONE 
;
; KEYWORDS:
;
;          mark:     Mark sample,line positions
;
;
; RETURN:
;        Array of Sample (x) and line (y) of the resulting transformation.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle 1/2000 
;       Updated by:     Haemmmerle 9/2000
;                       
;-
;=============================================================================
function cas_wac_to_nac, wpoints, mark=mark

  n = n_elements(wpoints)/2
  npoints = fltarr(2,n)

;======================================
; WAC boresight in NAC from ICO results
; Line (y)   391.2 +/-  10.8
; Sample (x) 578.8 +/-   1.4
;======================================
; WAC boresight in NAC from Fomalhaut results
; Line (y)   404.2 +/-   1.9
; Sample (x) 580.3 +/-   1.2
;======================================

  npoints(0,*) = 10.*(wpoints(0,*) - 511.5) + 580.3
  npoints(1,*) = 10.*(wpoints(1,*) - 511.5) + 404.2

  if(keyword__set(mark)) then $
   begin
    for i=0,n do $
    plots, npoints(0,i), npoints(1,i), psym=6, symsize=5
   end

 return, npoints
end
;=============================================================================
