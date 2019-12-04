; docformat = 'rst'
;=============================================================================
;+
; :Hidden:
; 
; NAME:
;       str_aberr
;
;
; PURPOSE:
;	Corrects star positions for stellar aberration due to the velocity
;	of the observer.
;
;	Star catalogues are compiled for a reference frame in which the 
;	Sun (or alternately the Solar System Barycenter or SSB) is 
;	stationary.  For an observer moving at a large velocity wrt the
;	SSB, a correction must be done.  Let v be the observer's velocity.
;	If omega is the angle between the observer's velocity vector and 
;	the vector pointing towards the star, then v*sin(omega) is the 
;	component of the observer's velocity that is tangential to the 
;	star's position.  To transform the starlight's velocity vector
;	from the SSB-stationary frame into the observer's frame, this
;	velocity must be vector-subtracted from the starlight's vector.
;	The result is the starlight's path as observed in the observer's
;	frame, which is deflected by an angle phi (the angle at the
;	bottom of the triangle below).  Since, according to Special
;	Relativity, the velocity of light is c = 3e8 m/s in all frames,
;	the hypoteneuse of the triangle below (representing the light's
;	path in the observer's frame) has a vector magnitude of c.
;
;		     v*sin(omega)
;
;			<-----
;			^     ^
;			 \    |
;	   apparent path  \   | actual path
;	   of starlight	   \  | of starlight
;		(c)	    \ |
;			     \|
;
;	Therefore, we arrive at an expression for the deflection angle:
;
;		sin(phi) = v*sin(omega) / c
;
;
; CATEGORY:
;       LIB/STR
;
;
; CALLING SEQUENCE:
;       str_aberr, rain, decin, vel, raout, decout
;
;
; ARGUMENTS:
;  INPUT:
;           rain:    Actual right ascension of the star(s), in degrees
;
;          decin:    Actual declination of the star(s), in degrees
;
;            vel:    Velocity of the observer, in meters/second
;
;  OUTPUT:
;          raout:    Apparent right ascension of the star(s), in degrees
;
;         decout:    Apparent declination of the star(s), in degrees
;
;
; KEYWORDS:
;  INPUT:
;       NONE
;
;  OUTPUT:
;       NONE
;
;
; RESTRICTIONS:
;	Inputs rain and decin must have the same number of elements.
;	Input vel must be a 1x3 vector in inertial Cartesian coordinates,
;	  in units of meters/second.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Tiscareno, 7/00
;	obsolete due to change in glb_globe routines 7/2007; Spitale
;
;-
;=============================================================================

pro str_aberr, rain, decin, vel, raout, decout

n=n_elements(rain)
if n ne n_elements(decin) then begin
  message, 'Input variable dimensions do not agree'
endif

; Get star position in normalized Cartesian coordinates
r=glb_globe_to_body(1,[[decin*!pi/180],[rain*!pi/180],[replicate(1,n)]])

vmag=(v_mag(vel))[0]
beta=vmag/3e8		; Scale by speed of light.

; Get angle between star position and observer velocity vectors
omega=acos(v_inner(r,rebin(vel,n,3))/vmag)

; Get rotation angle
phi=asin(beta*sin(omega))

; Get rotation axis (perpendicular to both r and vel)
h=v_cross(r,rebin(vel,n,3))
h=h/(v_mag(h))[0]	; Normalize

; Rotate about h by phi radians to get apparent position
rprime1=v_rotate(r,h,[sin(-phi)],[cos(-phi)])
rprime=dblarr(n,3)
for i=0,n-1 do rprime(i,*)=rprime1(i,*,i)

; Return to polar coordinates
radec=glb_body_to_globe(1,rprime)
decout=radec[*,0]*180/!pi
raout=radec[*,1]*180/!pi

end
