;=============================================================================
;+
; NAME:
;       str_get_flux
;
;
; PURPOSE:
;       Calculates the flux (power/area) for each given star relative to 
;	a given observer.
;
;
; CATEGORY:
;       NV/LIB/STR
;
;
; CALLING SEQUENCE:
;       result = str_get_flux(sd, od=od)
;
;
; ARGUMENTS:
;  INPUT:
;       sd:    Array (nt) of star descriptors.
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;  INPUT: 
;	od:	Observer descriptor.
;
;  OUTPUT: NONE
;
; RETURN:
;       An array (nt) of fluxes.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 8/2017
;
;
;-
;=============================================================================
function str_get_flux, sd, od=od
@core.include

 dim = size(sd, /dim)
 nv = dim[0]
 nt = 1
 if(n_elements(dim) GT 2) then nt = dim[2]

 pos = (bod_pos(od))[linegen3x(nv,3,nt)]

 return, str_lum(sd) / 4d / !dpi / v_sqmag(bod_pos(sd)-pos)
end
;===========================================================================
