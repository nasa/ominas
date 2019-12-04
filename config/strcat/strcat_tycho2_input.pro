;===============================================================================
; docformat = 'rst'
;+
;
; Input translator for TYCHO-2 star catalog.
; 
; Usage
; =====
; This routine is called via `dat_get_value`, which is used to read the
; translator table. In particular, the specific translator for the scene
; to be processed should contain the following line::
;
;      -   strcat_tycho2_input     -       /j2000    # or /b1950 if desired 
; 
; For the star catalog translator system to work properly, only one type
; of catalog may be used at a time for a particular instrument.
;
; The version of the TYCHO-2 catalog which is expected by this translator
; can be obtained from the `CDS Strasbourg database <ftp://cdsarc.u-strasbg.fr/pub/cats/I/259/>`.
; The twenty individual catalog files should be concatenated into a single
; file named tyc2.dat, as per the provided instructions. Another required
; file is the index.dat, which is provided on the same webpage. The path
; to the catalog files is specified by the NV_TYCHO2_DATA environment
; variable, which is set during installation.
;
; Please note that the version of TYCHO-2 in EK format which is distributed
; by NAIF is not supported by this translator.
;
; Restrictions
; ============
;
; Since the distance to stars are not given in the TYCHO-2 catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
; Procedure
; =========
;
; Stars are found in a square area in RA and DEC around a given
; or calculated center.  The star descriptor is filled with stars
; that fit in this area.  If B1950 is selected, input sd's orient 
;	matrix is assumed to be B1950 also, if not, input is assumed to
; be J2000, like the catalog.
;
; :Categories:
;   nv, config
;
; :Author:
;   Joseph Spitale, 3/2004
;
;   Jacqueline Ryan, 8/2016
;
;-
;===============================================================================

;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function tycho2_get_regions, ra1, ra2, dec1, dec2, path_tycho2=path_tycho2
  return, path_tycho2 + '/index.dat'
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
;      Years since 2000 (the epoch of catalog) for precession
;      and proper motion correction. If not given, it is taken
;      from the object descriptor bod_time, which is assumed to
;      be seconds past 2000, unless keyword /b1950 is set
;-
;===============================================================================
function tycho2_get_stars, dd, filename, $
         b1950=b1950, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, nbright=nbright, $
         names=names, mag=mag, jtime=jtime

 ndx_f = file_search(filename)
 if(ndx_f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + filename
   return, ''
  end
 
 ;---------------------------------------------------------
 ; Read the index file into a list of index entries
 ; The format for these entries is specified in the
 ; TYCHO-2 guide.pdf, Table 3
 ;---------------------------------------------------------
 nl = file_lines(filename)
 format = '(I7,1X,I6,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2)'
 index = replicate({tycho2_index}, nl)
 openr, ndx_lun, filename, /get_lun
 readf, ndx_lun, index, format=format
 close, ndx_lun
 free_lun, ndx_lun

 ;---------------------------------------------------------
 ; Find the tycho regions that the scene occupies
 ;---------------------------------------------------------
; reg = where(index.DEmax ge dec1 and index.DEmin le dec2 and index.RAmax ge ra1 and index.RAmin le ra2)
 reg = strcat_radec_regions( [ra1, ra2]*!dpi/180d, [dec1, dec2]*!dpi/180d, $
	  index.RAmin*!dpi/180d, index.RAmax*!dpi/180d, $
	  index.DEmin*!dpi/180d, index.DEmax*!dpi/180d)

 ;---------------------------------------------------------
 ; Open the catalog file, known bug: will break if 
 ; the value of path_tycho2 is changed from the default
 ;---------------------------------------------------------
 cat_fname = getenv('NV_TYCHO2_DATA') + '/tyc2.dat'
 f = file_search(cat_fname)
 if(f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + cat_fname
  end
 
 ;---------------------------------------------------------
 ; Organize the regions to be read from the file 
 ;---------------------------------------------------------
 n_reg = n_elements(reg)
 linarr = lindgen(n_reg, 2)
 linarr[*, 0] = index[reg].rec_t2
 linarr[*, 1] = index[reg+1].rec_t2
 linarr = reform(linarr[sort(linarr)], [2, n_reg])

 ;---------------------------------------------------------
 ; Catalog record format from TYCHO-2 guide.pdf, Table 1
 ;---------------------------------------------------------
 cat_format = '(I4.4,1X,I5.5,1X,I1,1X,A1,1X,F12.8,1X,F12.8,1X,F7.1,1X,F7.1,1X,I3,1X,I3,1X,'+ $
 'F4.1,1X,F4.1,1X,F7.2,1X,F7.2,1X,I2,1X,F3.1,1X,F3.1,1X,F3.1,1X,F3.1,1X,F6.3,1X,'+ $
 'F5.3,1X,F6.3,1X,F5.3,1X,I3,1X,A1,1X,I6,A3,1X,F12.8,1X,F12.8,1X,F4.2,1X,F4.2,1X,'+ $
 'F5.1,1X,F5.1,1X,A1,1X,F4.1)'

 ;---------------------------------------------------------
 ; Move to location of first region and initialize loop
 ; var.
 ;---------------------------------------------------------
 openr, cat_lun, cat_fname, /get_lun
 skip_lun, cat_lun, linarr[0,0] - 1, /lines
 end_prev = linarr[0,0]

 ;---------------------------------------------------------
 ; Compile a list of star records region by region
 ;---------------------------------------------------------
 recs = [ ]
 for n = 0, n_reg - 1 do $
  begin
   n_recs = linarr[1, n] - linarr[0, n] - 1
   reg_recs = replicate({tycho2_record}, n_recs)
   skip_lun, cat_lun, linarr[0, n] - end_prev, /lines
   readf, cat_lun, reg_recs, format=cat_format
   recs = [recs, reg_recs]
   end_prev = linarr[1, n]
  endfor
 close, cat_lun
 free_lun, cat_lun

 ;---------------------------------------------------------
 ; Convert catalog data format to standardized format
 ;---------------------------------------------------------
 nstars = n_elements(recs)
 stars = replicate({tycho2_star}, nstars)
 stars.ra = recs.mRAdeg                     ; mean j2000 ra in deg
 stars.dec = recs.mDEdeg                    ; mean j2000 dec in deg
 stars.rapm = recs.pmRA / 3600000d          ; mas/yr -> deg/yr
 stars.decpm = recs.pmDE / 3600000d         ; mas/yr -> deg/yr
 stars.mag = recs.VT                        ; approximately equivalent to visual mag.
 stars.px = 0                               ; parallax is not known
 stars.num = strtrim(string(recs.tyc1), 2)+'-'+strtrim(string(recs.tyc2), 2)+'-'+strtrim(string(recs.tyc3), 2)
 stars.epochra = recs.mepRA
 stars.epochdec = recs.mepDE

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

 ;--------------------------------------------------------
 ; Apply proper motion to stars
 ; jtime = years past 2000.0
 ; rapm and decpm = degrees per year
 ;--------------------------------------------------------
 stars.ra = stars.ra + stars.rapm * jtime
 stars.dec = stars.dec + stars.decpm * jtime

 ;---------------------------------------------------------
 ; Work in radians now
 ;---------------------------------------------------------
 stars.ra = stars.ra * !dpi/180d
 stars.dec = stars.dec * !dpi/180d
 stars.rapm = stars.rapm * !dpi/180d
 stars.decpm = stars.decpm * !dpi/180d

 ;---------------------------------------------------------
 ; If desired, select only nbright brightest stars
 ;---------------------------------------------------------
 if(keyword_set(nbright)) then $
  begin
   mag = stars.mag
   w = strcat_nbright(mag, nbright)
   stars = stars[w]
  end

 name = 'TYC ' + stars.num


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
 radec = transpose([transpose([stars.ra]), transpose([stars.dec]), transpose([dist])])
 pos = transpose(bod_radec_to_body(bod_inertial(), radec))


 ;---------------------------------------------------------
 ; Compute skyplane velocity from proper motion 
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
function strcat_tycho2_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 return, strcat_input(dd, keyword, 'tycho2', n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )

end
;===============================================================================
