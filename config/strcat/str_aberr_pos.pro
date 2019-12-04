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
;     Tiscareno, 7/00
;     
;     Haemmerle, 12/00
;
;-

;+
; :Params:
;     pos : in, type="double array"
;        Array of column vectors (1,3,n) from observer to objects 
;     vel : in, type="double array"
;        Velocity of the observer, in meters/second wrt Solar System
;	       Barycenter, or Sun, which is close enough
;     posout : out, type="double array"
;        Apparent position of objects from observer corrected for
;        stellar aberration
;
; :Hidden:
;-
pro str_aberr_pos, pos, vel, posout

;----------------------------------------------------------
; Stellar aberration is now performed downstream.  
; Translators are instead required to return uncorrected
; positions. I haven't yet tested this; Spitale 3/2006
;----------------------------------------------------------
;posout = pos
;return

;----------------------------------------------------------
; We reverse the velocity here because stellab_pos treats 
; the observer as stationary, while this routine treats 
; the target as stationary.
;----------------------------------------------------------
 posout = stellab_pos(pos, -vel, c=pgc_const('c'))
 return
 
 n=n_elements(pos)/3
 c=299792.458d3  ; Speed of light

 r=[pos[0,0,*],pos[0,1,*],pos[0,2,*]]
 r=reform(r,n,3,/overwrite)

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
   abrpos=v_rotate(r,v_unit(h),sin(phi),cos(phi))
   posout=dblarr(1,3,n)
   for i=0,n-1 do posout[0,*,i]=abrpos[i,*,i]
  end $
 else posout = pos

end
