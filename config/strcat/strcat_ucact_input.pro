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
;      -   strcat_ucact_input     -       /j2000    # or /b1950 if desired
; 
; For the star catalog translator system to work properly, only one type
; of catalog may be used at a time for a particular instrument.
;
; The UCACT catalog is a composite product of the UCAC2 and TYCHO star
; catalogs, and was compiled by Bill Owen. This catalog is proprietary to
; the Jet Propulsion Laboratory, and can be obtained by contacting either
; `Bill Owen <mailto: William.M.Owen@jpl.nasa.gov>`, or
; `Joseph Spitale <mailto: spitale@pirl.lpl.arizona.edu>`. The translator
; expects a file called ucact-c.cat, which contains the combined index and
; star data for the catalog in a binary format. The path to the catalog
; file is set by the NV_UCACT_DATA environment variable, which is specified
; during installation.
;
; Restrictions
; ============
;
; Since the distance to stars are not given in the UCACT catalog, the
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
; :Author:
;   Joseph Spitale, 3/2004
;   Jacqueline Ryan, 8/2016
;
;-

;+
; :Private:
; :Hidden:
;-
;===============================================================================
function ucact_get_regions, ra1, ra2, dec1, dec2, path_ucact=path_ucact
 return, path_ucact + '/ucact-c.cat'	; there's only one "region" file
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Performs conversion UCACT packed data type to correct units
; and values.
; 
; :Params:
;   packed_stars : in, required, type="`ucact_packed_star` array"
;     array of structs containing raw data of stars from binary
;     catalog file
;
; :Keywords:
;   ra : optional, type=double
;     right ascension is converted to degrees
;   dec : optional, type=double
;     declination is converted to degrees
;   _rapm : optional, type=double
;     proper motion is converted to degrees/year
;   _decpm : optional, type=double
;     proper motion is converted to degrees/year
;   mag : optional, type=double
;     magnitude is converted to W
;   px : optional, type=long
;     parallax
;   sp : optional, type=integer
;     sp does not contain the spectral type since this is not
;     available.  Instead it contains the UCACT class of the object:
;       0 - star
;       1 - galaxy
;       2 - blend or member of incorrectly resolved blend.
;       3 - non-star
;       5 - potential artifact
;
;     (Note that code 1 is used only for a few  hand-entered errata;
;      galaxies successfully processed by the software have a 
;      classification of 3 [non-stellar].  Also code 4 is never used.)
;   num : optional, type=long
;     UCACT number, this is neither the UCAC number nor the TYCHO number
;   epochra : optional, type=double
;     epoch of ra is converted to b1950 in absolute years (NOT years after 1950)
;   epochdec : optional, type=double
;     epoch of dec is converted to b1950 in absolute years (NOT years after 1950)
;   
;-
;===============================================================================
pro ucact_unpack_stars, packed_stars, $
  ra=ra, dec=dec, _rapm=rapm, _decpm=decpm, mag=mag, px=px, sp=sp, num=num, $
  epochra=epochra, epochdec=epochdec

 ;---------------------------------------------------------
 ; ra, dec
 ;---------------------------------------------------------
 if(arg_present(ra)) then ra = packed_stars.ra / 268435456d * 180d/!dpi		    ; deg
 if(arg_present(dec)) then dec = packed_stars.dec / 268435456d * 180d/!dpi		; deg

 ;---------------------------------------------------------
 ; Proper motions
 ;---------------------------------------------------------
 if(arg_present(rapm)) then $
  begin
   xx = mvbits(packed_stars.rapm, 14, 18, 0)
   w = where(btest(xx,17))
   if(w[0] NE -1) then xx[w] = xx[w] OR 'fffc0000'xl
   rapm = xx / 2147483648d * 180d/!dpi			; deg/yr
  end

 if(arg_present(decpm)) then $
  begin
   xx = mvbits(packed_stars.decpm, 14, 18, 0)
   w = where(btest(xx,17))
   if(w[0] NE -1) then xx[w] = xx[w] OR 'fffc0000'xl
   decpm = xx / 2147483648d * 180d/!dpi			; deg/yr
  end

 ;---------------------------------------------------------
 ; Misc
 ;---------------------------------------------------------
 if(arg_present(mag)) then $
  begin
   xx = mvbits(packed_stars.pxmagsp, 8, 11, 0)
   mag = xx/100. - 2.
  end

 if(arg_present(px)) then $
  begin
   xx = mvbits(packed_stars.pxmagsp, 19, 13, 0)
   px = xx/10000.
  end

 if(arg_present(sp)) then $
  begin
   sp1 = byte(mvbits(packed_stars.pxmagsp, 0, 8, 0))
   sp2 = byte(mvbits(packed_stars.DM, 0, 8, 0))
   sp3 = byte(mvbits(packed_stars.num, 0, 8, 0))
   sp = string([tr(sp1), tr(sp2), tr(sp3)])
  end

 if(arg_present(num)) then $
  begin
   xx = mvbits(packed_stars.num, 8, 24, 0)
   w = where(btest(xx,23))
   if(w[0] NE -1) then xx[w] = xx[w] OR 'ff000000'xl
   num = xx
  end

 if(arg_present(epochra)) then $
  begin
   xx = mvbits(packed_stars.epoch, 16, 16, 0)
   w = where(btest(xx,15))
   if(w[0] NE -1) then xx[w] = xx[w] OR 'ffff0000'xl
   epochra = xx/100d + 1950
  end

 if(arg_present(epochdec)) then $
  begin
   xx = mvbits(packed_stars.epoch, 0, 16, 0)
   w = where(btest(xx,15))
   if(w[0] NE -1) then xx[w] = xx[w] OR 'ffff0000'xl
   epochdec = xx/100d + 1950
  end
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Ingests a set of records from the UCACT star catalog and generates star 
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
function ucact_get_stars, dd, filename, $
         b1950=b1950, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, nbright=nbright, $
         names=names, mag=mag, jtime=jtime

 f = file_search(filename)
 if(f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + filename
   return, ''
  end

 ;---------------------------------------------------------
 ; Probe byte order
 ;---------------------------------------------------------
 b = 1l
 byteorder, b, /htonl
 swap = (b EQ 1)

 ;---------------------------------------------------------
 ; Open file 
 ;---------------------------------------------------------
 openr, unit, filename, /get_lun

 ;---------------------------------------------------------
 ; Read header
 ;---------------------------------------------------------
 hrec = assoc(unit, {ucact_header})
 header = hrec[0]

 ;---------------------------------------------------------
 ; Read zone directories
 ;---------------------------------------------------------
 point_lun, -unit, pos
 zrec = assoc(unit, replicate({ucact_directory},180), pos)
 zones = zrec[0]
 if(swap) then zones = swap_endian(zones)

 ;---------------------------------------------------------
 ; Build a list of star records
 ;---------------------------------------------------------
 point_lun, -unit, pos
 srec = assoc(unit, {ucact_record}, pos)

 _z1 = round(90-dec1)
 _z2 = round(90-dec2)
 z1 = min([_z1,_z2])
 z2 = max([_z1,_z2])
 z = lindgen((z2-z1+2)>1) + z1 - 1
 nz = n_elements(z)

; *** need to use strcat_radec_regions (see strcat_tycho2_input) ***
 for i=0, nz-1 do $
  begin
   ;-------------------------------------------------------
   ; Starting ra for each star record in this zone
   ;-------------------------------------------------------
   ra_start = double(zones[z[i]].ra_start[0:zones[z[i]].numrec-1]) / $
                                                      268435456d * 180d/!dpi

   ;-------------------------------------------------------
   ; Number of first (2560-byte) star record in this zone
   ;-------------------------------------------------------
   rec_start = zones[z[i]].rec_start - zones[0].rec_start
   if(rec_start[0] NE -1) then $
    begin
     w1 = max(where(ra1 GE ra_start))
     w2 = min(where(ra2 LE ra_start))
     if(w2[0] EQ -1) then w2 = n_elements(ra_start)-1
     w = lindgen(w2-w1+1) + w1
     nw = n_elements(w)

     ;-----------------------------------------------------
     ; Extract selected records
     ;-----------------------------------------------------
     ps = replicate({ucact_packed_star}, nw*71)
     ns = 0
     for j=0, nw-1 do $
      begin
       recnum = rec_start+w[j]
       if(recnum LE 686945) then $
        begin
         record = srec[recnum]
         if(swap) then record = swap_endian(record)

         ps[ns:ns+record.nstars-1] = record.stars[0:record.nstars-1]
         ns = ns + record.nstars
        end
      end

     if(ns GT 0) then $
      begin
       ps = ps[0:ns-1]

       ;---------------------------------------------------
       ; Select stars within magnitude limits
       ;---------------------------------------------------
       mag = ''
       if(keyword_set(faint)) then $
        begin
         ucact_unpack_stars, ps, mag=mag
         w = where(mag LE faint)
         if(w[0] NE -1) then $
          begin
           ps = ps[w]
           mag = mag[w]
          end else ps = (mag = 0)
        end

       if(keyword_set(bright)) then $
        begin
         if(NOT keyword_set(mag)) then ucact_unpack_stars, ps, mag=mag
         w = where(mag GE bright)
         if(w[0] NE -1) then $
          begin
           ps = ps[w]
           mag = mag[w]
          end else ps = (mag = 0)
        end

       ;---------------------------------------------------
       ; If desired, select only nbright brightest stars
       ;---------------------------------------------------
       if(keyword_set(nbright)) then $
        begin
         nps = n_elements(ps)
         if(NOT keyword_set(mag)) then ucact_unpack_stars, ps, mag=mag
         ss = sort(mag)
         ps = (ps[ss])[0:(nbright<nps)-1]
        end

        ;--------------------------------------------------
        ; add stars 
        ;--------------------------------------------------
        packed_stars = append_array(packed_stars, ps)
      end
    end
  end

 ;-------------------------------------------
 ; close file
 ;-------------------------------------------
 close, unit
 free_lun, unit
 
 ;---------------------------------------------------------
 ; unpack star records from binary format
 ;---------------------------------------------------------
 if(NOT keyword_set(packed_stars)) then return, ''
 ucact_unpack_stars, packed_stars, $
  ra=stars_ra, dec=stars_dec, _rapm=stars_rapm, _decpm=stars_decpm, $
  mag=stars_mag, px=stars_px, sp=stars_sp, num=stars_num, $
  epochra=stars_epochra, epochdec=stars_epochdec

 nstars = n_elements(stars_ra)
 stars = replicate({ucact_star}, nstars)
 stars.ra = stars_ra
 stars.dec = stars_dec
 stars.rapm = stars_rapm
 stars.decpm = stars_decpm
 stars.mag = stars_mag
 stars.px = stars_px
 stars.sp = stars_sp
 stars.num = stars_num
 stars.epochra = stars_epochra
 stars.epochdec = stars_epochdec


 ;---------------------------------------------------------
 ; If limits are defined, remove stars that fall outside
 ; the limits. Limits in deg, Assumes RA's + DEC's in 
 ; J2000 (B1950 if /b1950)
 ;---------------------------------------------------------
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

 ;---------------------------------------------------------
 ; Apply proper motion to star 
 ; jtime = years past 2000.0
 ; rapm and decpm = degrees per year
 ;---------------------------------------------------------
 stars.ra = stars.ra + stars.rapm*(jtime-(stars.epochra-2000))
 stars.dec = stars.dec + stars.decpm*(jtime-(stars.epochdec-2000))

 ;---------------------------------------------------------
 ; work in radians now
 ;---------------------------------------------------------
 stars.ra = stars.ra * !dpi/180d
 stars.dec = stars.dec * !dpi/180d
 stars.rapm = stars.rapm * !dpi/180d
 stars.decpm = stars.decpm * !dpi/180d

 ;---------------------------------------------------------
 ; if desired, select only nbright brightest stars
 ;---------------------------------------------------------
 if(keyword_set(nbright)) then $
  begin
   mag = stars.mag
   w = strcat_nbright(mag, nbright)
   stars = stars[w]
  end

 name = 'UCACT ' + strtrim(string(stars.num), 2)


 ;---------------------------------------------------------
 ; Select explicitly named stars
 ;---------------------------------------------------------
 if(keyword_set(names)) then $
  begin
   w = where(names EQ name)
   if(w[0] NE -1) then _stars = stars[w]
   if(NOT keyword__set(_stars)) then return, ''
   stars = _stars
   name = name[w]
  end

 n = n_elements(stars)
 print, 'Total of ',n,' stars.'
 if(n eq 0) then return, ''

 ;---------------------------------------------------------
 ; Calculate "dummy" properties
 ;---------------------------------------------------------
 orient = make_array(3,3,n)
 _orient = [ [1d,0d,0d], [0d,1d,0d], [0d,0d,1d] ]
 for j = 0 , n-1 do orient[*,*,j] = _orient
 avel = make_array(1,3,n,value=0d)
 vel = make_array(1,3,n,value=0d)
 time = make_array(n,value=0d)
 radii = make_array(3,n,value=1d)
 lora = make_array(n, value=0d)


 ;---------------------------------------------------------
 ; Calculate position vector, use a very large distance 
 ; since parallax is not known for this catalog.
 ;---------------------------------------------------------
 ; 3 orders of magnitude larger than the diameter of the milky way in km
 dist = make_array(n,val=1d21)	

 ;---------------------------------------------------------
 ; if parallax is known, then compute the actual distance
 ;---------------------------------------------------------
 w = where(stars.px NE 0)
 if(w[0] NE -1) then $
  begin
   px_rad = stars[w].px / 3600d * !dpi/180d
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
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_ucact_input, dd, keyword, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

 ndd = n_elements(dd)
 for i=0, ndd-1 do $
  begin
  _sd = strcat_input(dd[i], keyword, 'ucact', values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )
   sd = append_array(sd, _sd)
  end

 return, sd
end
;===============================================================================
