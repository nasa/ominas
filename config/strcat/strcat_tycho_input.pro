;===============================================================================
; docformat = 'rst'
;+
;
;        Input translator for Tycho-1 star catalog.
;
; Usage
; =====
; This routine is called via `dat_get_value`, which is used to read the
; translator table. In particular, the specific translator for the scene
; to be processed should contain the following line::
;
;      -   strcat_tycho_input     -       /j2000    # or /b1950 if desired
;
; For the star catalog translator system to work properly, only one type
; of catalog may be used at a time for a particular instrument.
; The version of the TYCHO catalog that this translator expects can be
; obtained from the original CD's. The catalog data is grouped into 
; approx 10,000 separate regions in numbered files in 24 separate 
; subdirectories. Each star has a data record of 16 bytes.Two identifying
; numbers: TYCHO_ID_1 and TYCHO_ID_2, RA_DEG and DEC_DEG (degrees), 
; RApm and DECpm (milliarcseconds/year), and MAG (Visual Magnitude). 
; The real values (RA_DEG, DEC_DEG, RApm, DECpm, and MAG) are in XDR,
; the GSC_ID and CLASS are network-order short integers.
;
;
; Restrictions
; ============
; 
; Since the distance to stars are not given in the GSC catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
;
; Procedure
; =========
; 
; Stars are found in a square area in RA and DEC around a given
; or calculated center.  The star descriptor is filled with stars
; that fit in this area.  If B1950 is selected, input RA, DEC and/or
;	ods orient matrix is assumed to be B1950 also, if not, input is
;	assumed to be J2000, like the catalog.  
;
; :Categories:
; nv, config
;
; :History:
;       Written by:     Vance Haemmerle, 3/2000
;
;       Modified:       Tiscareno, 8/2000
;
;	      Modified:	      Haemmerle, 12/2000
;
;       Modified:       Spitale 9/2001
;
;-
;===============================================================================

;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function tycho_fzone, declow, dechi

  dec = (declow + dechi) / 2.0
  zone = fix (dec / (90./12.)) + 1
  if (dec lt 0) then begin
    zone = (12 + 2) - zone
  endif

  return, zone
end

;+
; :Private:
; :Hidden:
; Initialize zone directory names for TYCHO catalog
;-
pro tycho_initzd, zdir

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
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Search the index table to find the region identifiers whose coordinate
; limits overlap the specified field. Save list of paths to gsc files for
; these regions.
; :Params:
;   ra1 : in, required, type=double
;      lower bound in right ascension of scene in hours
;   ra2 : in, required, type=double
;      upper bound in right ascension of scene in hours
;   dec1 : in, required, type=double
;      lower bound in declination of scene in degrees
;   dec2 : in, required, type=double
;      upper bound in declination of scene in degrees
;      
; :Keywords:
;    path_tycho : in, required, type=string, default='NV_TYCHO_DATA'
;       Sets the path to look for catalog files. Uses the value of
;       the NV_TYCHO_DATA environment variable by default.
;       
; :Returns:
;    Table to store regions found (to search for guide stars)
;    
;-
function tycho_get_regions, ra1, ra2, dec1, dec2, path_tycho=path_tycho

  ; Initialize the directory name for each zone
  zdir = strarr(24)
  tycho_initzd, zdir
  rows = 9537
  num_regions = 0

  region_file = path_tycho + "/" + "regions.index"
  if(!VERSION.OS eq 'vms') then $
   begin
    len = strlen(path_tycho)
    lastchar = strmid(path_tycho,len-1,1)
    if(lastchar eq ']' or lastchar eq ':') then $
      region_file = path_tycho + "regions.index"
    if(lastchar eq '.') then region_file = $
     strmid(path_tycho,0,len-1) + "]" + "regions.index"
   end

  get_lun, lun
  openr, lun, region_file
  tycho_region_table = assoc(lun,{tycho_region})

  region_list = ''
  for row = 0, rows-1 do begin
    ; For each row in the tycho_region_table
    region_table = tycho_region_table[row]

    ; Declination range of the Tycho/GSC region
    ; Note:  southern dechi and declow are reversed
    dechi = region_table.DEC_HI
    byteorder, dechi, /XDRTOF

    if (dechi gt 0 and dechi lt dec1) then begin
      goto,next
    endif else if (dechi lt 0 and dechi gt dec2) then begin
      goto,next
    endif

    ; Limit of Tycho/GSC region closer to equator
    declow = region_table.DEC_LO
    byteorder, declow, /XDRTOF

    if (declow gt 0) then begin
      ; North
      if (declow gt dec2) then goto,next
    endif else if (declow lt 0) then  begin
      ; South
      if (declow le dec1) then goto, next
    endif else begin
      ; Lower limit of Tycho/GSC region ON equator
      if (dechi gt 0) then begin
        ; North
        if (dechi lt dec1 or declow gt dec2) then goto, next
      endif else if (dechi < 0) then begin
        ; South
        if (dechi gt dec2 or declow lt dec1) then goto, next
      endif
    endelse

    ; Right ascension range of the Tycho/GSC region
    if (ra1 lt ra2) then begin
      ; 0 R.A. not in region

      ralow = region_table.RA_LOW
      byteorder, ralow, /XDRTOF
      if (ralow gt ra2) then goto, next

      rahi = region_table.RA_HI
      byteorder, rahi, /XDRTOF
      if (ralow gt rahi) then rahi = rahi + 360.0
      if (rahi lt ra1) then goto, next

    endif else begin

      ; 0 R.A. in region
      ralow = region_table.RA_LOW
      byteorder, ralow, /XDRTOF
      rahi = region_table.RA_HI
      byteorder, rahi, /XDRTOF

      if (ralow gt rahi) then rahi = rahi + 360.0
      if (ralow gt ra2 and rahi lt ra1) then goto, next

    endelse

    ; Region number
    regnum = region_table.REG_NO
    byteorder, regnum, /NTOHS

    ; Zone number => directory name
    zone = tycho_fzone (declow, dechi)

    ; Build the file name
    root = string(format='(i4.4,".str")',regnum)

    path = string(format='(a,"/",a,"/")',path_tycho,zdir(zone-1))
    if(!VERSION.OS eq 'vms') then $
     begin
      len = strlen(path_tycho)
      lastchar = strmid(path_tycho,len-1,1)
      if(lastchar eq ']') then path = $
       strmid(path_tycho,0,len-1) + "." + zdir(zone-1) + "]"
      if(lastchar eq ':') then path = $
       path_tycho + "[" + zdir(zone-1) + "]"
      if(lastchar eq '.') then path = $
       path_tycho + zdir(zone-1) + "]"
     end

    if(num_regions eq 0) then region_list = path+root $
    else region_list = [region_list, path+root]
    num_regions = num_regions + 1

next: a = 1
  endfor

 close, lun
 free_lun, lun
 return, region_list
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Ingests a set of records from the TYCHO-2 star catalog and generates star 
; descriptors for each star within a specified scene.
;
; :Returns:
;   array of star descriptors
;
; :Params:
;   dd : in, required, type="data descriptor"
;      data descriptor
;   filename : in, required, type=string
;      name of index file, or regions file
;  
; :Keywords:
;   b1950 : in, optional, type=string
;      if set, coordinates are output wrt b1950
;   ra1 : in, required, type=double
;      lower bound in right ascension of scene
;   ra2 : in, required, type=double
;      upper bound in right ascension of scene
;   dec1 : in, required, type=double
;      lower bound in declination of scene
;   dec2 : in, required, type=double
;      upper bound in declination of scene
;   faint : in, optional, type=double
;      stars with magnitudes fainter than this will not be returned
;   bright : in, optional, type=double
;      stars with magnitudes brighter than this will not be returned
;   nbright : in, optional, type=double
;      if set, selects only the n brightest stars
;   names : in, optional, type="string array"
;      if set, will return only the stars with the expected names
;   mag : out, required, type=double
;      magnitude of returned stars
;   jtime : in, optional, type=double
;      Years since 1950 (the epoch of catalog) for precession
;      and proper motion correction. If not given, it is taken
;      from the object descriptor bod_time, which is assumed to
;      be seconds past 2000, unless keyword /b1950 is set
;-
;===============================================================================
function tycho_get_stars, filename, b1950=b1950, $
         jtime=jtime, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, names=names, mag=mag

 f = findfile(filename)
 if(f[0] eq '') then $
  begin
   print, 'tycho_get_stars: File does not exist - ',filename
   return, ''
  end

 ;----------------------------------------------
 ; Open file, expected name ends with "nnnn.str"
 ; where nnnn is the Tycho/GSC region
 ;----------------------------------------------
 start = strpos(filename,'.str') - 4
 tycho_region = strmid(filename,start,4)
 openr, tycho_unit, filename, /get_lun
 info = fstat(tycho_unit)
 nstars = info.size/24
 stars = replicate({tycho_record},nstars)
 readu, tycho_unit, stars
 close, tycho_unit
 free_lun, tycho_unit

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
 RA_DEG = stars.RA_DEG
 DEC_DEG = stars.DEC_DEG
 RApm = stars.RApm
 DECpm = stars.DECpm
 Mag = stars.MAG
 ID_1 = stars.TYCHO_ID_1
 ID_2 = stars.TYCHO_ID_2
 byteorder, RA_DEG, /XDRTOF
 byteorder, DEC_DEG, /XDRTOF
 byteorder, RApm, /XDRTOF
 byteorder, DECpm, /XDRTOF
 byteorder, Mag, /XDRTOF
 byteorder, ID_1, /NTOHS
 byteorder, ID_2, /NTOHS

 ;------------------------------------------------------------------
 ; If limits are defined, remove stars which fall outside the limits
 ; Limits in deg, Assumes RA's + DEC's in J2000 (B1950 if /b1950)
 ;------------------------------------------------------------------
; *** need to use strcat_radec_regions (see strcat_tycho2_input) ***
 if(keyword__set(dec1) and keyword__set(dec2)) then $
   begin
    subs = where(DEC_DEG ge dec1 and DEC_DEG le dec2, count)
    if(count eq 0) then return, ''
    RA_DEG = RA_DEG[subs]
    DEC_DEG = DEC_DEG[subs]
    RApm = RApm[subs]
    DECpm = DECpm[subs]
    Mag = Mag[subs]
    ID_1 = ID_1[subs]
    ID_2 = ID_2[subs]
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
    RA_DEG = RA_DEG[subs]
    DEC_DEG = DEC_DEG[subs]
    RApm = RApm[subs]
    DECpm = DECpm[subs]
    Mag = Mag[subs]
    ID_1 = ID_1[subs]
    ID_2 = ID_2[subs]
   end

 RA = RA_DEG*!DPI/180d0
 DEC = DEC_DEG*!DPI/180d0
 tycho_id = STRING(ID_1+100000)
 tycho_id = strmid(strtrim(tycho_id,2),1,5)
 Name = 'TYC ' + tycho_region + '-' + tycho_id + '-' + strtrim(ID_2,2)

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
 print, 'Total of ',n,' stars out of ',nstars,' in Tycho/GSC region ', $
	tycho_region
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
 ;-------------------------------------------------------
 Lsun = const_get('Lsun')
 lum = Lsun * 10.d^( (4.83d0-double(Mag))/2.5d ) 

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
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function _strcat_tycho_input, dd, keyword, n_obj=n_obj, dim=dim, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 return, strcat_input('tycho', dd, keyword, n_obj=n_obj, dim=dim, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )

end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_tycho_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 status = -1
 if(keyword NE 'STR_DESCRIPTORS') then return, ''

 ;-----------------------------------------------
 ; get inputs
 ;-----------------------------------------------
 strcat_get_inputs, dd, 'NV_TYCHO_DATA', 'path_tycho', $
	b1950=b1950, j2000=j2000, jtime=jtime, $
	path=path_tycho, names=names, $
	ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
	faint=faint, bright=bright, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords
  if(NOT keyword__set(path_tycho)) then return, ''
 

 status=0
 n_obj=0
 dim = [1]

 ;---------------------------
 ; Get GSC regions to read in
 ;---------------------------
 ra1 = ra1*180d/!dpi
 ra2 = ra2*180d/!dpi
 dec1 = dec1*180d/!dpi
 dec2 = dec2*180d/!dpi

 regions = tycho_get_regions(ra1, ra2, dec1, dec2, path_tycho=path_tycho)
 nregions = n_elements(regions)
 if(nregions eq 1 AND regions[0] eq '') then $
                                nv_message, 'No Tycho/GSC regions found.'
 nv_message, verb=0.2, 'Number of Tycho/GSC regions found: ', nregions

 ;--------------------------
 ; Loop on Tycho/GSC regions
 ;--------------------------
 first = 1
 for i=0,nregions-1 do $
  begin
   _sd = tycho_get_stars(regions[i], cam_vel=cam__vel, jtime=jtime, $
		ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, b1950=b1950, $
		faint=faint, bright=bright, names=names)
   if(keyword__set(_sd)) then $
    begin
      if(first eq 1) then $
        begin
         sd = _sd
         first = 0
        end $
       else sd = [sd, _sd]
    end
  end

 n_obj = n_elements(sd)
print, 'Total Tycho-2 stars found: ',n_obj

 status = -1
 if(n_obj EQ 0) then return, ''

 status = 0
 return, sd
end
;===============================================================================
