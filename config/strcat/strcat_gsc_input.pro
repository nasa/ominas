;===============================================================================
; docformat = 'rst'
;+
; Input translator for GSC star catalog.
;
; Returns
; =======
;   Star descriptor containing all the stars found.  The Sp part of
;   the star descriptor does not contain the Spectral type since this
;   is not available.  Instead it contains the GSC class of the object::
;    0 - star
;    1 - galaxy
;    2 - blend or member of incorrectly resolved blend.
;    3 - non-star
;    5 - potential artifact
;
;   (Note that code 1 is used only for a few  hand-entered errata;
;   galaxies successfully processed by the software have a 
;   classification of 3 [non-stellar].  Also code 4 is never used.)  
;
; Restrictions
; ============
;
; Since the distance to stars are not given in the GSC catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
;	This translator does not correct for proper motion.
;
;
; Procedure
; =========
;
; Stars are found in a square area in RA and DEC around a given
; or calculated center.  The star descriptor is filled with stars
; that fit in this area.  If B1950 is selected, input ods orient 
;	matrix is assumed to be B1950 also, if not, input is assumed to be
;	J2000, like the catalog.  
;
; :Private:
;
; :Categories:
;   nv, config
;
; :History:
;    Written by:     Vance Haemmerle, 3/2000 (pg_get_stars_gsc.pro)
;
;    Modified:       Spitale 9/2001 - changed to strcat_gsc_input.pro
;
;-
;===============================================================================


;===============================================================================
;+
; :Private:
; :Hidden:
;
; gsc_fzone:  Determine the Declination zone of a GSC region
;-
;===============================================================================
function gsc_fzone, declow, dechi

  dec = (declow + dechi) / 2.0
  zone = fix (dec / (90./12.)) + 1
  if (dec lt 0) then begin
    zone = (12 + 2) - zone
  endif

  return, zone
end
;===============================================================================




;==============================================================================
;+
; :Private:
; :Hidden:
;
; gsc_initzd: Initialize GSC directory names
;-
;==============================================================================
pro gsc_initzd, zdir

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




;==============================================================================
;+
; :Private:
; :Hidden:
;
; Search the index table to find the region identifiers whose coordinate
; limits overlap the specified field. Save list of paths to gsc files for
; these regions.
;-
;==============================================================================
function gsc_get_regions, ra1, ra2, dec1, dec2, path_gsc=path_gsc

  ; Initialize the directory name for each zone
  zdir = strarr(24)
  gsc_initzd, zdir
  rows = 9537
  num_regions = 0

  if(NOT keyword__set(path_gsc)) then path_gsc = getenv('NV_GSC_DATA')
  region_file = path_gsc + "/" + "regions.index"
  if(!VERSION.OS eq 'vms') then $
   begin
    len = strlen(path_gsc)
    lastchar = strmid(path_gsc,len-1,1)
    if(lastchar eq ']' or lastchar eq ':') then $
      region_file = path_gsc + "regions.index"
    if(lastchar eq '.') then region_file = $
     strmid(path_gsc,0,len-1) + "]" + "regions.index"
   end

  get_lun, lun
  openr, lun, region_file
  gsc_region_table = assoc(lun,{gsc_region})

  region_list = ''
  for row = 0, rows-1 do begin
    ; For each row in the gsc_region_table
    region_table = gsc_region_table[row]

    ; Declination range of the GS region
    ; Note:  southern dechi and declow are reversed
    dechi = region_table.DEC_HI
    byteorder, dechi, /XDRTOF

    if (dechi gt 0 and dechi lt dec1) then begin
      goto,next
    endif else if (dechi lt 0 and dechi gt dec2) then begin
      goto,next
    endif

    ; Limit of GS region closer to equator
    declow = region_table.DEC_LO
    byteorder, declow, /XDRTOF

    if (declow gt 0) then begin
      ; North
      if (declow gt dec2) then goto,next
    endif else if (declow lt 0) then  begin
      ; South
      if (declow le dec1) then goto, next
    endif else begin
      ; Lower limit of GS region ON equator
      if (dechi gt 0) then begin
        ; North
        if (dechi lt dec1 or declow gt dec2) then goto, next
      endif else if (dechi < 0) then begin
        ; South
        if (dechi gt dec2 or declow lt dec1) then goto, next
      endif
    endelse

    ; Right ascension range of the GS region
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
    zone = gsc_fzone (declow, dechi)

    ; Build the file name
    root = string(format='(i4.4,".str")',regnum)

    path = string(format='(a,"/",a,"/")',path_gsc,zdir(zone-1))
    if(!VERSION.OS eq 'vms') then $
     begin
      len = strlen(path_gsc)
      lastchar = strmid(path_gsc,len-1,1)
      if(lastchar eq ']') then path = $
       strmid(path_gsc,0,len-1) + "." + zdir(zone-1) + "]"
      if(lastchar eq ':') then path = $
       path_gsc + "[" + zdir(zone-1) + "]"
      if(lastchar eq '.') then path = $
       path_gsc + zdir(zone-1) + "]"
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
;
; Given a GSC region filename, load the stars that fit within
; region (ra1 - ra2) and (dec1 - dec2) into a star descriptor.
;-
;===============================================================================
function gsc_get_stars, filename, $
         b1950=b1950, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, nbright=nbright, $
         names=names, mag=mag, jtime=jtime
       
 f = findfile(filename)
 if(f[0] eq '') then $
  begin
   print, 'gsc_get_stars: File does not exist - ',filename
   return, ''
  end

 ;----------------------------------------------
 ; Open file, expected name ends with "nnnn.str"
 ; where nnnn is the gsc region
 ;----------------------------------------------
 start = strpos(filename,'.str') - 4
 gsc_region = strmid(filename,start,4)
 openr, gsc_unit, filename, /get_lun
 info = fstat(gsc_unit)
 nstars = info.size/16
 stars = replicate({gsc_record},nstars)
 readu, gsc_unit, stars
 close, gsc_unit
 free_lun, gsc_unit

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
 Mag = stars.MAG
 ID = stars.GSC_ID
 CLASS = stars.CLASS
 byteorder, RA_DEG, /XDRTOF
 byteorder, DEC_DEG, /XDRTOF
 byteorder, Mag, /XDRTOF
 byteorder, ID, /NTOHS
 byteorder, CLASS, /NTOHS

 ;------------------------------------------------------------------
 ; If limits are defined, remove stars that fall outside the limits
 ; Limits in deg, Assumes RA's + DEC's in J2000 (B1950 if /b1950)
 ;------------------------------------------------------------------
; *** need to use strcat_radec_regions (see strcat_tycho2_input) ***
 if(keyword__set(dec1) and keyword__set(dec2)) then $
   begin
    subs = where(DEC_DEG ge dec1 and DEC_DEG le dec2, count)
    if(count eq 0) then return, ''
    RA_DEG = RA_DEG[subs]
    DEC_DEG = DEC_DEG[subs]
    Mag = Mag[subs]
    ID = ID[subs]
    CLASS = CLASS[subs]
    stars = stars[subs]
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
    Mag = Mag[subs]
    ID = ID[subs]
    CLASS = CLASS[subs]
    stars = stars[subs]
   end

 RA = RA_DEG*!DPI/180d0
 DEC = DEC_DEG*!DPI/180d0
 gsc_id = STRING(ID+100000)
 gsc_id = strmid(strtrim(gsc_id,2),1,5) 
 Name = "GSC " + gsc_region + " " + gsc_id
 Sp = strtrim(STRING(CLASS),2)

 ;-----------------------------------------------------------
 ; if desired, select only nbright brightest stars
 ;-----------------------------------------------------------
 if(keyword__set(nbright)) then $
  begin
   mag = stars.mag
   byteorder, mag, /XDRTOF
   w = strcat_nbright(mag, nbright)
   stars = stars[w]
  end

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
 print, 'Total of ',n,' stars out of ',nstars,' in GSC region ',gsc_region
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
 pos = make_array(3,n,value=0d)
 pos[0,*] = cos(RA)*cos(DEC)*dist
 pos[1,*] = sin(RA)*cos(DEC)*dist
 pos[2,*] = sin(DEC)*dist

 ;-----------------------------------------------------
 ; Precess J2000 to B1950 if wanted
 ;-----------------------------------------------------
 if(keyword__set(b1950)) then pos = $
  transpose(b1950_to_j2000(transpose(pos),/reverse))
 pos = reform(pos,1,3,n)

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
;=============================================================================



;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_gsc_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 return, strcat_input(dd, keyword, 'gsc', n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )

end
;=============================================================================



