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
;   
;-

;+
; :Private:
; :Hidden:
;-
;===============================================================================
function ucac4_get_regions, ra1, ra2, dec1, dec2, path_ucac4=path_ucac4
 return, path_ucac4 + 'u4index.asc'	; there's only one "region" file
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
;      Years since 1950 (the epoch of catalog) for precession
;      and proper motion correction. If not given, it is taken
;      from the object descriptor bod_time, which is assumed to
;      be seconds past 2000, unless keyword /b1950 is set
;-
;===============================================================================
function ucac4_get_stars, dd, filename, $
         b1950=b1950, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, nbright=nbright, $
         names=names, mag=mag, jtime=jtime

 print, filename
 f = file_search(filename)
 if(f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + filename
   return, ''
  end
 
 ; Determine ra bins (j) between 1 and 1440
 jmin = floor(ra1 * 4)
 jmax = ceil(ra2 * 4)
 ; Determine dec zones (zn) between 1 and 900
 zmin = ceil(dec1 * 5) + 450
 zmax = ceil(dec2 * 5) + 450
 nz = zmax - zmin
 
 openr, index, filename, /get_lun
 skip_lun, index, 1440 * zmin + jmin, /lines
 line = ''
 bounds = intarr(2, nz)
 rec_bytes = 78
 recs = [ ]
 for i = 0, nz do $
  begin
   readf, index, line
   first = long(strmid(line, 0, 6))
   skip_lun, index, jmax - jmin - 1, /lines
   readf, index, line
   last = long(strmid(line, 0, 6))
   skip_lun, index, 1439 - jmax + jmin, /lines

   z_fname = 'z' + string(zmin + i, format='(I03)')
   z_strs = last - first
   z_recs = replicate({ucac4_record}, z_strs)
   openr, zone, getenv('NV_UCAC4_DATA') + z_fname, /get_lun
   point_lun, zone, first * rec_bytes
   readu, zone, z_recs
   recs = [recs, z_recs]
   close, zone
   free_lun, zone
  endfor
 close, index
 free_lun, index
 
 ;-----------------------------------
 ; probe byte order
 ;-----------------------------------
 ;b = 1l
 ;byteorder, b, /htonl
 ;swap = (b EQ 1)

 ;-----------------------------------
 ; open file 
 ;-----------------------------------
 ;openr, unit, filename, /get_lun

 ;-----------------------------------
 ; read header
 ;-----------------------------------
 ;hrec = assoc(unit, {ucac4_header})
 ;header = hrec[0]

 ;-----------------------------------
 ; read zone directories
 ;-----------------------------------
 ;point_lun, -unit, pos
 ;zrec = assoc(unit, replicate({ucac4_directory},180), pos)
 ;zones = zrec[0]
 ;if(swap) then zones = swap_endian(zones)

 ;-------------------------------------------
 ; build a list of star records
 ;-------------------------------------------
 ;point_lun, -unit, pos
 ;srec = assoc(unit, {ucac4_record}, pos)

;;; _z1 = fix(90-dec1)
;;; _z2 = fix(90-dec2)
 ;_z1 = round(90-dec1)
 ;_z2 = round(90-dec2)
 ;z1 = min([_z1,_z2])
 ;z2 = max([_z1,_z2])

; z = lindgen(z2-z1+1) + z1
; if(z1 EQ z2) then z = z1
;;; z = lindgen((z2-z1)>1) + z1
 ;z = lindgen((z2-z1+2)>1) + z1 - 1

 ;nz = n_elements(z)
 ;for i=0, nz-1 do $
 ; begin
;stop
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; starting ra for each star record in this zone
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ;  ra_start = double(zones[z[i]].ra_start[0:zones[z[i]].numrec-1]) / $
 ;                                                     268435456d * 180d/!dpi

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; number of first (2560-byte) star record in this zone
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; rec_start = zones[z[i]].rec_start - zones[0].rec_start
  ; if(rec_start[0] NE -1) then $
  ;  begin
;w1 = max(where(ra1 GE ra_start))
;w2 = min(where(ra2 LE ra_start))
;if(w2[0] EQ -1) then w2 = n_elements(ra_start)-1
;;;     w1 = min(where(ra_start GE ra1))
;;;     w2 = max(where(ra_start LE ra2) + 1) 
;stop
;     w = lindgen(w2-w1+1) + w1
;     nw = n_elements(w)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; extract selected records
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;     ps = replicate({ucac4_packed_star}, nw*71)
;     ns = 0
;     for j=0, nw-1 do $
;      begin
;       recnum = rec_start+w[j]
;       if(recnum LE 686945) then $
;        begin
;         record = srec[recnum]
;         if(swap) then record = swap_endian(record)
;
;         ps[ns:ns+record.nstars-1] = record.stars[0:record.nstars-1]
;         ns = ns + record.nstars
;        end
;      end

;     if(ns GT 0) then $
;      begin
;       ps = ps[0:ns-1]
;
       ;- - - - - - - - - - - - - - - - - - - -
       ; select stars within magnitude limits
       ;- - - - - - - - - - - - - - - - - - - -
;       mag = ''
;       if(keyword_set(faint)) then $
;        begin
;         ucac4_unpack_stars, ps, mag=mag
;         w = where(mag LE faint)
;         if(w[0] NE -1) then $
;          begin
;           ps = ps[w]
;           mag = mag[w]
;          end else ps = (mag = 0)
;        end
;
;       if(keyword_set(bright)) then $
;        begin
;         if(NOT keyword_set(mag)) then ucac4_unpack_stars, ps, mag=mag
;         w = where(mag GE bright)
;         if(w[0] NE -1) then $
;          begin
;           ps = ps[w]
;           mag = mag[w]
;          end else ps = (mag = 0)
;        end
;
       ;- - - - - - - - - - - - - - - - - - - -
       ; select brightest stars 
       ;- - - - - - - - - - - - - - - - - - - -
;       if(keyword_set(nbright)) then $
;        begin
;         nps = n_elements(ps)
;         if(NOT keyword_set(mag)) then ucac4_unpack_stars, ps, mag=mag
;         ss = sort(mag)
;         ps = (ps[ss])[0:(nbright<nps)-1]
;        end



        ;- - - - - - - - - - - - - - - - - - - -
        ; add stars 
        ;- - - - - - - - - - - - - - - - - - - -
;        packed_stars = append_array(packed_stars, ps)
;      end
;    end
;  end

 ;-------------------------------------------
 ; close file
 ;-------------------------------------------
 ;close, unit
 ;free_lun, unit
 
 ;-------------------------------------------
 ; unpack star records
 ;-------------------------------------------
 ;if(NOT keyword_set(packed_stars)) then return, ''
 ;ucac4_unpack_stars, packed_stars, $
 ; ra=stars_ra, dec=stars_dec, _rapm=stars_rapm, _decpm=stars_decpm, $
 ; mag=stars_mag, px=stars_px, sp=stars_sp, num=stars_num, $
 ; epochra=stars_epochra, epochdec=stars_epochdec

 nstars = n_elements(recs)
 stars = replicate({ucac4_star}, nstars)
 stars.ra = recs.ra / 3600000d                           ; mas -> deg 
 stars.dec = (recs.spd / 3600000d) - 90d                 ; mas above south pole -> deg declination
 cosdec = cos(stars.dec * (!dpi / 180d)) * (180d / !dpi) 
 stars.rapm = recs.pmrac / (cosdec * 3600000d)  ; pmRA * cos(dec) [mas/yr] -> pmRA [deg/yr]
 stars.decpm = recs.pmdc / 3600000d
 stars.mag = stars_mag
 stars.px = stars_px
 stars.sp = recs.objt
 stars.num = stars_num
 stars.epochra = stars_epochra
 stars.epochdec = stars_epochdec


 ;------------------------------------------------------------------
 ; If limits are defined, remove stars that fall outside the limits
 ; Limits in deg, Assumes RA's + DEC's in J2000 (B1950 if /b1950)
 ;------------------------------------------------------------------
; *** need to use strcat_radec_regions (see strcat_tycho2_input) ***
 if(keyword_set(dec1) AND keyword_set(dec2)) then $
   begin
    subs = where((stars.dec GE dec1) AND (stars.dec LE dec2), count)
    if(count EQ 0) then return, ''
    stars = stars[subs]
   end


 if(keyword_set(ra1) AND keyword_set(ra2)) then $
   begin
    subs = where((stars.ra GE ra1) AND (stars.ra LE ra2), count)
    if(count EQ 0) then return, ''
    stars = stars[subs]
   end

 ;--------------------------------------------------------
 ; Apply proper motion to star 
 ; jtime = years past 2000.0
 ; rapm and decpm = radians per year
 ;--------------------------------------------------------
 stars.ra = stars.ra + stars.rapm*(jtime-(stars.epochra-2000))
 stars.dec = stars.dec + stars.decpm*(jtime-(stars.epochdec-2000))

 ;-------------------------------------------
 ; work in radians now
 ;-------------------------------------------
 stars.ra = stars.ra * !dpi/180d
 stars.dec = stars.dec * !dpi/180d
 stars.rapm = stars.rapm * !dpi/180d
 stars.decpm = stars.decpm * !dpi/180d

 ;-----------------------------------------------------------
 ; if desired, select only nbright brightest stars
 ;-----------------------------------------------------------
 if(keyword_set(nbright)) then $
  begin
   mag = stars.mag
   w = strcat_nbright(mag, nbright)
   stars = stars[w]
  end

 ;-------------------------------------
 ; select named stars
 ;-------------------------------------
 file = file_search(getenv('OMINAS_DIR')+'/config/strcat/stars.txt')
 openr, lun, file, /get_lun
 line = ''
 linarr = strarr(file_lines(file), 7)
 i = 0
 while not eof(lun) do $
  begin
   readf, lun, line
   fields = strsplit(line, ';', /extract)
   linarr[i, *] = fields
   i = i + 1
  endwhile
 free_lun, lun
 
 n = n_elements(stars)
 matches = intarr(n)
 for i=0, n - 1 do matches[i] = where(strpos(linarr[*,2], stars[i].num) ne -1)
 name = 'ucac4 ' + strtrim(string(stars.num), 2)
 ndx = where(matches ne -1)
 matches = matches[ndx]
 for i = 0, n_elements(matches) - 1 do $
  begin
    lin_ndx = matches[i]
    if strtrim(linarr[lin_ndx, 1], 2) ne '-1' then name[ndx[i]] = linarr[lin_ndx, 1]
    if strtrim(linarr[lin_ndx, 0], 2) ne '-1' then name[ndx[i]] = linarr[lin_ndx, 0]
    print, name[ndx[i]]
  endfor
 
 if(keyword_set(names)) then $
  begin
   w = where(names EQ name)
   if(w[0] NE -1) then _stars = stars[w]
   if(NOT keyword__set(_stars)) then return, ''
   stars = _stars
   name = name[w]
  end

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

; pos = make_array(3,n,value=0d)
; pos[0,*] = cos(stars.ra)*cos(stars.dec)*dist
; pos[1,*] = sin(stars.ra)*cos(stars.dec)*dist
; pos[2,*] = sin(stars.dec)*dist

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
