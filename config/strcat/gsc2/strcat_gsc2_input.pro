; docformat = 'rst'
;+
;
; Input translator for GSC2 star catalog. See also: `gsc_catalog_inputs`
;
; Usage
; =====
; This routine is called via `dat_get_value`, which is used to read the
; translator table. In particular, the specific translator for the scene
; to be processed should contain the following line::
;
;      -   strcat_gsc2_input     -       /j2000    # or /b1950 if desired
;
; For the star catalog translator system to work properly, only one type
; of catalog may be used at a time for a particular instrument.
;
; The version of the GSC2 catalog that this translator expects can be
; obtained from the catalog compilation function outlined in 
; `gsc2_catalog_inputs`. The catalog data is grouped into 
; approx 10,000 separate regions in numbered files in 24 separate 
; subdirectories. Each star has a data record of 16 bytes.
;
; Record description: GSC_ID, CLASS, RA_DEG (degrees), DEC_DEG
; (degrees), and MAG (Visual Magnitude). The real values (RA_DEG, 
; DEC_DEG and MAG) are in XDR, the GSC_ID and CLASS are network-order
; short integers.
;
; Restrictions
; ============
;
; IMPORTANT: This translator may not be used until the appropriate data
; have been obtained from the Space Telescope Science Institute website. 
; See Procedure below.
;
; Since the distance to stars are not given in the GSC catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
;
; Procedure
; =========
;
; The gsc2 catalog can be accessed via the Space Telescope Science
; Institute website, but cannot be downloaded in its entirety.  Therefore,
; before using this translator, the catalog must be searched on the stsci
; site::
;
;  `<http://www-gsss.stsci.edu/support/data_access.htm>`
;
; and the results stored in a form readable by this translator.
; Until the complete catalog is available locally, the procedure
; gsc2_catalog_inputs (see the documentation for that procedure) 
; may be used tpo guide the user through the process.
; 
; Stars are found in a square area in RA and DEC around a given
; or calculated center.  The star descriptor is filled with stars
; that fit in this area.  If B1950 is selected, input RA, DEC and/or
; ods orient matrix is assumed to be B1950 also, if not, input is
; assumed to be J2000, like the catalog.  The velocity of the observer 
; is used to correct for stellar aberration.
;
; :Private:
;
; :Categories:
;    nv, config
;
; :History:
;    Written by:     Vance Haemmerle, 3/2000 (pg_get_stars_gsc.pro)
;
;    Modified:       Tiscareno, 8/2000 (pg_get_stars_tycho.pro)
;
;    Modified:       Haemmerle, 12/2000 (pg_get_stars_tycho.pro)
;
;    Modified:       Tiscareno, 9/2001
;
;    Modified:       Spitale; 9/2001 -- changed to strcat_gsc2_input.pro
;
;-

;==============================================================================
;+
; gsc2_fzone:  Determine the Declination zone of a GSC/Tycho region
; :Hidden:
;-
;==============================================================================
function gsc2_fzone, declow, dechi

  dec = (declow + dechi) / 2.0
  zone = fix (dec / (90./12.)) + 1
  if (dec lt 0) then begin
    zone = (12 + 2) - zone
  endif

  return, zone
end

;==============================================================================
;+
; gsc2_initzd: Initialize GSC/Tycho directory names
; :Hidden:
; :Private:
;-
;==============================================================================
pro gsc2_initzd, zdir

  zdir(0)  = 'N0000'
  zdir(1)  = 'N0730'
  zdir(2)  = 'N1500'
  zdir(3)  = 'N2230'
  zdir(4)  = 'N3000'
  zdir(5)  = 'N3730'
  zdir(6)  = 'N4500'
  zdir(7)  = 'N5230'
  zdir(8)  = 'N6000'
  zdir(9)  = 'N6730'
  zdir(10) = 'N7500'
  zdir(11) = 'N8230'

  zdir(12) = 'S0000'
  zdir(13) = 'S0730'
  zdir(14) = 'S1500'
  zdir(15) = 'S2230'
  zdir(16) = 'S3000'
  zdir(17) = 'S3730'
  zdir(18) = 'S4500'
  zdir(19) = 'S5230'
  zdir(20) = 'S6000'
  zdir(21) = 'S6730'
  zdir(22) = 'S7500'
  zdir(23) = 'S8230'
end



;==========================================================================
;+
;  gsc2_get_regions
; :Hidden:
;-
;==========================================================================
function gsc2_get_regions, ra1, ra2, dec1, dec2, path_gsc2=path_gsc2
 return, path_gsc2 + 'gsc2.str'
end
;==========================================================================



;========================================================================
;+
; gsc2_get_stars -  Load the stars that fit within region (ra1 - ra2) 
;                    and (dec1 - dec2) into a star descriptor.
; :Hidden:
;-
;========================================================================
function gsc2_get_stars, filename, b1950=b1950, cam_vel=cam_vel, $
         jtime=jtime, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, noaberr=noaberr, names=names, mag=mag, $
         nbright=nbright

 f = findfile(filename)
 if(f[0] eq '') then $
  begin
   print, 'gsc2_get_stars: File does not exist - ',filename
   return, ''
  end

 ;----------------------------------------------
 ; Open file, expected name ends with "nnnn.str"
 ; where nnnn is the Tycho/GSC region
 ;----------------------------------------------
 openr, gsc2_unit, filename, /get_lun
 info = fstat(gsc2_unit)
 nstars = info.size/24
 stars = replicate({gsc2_record},nstars)
 readu, gsc2_unit, stars
 close, gsc2_unit
 free_lun, gsc2_unit

 ;-------------------------------------
 ; select within magnitude limits
 ;-------------------------------------
 if(n_elements(faint) NE 0) then $
  begin
   faint = double(faint)
   mag = stars.mag
   byteorder, mag, /XDRTOF
   w = where(mag LE faint)
   if(w[0] NE -1) then _stars = stars[w]
   if(NOT keyword__set(_stars)) then return, ''
   stars = _stars
  end

 if(n_elements(bright) NE 0) then $
  begin
   bright = double(bright)
   mag = stars.mag
   byteorder, mag, /XDRTOF
   w = where(mag GE bright)
   if(w[0] NE -1) then __stars = stars[w]
   if(NOT keyword__set(__stars)) then return, ''
   stars = __stars
  end

 ;-------------------------
 ; Unpack the star array
 ;-------------------------
 gsc2_id = stars.gsc2_id
 RA_DEG = stars.RA_DEG
 DEC_DEG = stars.DEC_DEG
 RApm = stars.RApm
 DECpm = stars.DECpm
 Mag = stars.MAG
 byteorder, gsc2_id, /NTOHL
 byteorder, RA_DEG, /XDRTOF
 byteorder, DEC_DEG, /XDRTOF
 byteorder, RApm, /XDRTOF
 byteorder, DECpm, /XDRTOF
 byteorder, Mag, /XDRTOF

 ;------------------------------------------------------------------
 ; If limits are defined, remove stars which fall outside the limits
 ; Limits in deg, Assumes RA's + DEC's in J2000 (B1950 if /b1950)
 ;------------------------------------------------------------------
 if(keyword__set(dec1) and keyword__set(dec2)) then $
   begin
    subs = where(DEC_DEG ge dec1 and DEC_DEG le dec2, count)
    if(count eq 0) then return, ''
    gsc2_id = gsc2_id[subs]
    RA_DEG = RA_DEG[subs]
    DEC_DEG = DEC_DEG[subs]
    RApm = RApm[subs]
    DECpm = DECpm[subs]
    Mag = Mag[subs]
   end

 if(keyword__set(ra1) and keyword__set(ra2)) then $
   begin
    if(ra1 lt ra2) then begin
      ; 0 R.A. not in the region
      subs = where(RA_DEG ge ra1 and RA_DEG le ra2, count)      
      ; Outside R.A. limits
    endif else begin
      ; 0 R.A. is in the region
      subs = where(RA_DEG ge ra1 or RA_DEG le ra2, count)
      ; Outside R.A. limits
    endelse
    if(count eq 0) then return, ''
    gsc2_id = gsc2_id[subs]
    RA_DEG = RA_DEG[subs]
    DEC_DEG = DEC_DEG[subs]
    RApm = RApm[subs]
    DECpm = DECpm[subs]
    Mag = Mag[subs]
   end

 RA = RA_DEG*!DPI/180d0
 DEC = DEC_DEG*!DPI/180d0
 gsc2_id = STRING(gsc2_id)
 Name = 'GSC2 N331' + strtrim(gsc2_id,2)

 ;-------------------------------------
 ; select named stars
 ;-------------------------------------
 if(keyword__set(names)) then $
  begin
   w = where(names EQ name)
   if(w[0] NE -1) then _stars = stars[w]
   if(NOT keyword__set(_stars)) then return, ''
   stars = _stars
  end

 ;----------------------
 ; Fill star descriptors
 ;----------------------
 n = n_elements(Name)
 print, 'Total of ',n,' stars out of ',nstars
 if(n eq 0) then return, ''

 ;-----------------------------
 ; Calculate "dummy" properties
 ;-----------------------------
 orient = make_array(3,3,n)
 _orient = [ [1d,0d,0d], [0d,1d,0d], [0d,0d,1d] ]
 for j = 0 , n-1 do orient[*,*,j] = _orient
 avel = make_array(1,3,n,value=0d)
 vel = make_array(1,3,n,value=0d)
 time = make_array(n,value=0d)
 radii = make_array(3,n,value=1d)
 lora = make_array(n, value=0d)
 sp = make_array(n, value=0d)

 ;--------------------------------------------------------
 ; Apply proper motion to star 
 ; JTIME = years past 2000.0
 ; RApm and DECpm = milliarcseconds per year
 ;--------------------------------------------------------
 RA = RA + ((double(RApm)*JTIME/3.6e6)*!DTOR) / cos(DEC)
 DEC = DEC + (double(DECpm)*JTIME/3.6e6)*!DTOR

 ;---------------------------------------------------------------
 ; Correct for stellar aberration if camera velocity is available
 ;---------------------------------------------------------------
 if not keyword__set(noaberr) AND keyword__set(cam_vel) THEN $
   str_aberr_radec, RA, DEC, cam_vel, RA, DEC

 ;-----------------------------------------------------
 ; Calculate position vector, use distance as 10 parsec 
 ; to have apparent magnitude = absolute magnitude
 ;-----------------------------------------------------
 dist = 3.085678d+17 ; 10pc in meters
 radec = transpose([transpose([RA]), transpose([DEC]), transpose([dist])])
 pos = transpose(bod_radec_to_body(bod_inertial(), radec))

; pos = make_array(3,n,value=0d)
; pos[0,*] = cos(RA)*cos(DEC)*dist
; pos[1,*] = sin(RA)*cos(DEC)*dist
; pos[2,*] = sin(DEC)*dist

 ;---------------------------------------------------
 ; compute skyplane velocity from proper motion 
 ;---------------------------------------------------
 radec_vel = transpose([transpose([RApm]/86400d/365.25d/3600d*!dpi/180d), $
             transpose([DECpm]/86400d/365.25d/3600d*!dpi/180d), dblarr(1,n)])
 vel = bod_radec_to_body_vel(bod_inertial(), radec, radec_vel)


 ;-----------------------------------------------------
 ; Precess J2000 to B1950 if wanted
 ;-----------------------------------------------------
 if(keyword__set(b1950)) then pos = $
  transpose(b1950_to_j2000(transpose(pos),/reverse))
 pos = reform(pos,1,3,n)

 if(keyword_set(b1950)) then vel = $
  transpose(b1950_to_j2000(transpose(vel),/reverse))
 vel = reform(vel,1,3,n)


 ;-------------------------------------------------------
 ; Calculate "luminosity" from visual Magnitude
 ; Use Sun as model, though this is wrong for other stars
 ; but since we don't know A (space absorption) and may
 ; only sometimes know Spectral type... what the heck
 ; use formula Mv = 4.83 - 2.5*log(L/Lsun) and since
 ; distance is 10pc mv = Mv
 ; Lum is expressed in J/sec (Lsun = 3.826e+26 J/sec)
 ;-------------------------------------------------------
 lum = 3.826d+26 * 10.d^( (4.83d0-double(Mag))/2.5d ) 

 _sd = str_create_descriptors( n, $
        name=name, $
        orient=orient, $
        avel=avel, $
        pos=pos, $
        vel=vel, $
        time=time, $
        radii=radii, $
        lora=lora, $
        lum=lum, $
        sp=sp )

 return, _sd
end

;=============================================================================




;=============================================================================
;+
; strcat_gsc2_input
; :Hidden:
;-
;=============================================================================
function strcat_gsc2_input, dd, keyword, n_obj=n_obj, dim=dim, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 return, strcat_input('gsc2', dd, keyword, n_obj=n_obj, dim=dim, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )

end
;=============================================================================
