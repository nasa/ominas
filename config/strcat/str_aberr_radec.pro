; docformat = 'rst'
;+
;	Corrects star positions for stellar aberration due to the velocity
;	of the observer.
; 
; Purpose
; ======= 
; 
; Star catalogues are compiled for a reference frame in which the 
; Sun (or alternately the Solar System Barycenter or SSB) is 
; stationary.  For an observer moving at a large velocity wrt the
; SSB, a correction must be done.  Let v be the observer's velocity.
; If omega is the angle between the observer's velocity vector and 
; the vector pointing towards the star, then `v*sin(omega)` is the 
; component of the observer's velocity that is tangential to the 
; star's position.  To transform the starlight's velocity vector
; from the SSB-stationary frame into the observer's frame, this
; velocity must be vector-subtracted from the starlight's vector.
; The result is the starlight's path as observed in the observer's
; frame, which is deflected by an angle phi (the angle at the
; bottom of the triangle below).  Since, according to Special
; Relativity, the velocity of light is `c = 3e8 m/s` in all frames,
; the hypoteneuse of the triangle below (representing the light's
; path in the observer's frame) has a vector magnitude of `c`::
;
;                      v*sin(omega)
;                       <-------
;                        ^     ^
;                         \    |
;          apparent path   \   | actual path
;          of starlight     \  | of starlight
;            (c)             \ |
;                             \|
;
; Therefore, we arrive at an expression for the deflection angle::
;
;  sin(phi) = v*sin(omega) / c
;
; Restrictions
; ============
; 
; Input vel must be a 1x3 vector in inertial Cartesian coordinates,
; in units of meters/second.
;       
; :Categories:
;       nv, config, str
;
; :Version:
;     Completed.  Checked vs SPICE routine STELAB
;       
; :Obsolete:
;
; :History:
; 	Tiscareno, 7/00
;      
; 	Haemmerle, 12/00
;
;-

;+
; :Params:
;    ra : in, type=double
;       Array of Right Ascension (radians)
;    dec : in, type=double
;       Array of Declination (radians)
;    vel : in, type="double array"
;       Velocity of the observer, in meters/second wrt Solar System
;	      Barycenter, or Sun, which is close enough
;    abr_ra : out, type="double array"
;       Array of aberration corrected Right Ascension (radians)
;    abr_dec : out, type="double array"
;       Array of aberration corrected Declination (radians)
;
; :Hidden: 
;-
pro str_aberr_radec, ra, dec, vel, abr_ra, abr_dec

;----------------------------------------------------------
; Stellar aberration is now performed downstream.  
; Translators are instead required to return uncorrected
; positions. I haven't yet tested this; Spitale 3/2006
;----------------------------------------------------------
;abr_ra = ra & abr_dec = dec
;return

 n=n_elements(ra)
 radec = dblarr(n,3)
 radec[*,0] = ra
 radec[*,1] = dec
 radec[*,2] = 1

;----------------------------------------------------------
; We reverse the velocity here because stellab_pos treats 
; the observer as stationary, while this routine treats 
; the target as stationary.
;----------------------------------------------------------
 radec_cor = stellab_radec(radec, -vel[linegen3x(n,3,1)], c=299792.458d3)
 abr_ra = radec_cor[*,0,*]
 abr_dec = radec_cor[*,1,*]
 return

 n=n_elements(ra)
 if(n NE n_elements(dec)) then begin
  message, 'Input variable dimensions do not agree'
 endif
 c=299792.458d3  ; Speed of light

 ;---------------------------------------------------------
 ; Convert to position vectors
 ;---------------------------------------------------------
 r = dblarr(n,3)
 r[*,0] = cos(ra)*cos(dec)
 r[*,1] = sin(ra)*cos(dec)
 r[*,2] = sin(dec)

 ;---------------------------------------------------------
 ; Get rotation axis (perpendicular to both pos and vel)
 ;---------------------------------------------------------
 h=v_cross(v_unit(r),rebin(vel,n,3)/c )

 ;---------------------------------------------------------
 ; Get rotation angle sin(phi) = (v/c*sin(omega)) = mag(h)
 ;---------------------------------------------------------
 phi=asin(v_mag(h))

 ;---------------------------------------------------------
 ; Rotate about h by phi radians to get apparent position
 ;---------------------------------------------------------
 if((v_mag(vel))[0] NE 0d0) THEN $
  begin
   abr_r=v_rotate(r,v_unit(h),sin(phi),cos(phi))
   for i=0,n-1 do r[i,*]=abr_r[i,*,i]
  end 

 ;---------------------------------------------------------
 ; Convert back to ra, dec
 ;---------------------------------------------------------
 abr_ra = atan(r[*,1],r[*,0])
 abr_dec = asin(r[*,2])

end
