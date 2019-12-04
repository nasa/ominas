;=============================================================================
;+
; NAME:
;       cas_nac_to_wac
;
;
; PURPOSE:
;	This procedure converts Cassini ISS NAC pixel locations into
;	ISS WAC pixel locations.
;
;
; CATEGORY:
;       UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;       result = cas_nac_to_wac(points)
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
;       Updated by:     Haemmerle 9/2000
;                       
;-
;=============================================================================
function cas_nac_to_wac, npoints, mark=mark

  n = n_elements(npoints)/2
  wpoints = fltarr(2,n)

;======================================
; NAC boresight in WAC from ICO results
; Line (y)   522.98 +/-   1.08
; Sample (x) 504.22 +/-   0.14
;======================================
; NAC boresight in WAC from Fomalhaut results
; Line (y)   522.23 +/-   0.19
; Sample (x) 504.62 +/-   0.12
;======================================

  wpoints(0,*) = 0.1*(npoints(0,*) - 511.5) + 504.62
  wpoints(1,*) = 0.1*(npoints(1,*) - 511.5) + 522.23

  if(keyword__set(mark)) then $
   begin
    for i=0,n do $
    plots, npoints(0,i), npoints(1,i), psym=6, symsize=5
   end

 return, wpoints
end
;=============================================================================
