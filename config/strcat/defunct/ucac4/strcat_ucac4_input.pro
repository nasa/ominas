;===============================================================================
; docformat = 'rst'
;+
;
; Input translator for ucact-c star catalog compiled by Bill Owen.
;
; Usage
; =====
; This routine is called via `dat_get_value`, which is used to read the
; translator table. In particular, the specific translator for the scene
; to be processed should contain the following line::
;
;      -   strcat_ucac4_input     -       /j2000    # or /b1950 if desired
; 
; For the star catalog translator system to work properly, only one type
; of catalog may be used at a time for a particular instrument.
;
; The UCAC4 catalog is the final release version of the USNO CCD Astrograph
; Catalog. The version of the catalog which is expected by this catalog was
; obtained from the `CDS Strasbourg database <ftp://cdsarc.u-strasbg.fr/pub/cats/more/UCAC4/u4b/>`.
; Each of the 900 zone files is required. Additionally, there is an 
; `ASCII index file <ftp://cdsarc.u-strasbg.fr/pub/cats/more/UCAC4/u4i/>`
; named u4index.asc, which is used to determine which zone files to load.
;
; Restrictions
; ============
;
; Since the distance to stars are not given in the UCAC4 catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
; Procedure
; =========
;
; Stars are found in a square area in RA and DEC around a given
; or calculated center.  The star descriptor is filled with stars
; that fit in this area.  If B1950 is selected, input sd's orient 
; matrix is assumed to be B1950 also, if not, input is assumed to
; be J2000, like the catalog.
;
; :Categories:
;   nv, config
;   
; :Version:
;    Incomplete
;
; :Author:
;   Jacqueline Ryan, 8/2016
;   Modified  Vance Haemmerle, 8/2017
;   
;-

;+
; :Private:
; :Hidden:
;-
;===============================================================================




;===============================================================================
; ucac4_get_regions
;
;===============================================================================
function ucac4_get_regions, ra1, ra2, dec1, dec2, path_ucac4=path_ucac4
 return, path_ucac4 + '/u4index.asc'	; there's only one "region" file
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Ingests a set of records from the UCAC4 star catalog and generates star
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
;      Years since 2000 (the epoch of catalog) for precession
;      and proper motion correction. If not given, it is taken
;      from the object descriptor bod_time, which is assumed to
;      be seconds past 2000, unless keyword /b1950 is set
;-
;===============================================================================
function ucac4_get_stars, dd, filename, $
         b1950=b1950, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, nbright=nbright, $
         names=names, mag=mag, jtime=jtime

 sep = path_sep()

 ;---------------------------------------------------------
 ; check whether catalog falls within brightness limits
 ;---------------------------------------------------------
 if(keyword_set(faint)) then if(faint LT 8) then return, ''
 if(keyword_set(bright)) then if(bright GT 16) then return, ''

 print, filename
 f = file_search(filename)
 if(f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + filename
   return, ''
  end

 ;---------------------------------------------------------
 ; For range testing, need to have limits in j2000 since
 ; star positions in catalog are in j2000 
 ; If /b1950 is specified, then convert range to j2000
 ;---------------------------------------------------------
 _ra1 = ra1
 _ra2 = ra2
 _dec1 = dec1
 _dec2 = dec2
 if (keyword_set(b1950)) then $
   begin
     ; If ra1/ra2 is entire range then do not change
     ; declination change is not enough to update
     if (ra1 NE 0. OR ra2 NE 360.) then $
       begin
         nv_message, verb=0.9, 'Converting RA/DEC to J2000 (catalog epoch) for range testing'
         ra_to_xyz, ra1, dec1, pos1
         ra_to_xyz, ra2, dec2, pos2
         pos1_1950 = b1950_to_j2000(pos1)
         pos2_1950 = b1950_to_j2000(pos2)
         xyz_to_ra, pos1_1950, _ra1, _dec1
         xyz_to_ra, pos2_1950, _ra2, _dec2
         if (_ra1 LT 0) then _ra1 = _ra1 + 360d
         if (_ra2 LT 0 ) then _ra2 = _ra2 + 360d
       end
   end
 nv_message, verb=0.9, '_ra1 = ' + strtrim(string(_ra1),2) + ', _ra2= ' + strtrim(string(_ra2),2)
 
 ; Determine ra bins (j) between 1 and 1440
 jmin = floor(_ra1 * 4)
 jmax = ceil(_ra2 * 4) + 1
 ; Determine dec zones (zn) between 1 and 900
 zmin = floor(_dec1 * 5) + 450
 zmax = ceil(_dec2 * 5) + 450 
 nz = zmax - zmin
 nv_message, verb=0.9, 'RA zones is ' + string(jmin) + ' to ' + string(jmax)
 
 openr, index, filename, /get_lun
 skip_lun, index, 1440 * zmin + jmin, /line
 line = ''
 bounds = intarr(2, nz)
 rec_bytes = 78
 recs = [ ]
 for i = 0, nz do $
  begin
   readf, index, line
   first = long(strmid(line, 0, 6))
   nv_message, verb=1.0, 'first line is ' + line
   skip_lun, index, jmax - jmin - 1, /line
   readf, index, line
   last = long(strmid(line, 0, 6))
   seg = strmid(line, 14, 4)
   nv_message, verb=1.0, 'last line is ' + line
   skip_lun, index, 1439 - jmax + jmin, /line
   nv_message, verb=0.9, 'RA bounds for zone ' + string(zmin+i) + ' is ' + string(first) + ',' + string(last)

   z_fname = 'z' + string(zmin + i, format='(I03)')
   z_strs = last - first
   z_recs = replicate({ucac4_record}, z_strs)
   openr, zone, getenv('NV_UCAC4_DATA') + sep + z_fname, /get_lun
   point_lun, zone, first * rec_bytes
   nv_message, verb=0.9, 'Reading ' + string(z_strs) + ' stars from zone file ' + getenv('NV_UCAC4_DATA') + sep + z_fname 
   readu, zone, z_recs
   ; store components of name, zone(zzz) and record number (nnnnnn) in pts_key
   ; star name is ucac4-zzz-nnnnnn
   z_zone = zmin + i
   z_number = indgen(z_strs) + first + 1
   z_recs.pts_key = z_zone*1000000 + z_number
   recs = [recs, z_recs]
   close, zone
   free_lun, zone
  endfor
 close, index
 free_lun, index
 
 ;-----------------------------------
 ; catalog is in little endian
 ;-----------------------------------
 recs = swap_endian(recs,/SWAP_IF_BIG_ENDIAN)

 mas_deg = 3600000d

; see http://ad.usno.navy.mil/ucac/readme_u4v5...
 nstars = n_elements(recs)
 stars = replicate({ucac4_star}, nstars)
 stars.ra = recs.ra / mas_deg                           ; mas -> deg 
 stars.dec = (recs.spd / mas_deg) - 90d                 ; mas above south pole -> deg declination
 cosdec = cos(stars.dec * (!dpi / 180d)) * (180d / !dpi) 
 stars.rapm = recs.pmrac / (cosdec * mas_deg) /10. ; pmRA * cos(dec) [0.1 mas/yr] -> pmRA [deg/yr]
 stars.decpm = recs.pmdc / mas_deg /10.
 stars.mag = recs.apasm[1]/1000.

;;;		 stars.px = stars_px	;; look up in hipsupl.dat
;;;		 stars.sp = recs.objt	;; not in record
 stars.num = recs.pts_key		;;; zzznnnnnn for star names
;;; stars.epochra = recs.cepra
;;; stars.epochdec = recs.cepdc
 href = recs.rnm			;;; for look-up in hipsupl.dat
                                        ;;; not implemented yet

 ;---------------------------------------------------------
 ; apply brightness thresholds
 ;---------------------------------------------------------
 if(keyword_set(faint)) then $
  begin
   w = where(stars.mag LE faint)
   if(w[0] EQ -1) then return, ''
   stars = stars[w]
  end
 if(keyword_set(bright)) then $
  begin
   w = where(stars.mag GE bright)
   if(w[0] EQ -1) then return, ''
   stars = stars[w]
  end

 ;-------------------------------------
 ; select named stars
 ; name according to section 3j of http://ad.usno.navy.mil/ucac/readme_u4v5
 ;-------------------------------------
 name = 'UCAC4 '+strtrim(string(stars.num/1000000,format='(I03)'),2)+'-'+strtrim(string(stars.num MOD 1000000,format='(I06)'),2)

 if(keyword_set(names)) then $
  begin
   w = where(names EQ name)
   if(w[0] NE -1) then _stars = stars[w]
   if(NOT keyword__set(_stars)) then return, ''
   stars = _stars
   name = name[w]
  end

 ;------------------------------------------------------------------
 ; If limits are defined, remove stars that fall outside the limits
 ; Limits in deg, Assumes RA's + DEC's in J2000 (B1950 if /b1950)
 ;------------------------------------------------------------------
 w = strcat_radec_select([_ra1, _ra2]*!dpi/180d, [_dec1, _dec2]*!dpi/180d, $
                                     stars.ra*!dpi/180d, stars.dec*!dpi/180d)
 if(w[0] EQ -1) then return, ''
 stars = stars[w]
 name = name[w]

 ;-----------------------------------------------------------
 ; if desired, select only nbright brightest stars
 ;-----------------------------------------------------------
 if(keyword_set(nbright)) then $
  begin
   mag = stars.mag
   w = strcat_nbright(mag, nbright)
   stars = stars[w]
   name = name[w]
  end

 ;--------------------------------------------------------
 ; Apply proper motion to star 
 ; jtime = years past 2000.0
 ; rapm and decpm = degrees per year
 ;--------------------------------------------------------
 _jtime = jtime
 if(keyword_set(b1950)) then _jtime = jtime - 50
 nv_message, verb=0.9, 'jtime used is ' + strtrim(string(_jtime),2)
 ;;stars.ra = stars.ra + stars.rapm*(_jtime-(stars.epochra-2000))
 ;;stars.dec = stars.dec + stars.decpm*(_jtime-(stars.epochdec-2000))
 stars.ra = stars.ra + stars.rapm*(_jtime)
 stars.dec = stars.dec + stars.decpm*(_jtime)

 ;-------------------------------------------
 ; work in radians now
 ;-------------------------------------------
 stars.ra = stars.ra * !dpi/180d
 stars.dec = stars.dec * !dpi/180d
 stars.rapm = stars.rapm * !dpi/180d
 stars.decpm = stars.decpm * !dpi/180d

 ;----------------------
 ; Fill star descriptors
 ;----------------------
 n = n_elements(stars)
 print, 'Total of ',n,' stars.'
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


 ;--------------------------------------------------------------------
 ; Calculate position vector, use a very large distance unless 
 ; parallax is known.
 ;--------------------------------------------------------------------
 dist = make_array(n,val=1d21)	
		; this is something like the diameter of the milky way

 ;--------------------------------------------------------
 ; if parallax is known, then compute the actual distance
 ;--------------------------------------------------------
 w = where(stars.px NE 0)
 if(w[0] NE -1) then $
  begin
   px_rad = stars[w].px / 3600d * !dpi/180d
;   dist[w] = 1.5d11 / tan(0.5d*px_rad) 
   dist[w] = 1.5d11 / tan(px_rad) 
  end

 radec = transpose([transpose([stars.ra]), transpose([stars.dec]), transpose([dist])])
 pos = transpose(bod_radec_to_body(bod_inertial(), radec))

 ;---------------------------------------------------------
 ; compute skyplane velocity from proper motion 
 ;---------------------------------------------------------
 radec_vel = transpose([transpose([stars.rapm]/86400d/365.25d), transpose([stars.decpm]/86400d/365.25d), dblarr(1,n)])
 vel = bod_radec_to_body_vel(bod_inertial(), radec, radec_vel)



 ;---------------------------------------------------------
 ; Precess J2000 to B1950 if desired
 ;---------------------------------------------------------
 if(keyword_set(b1950)) then pos = $
  transpose(b1950_to_j2000(transpose(pos),/reverse))
 pos = reform(pos,1,3,n)

 if(keyword_set(b1950)) then vel = $
  transpose(b1950_to_j2000(transpose(vel),/reverse))
 vel = reform(vel,1,3,n)


 ;---------------------------------------------------------
 ; Calculate "luminosity" from visual Magnitude using the 
 ; Sun as a model. If distance is unknown, lum will be 
 ; incorrect, but the magnitudes will work out.
 ;---------------------------------------------------------
 pc = const_get('parsec')
 Lsun = const_get('Lsun')
 m = stars.mag - 5d*alog10(dist/pc) + 5d
 lum = Lsun * 10.d^( (4.83d0-m)/2.5d ) 

 _sd = str_create_descriptors(n, $
        gd=make_array(n, val=dd), $
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

 mag = stars.mag

 return, _sd
end

;+
; :Private:
; :Hidden:
;-
function strcat_ucac4_input, dd, keyword, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

 ndd = n_elements(dd)
 for i=0, ndd-1 do $
  begin
  _sd = strcat_input(dd[i], keyword, 'ucac4', values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )
   sd = append_array(sd, _sd)
  end

 return, sd
end
;===============================================================================
