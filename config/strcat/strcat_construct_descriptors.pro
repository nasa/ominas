;=============================================================================
; strcat_construct_descriptors
;
;
;=============================================================================
function strcat_construct_descriptors, dd, parm, stars, note=note

 names = *parm.names_p

 ;---------------------------------------------------------
 ; apply brightness thresholds
 ;---------------------------------------------------------
 if(finite(parm.faint)) then $
  begin
   w = where(stars.mag LE parm.faint)
   if(w[0] EQ -1) then return, ''
   stars = stars[w]
  end
 if(finite(parm.bright)) then $
  begin
   w = where(stars.mag GE parm.bright)
   if(w[0] EQ -1) then return, ''
   stars = stars[w]
  end

 ;---------------------------------------------------------
 ; Select explicitly named stars
 ;---------------------------------------------------------
 if(keyword_set(names)) then $
  begin
   w = where(names EQ stars.name)
   if(w[0] NE -1) then _stars = stars[w]
   if(NOT keyword__set(_stars)) then return, ''
   stars = _stars
  end

 ;---------------------------------------------------------
 ; If limits are defined, remove stars that fall outside
 ; the limits. 
 ;---------------------------------------------------------
 w = strcat_radec_select([parm.ra1, parm.ra2]*!dpi/180d, [parm.dec1, parm.dec2]*!dpi/180d, $
	                             stars.ra*!dpi/180d, stars.dec*!dpi/180d)
 if(w[0] EQ -1) then return, ''
 stars = stars[w]

 ;--------------------------------------------------------
 ; Apply proper motion to stars
 ; jtime = years past 2000.0
 ; rapm and decpm = degrees per year
 ;--------------------------------------------------------
 stars.ra = stars.ra + stars.rapm * parm.jtime
 stars.dec = stars.dec + stars.decpm * parm.jtime

 ;---------------------------------------------------------
 ; Work in radians now
 ;---------------------------------------------------------
 stars.ra = stars.ra * !dpi/180d
 stars.dec = stars.dec * !dpi/180d
 stars.rapm = stars.rapm * !dpi/180d
 stars.decpm = stars.decpm * !dpi/180d

 n = n_elements(stars)
 nv_message, verb=0.1, 'Total of ' + strtrim(n,2) + ' stars.'
 if(n EQ 0) then return, ''

 ;---------------------------------------------------------
 ; Calculate "dummy" properties
 ;---------------------------------------------------------
 orient = make_array(3,3,n)
 _orient = [ [1d,0d,0d], [0d,1d,0d], [0d,0d,1d] ]
 for j = 0 , n-1 do orient[*,*,j] = _orient
 avel = make_array(1,3,n,value=0d)
 vel = make_array(1,3,n,value=0d)
 time = make_array(n,value=0d)
 radii = make_array(3,n,value=0d)
 lora = make_array(n, value=0d)


 ;---------------------------------------------------------
 ; Calculate position vector, use a very large distance 
 ; since parallax is not known for this catalog.
 ;---------------------------------------------------------
 ; 3 orders of magnitude larger than the diameter of the milky way in km
 dist = make_array(n,val=1d21)
 radec = transpose([transpose([stars.ra]), transpose([stars.dec]), transpose([dist])])
 pos = bod_radec_to_body(bod_inertial(), radec)


 ;---------------------------------------------------------
 ; Compute skyplane velocity from proper motion 
 ;---------------------------------------------------------
 radec_vel = transpose([transpose([stars.rapm]/86400d/365.25d), transpose([stars.decpm]/86400d/365.25d), dblarr(1,n)])
 vel = bod_radec_to_body_vel(bod_inertial(), radec, radec_vel)

 ;---------------------------------------------------------
 ; Precess to output coordinstae
 ;---------------------------------------------------------
 strcat_precess, parm, pos, /back
 strcat_precess, parm, vel, /back

 pos = reform(transpose(pos),1,3,n, /over)
 vel = reform(transpose(vel),1,3,n, /over)

 ;-------------------------------------------------------------
 ; Calculate "luminosity" from visual Magnitude using the 
 ; Sun as a model. If distance is unknown, lum will be 
 ; incorrect, but the magnitudes will work out in str_get_mag.
 ;-------------------------------------------------------------
 pc = const_get('parsec')
 Lsun = const_get('Lsun')
 m = stars.mag - 5d*alog10(dist/pc) + 5d
 lum = Lsun * 10.d^( (4.83d0-m)/2.5d )

 ;---------------------------------------------------------
 ; create star descriptors
 ;---------------------------------------------------------
 sd = str_create_descriptors(n, $
        gd=make_array(n, val=dd), $
        name=stars.name, $
        orient=orient, $
        avel=avel, $
        pos=pos, $
        vel=vel, $
        time=time, $
        radii=radii, $
        lora=lora, $
        lum=lum, $
        sp=sp )
 if(keyword_set(note)) then cor_set_udata, sd[0], 'STRCAT_NOTE', note

 return, sd
end
;=============================================================================
