;=============================================================================
;+
; NAME:
;       cas_nac_box
;
;
; PURPOSE:
;	This procedure converts Cassini ISS NAC image corners into
;	ISS WAC pixel locations.  Useful for plotting NAC FOV in WAC
;	images.
;
;
; CATEGORY:
;       UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;       result = cas_nac_box()
;
;
; ARGUMENTS:
;  INPUT:
;       NONE
;
;  OUTPUT:
;       NONE 
;
; KEYWORDS:
;
;       NONE
;
; RETURN:
;        Array of corner pixels.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle 1/2000 
;                       
;-
;=============================================================================
function cas_nac_box

  npoints = fltarr(2,5)
  npoints(0,0)= 0.
  npoints(1,0)= 0.
  npoints(0,1)= 0.
  npoints(1,1)= 1023.
  npoints(0,2)= 1023.
  npoints(1,2)= 1023.
  npoints(0,3)= 1023.
  npoints(1,3)= 0.
  npoints(0,4)= 0.
  npoints(1,4)= 0.

  wpoints = cas_nac_to_wac(npoints)

 return, wpoints
end
;=============================================================================
