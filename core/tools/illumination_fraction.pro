;=============================================================================
;+
; NAME:
;       illumination_fraction
;
;
; PURPOSE:
;	Assuming the body gbx is a sphere, this routine computes the fraction of 
;	its disk that appears illuminated by the source ltd, as seen from the
;	inertial position vectors v.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       v = illumination_fraction(gbx, ltd, v)
;
;
; ARGUMENTS:
;  INPUT:
;	gbx:	Any subclass of GLOBE.
;
;	ltd:	Any subclass of STAR representing the light source.
;
;	v:	Array (nv,3) Inertial positions of viewer.
;
;  OUTPUT:
;       NONE
;
;
; KEYOWRDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (nv) giving the illumination fraction for each gbx.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function illumination_fraction, gbx, ltd, v

 nv = n_elements(v)/3

 vv = bod_inertial_to_body_pos(gbx, v)
 ss = bod_inertial_to_body_pos(gbx, bod_pos(ltd)) ## make_array(nv, val=1d)

 phi = v_angle(vv,ss) - !dpi/2d

 fraction = 0.5d*(1d - sin(phi))

 return, fraction
end
;===========================================================================



