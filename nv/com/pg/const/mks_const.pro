;============================================================================
; mks_const
;
;============================================================================
function mks_const, name

 case name of 
  'G'   	  : return, 6.6725985d-11	; Gravitational constant J m/kg2
  'c'     	: return, 2.99792458d8		; Speed of light m/s2; from cspice_clight()
  'sigma' 	: return, 5.669656d-8		; Stefan-Boltzmann constant W/m2/K4
  'k'    	 : return, 1.38062d-23		; Boltzmann's constant
  'h'     	: return, 6.62620d-34		; Planck's constant
  'rho_h2o'     : return, 1d3			; Density of water kg/m3
  'to_m'  	: return, 1d			; convert lengths to meters
  'to_km' 	: return, 1d-3			; convert lengths to km
  'to_cm' 	: return, 1d2			; convert lengths to cm
  'AU'   	 : return, 1.496d11		; Astromonimcal unit m
 endcase

end
;============================================================================
