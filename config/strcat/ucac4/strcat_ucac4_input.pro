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
function ucac4_get_regions, parm
 return, parm.path + '/u4index.asc'	; there's only one "region" file
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
function ucac4_get_stars, dd, filename, parm

 sep = path_sep()

 ;---------------------------------------------------------
 ; check whether catalog falls within brightness limits
 ;---------------------------------------------------------
 if(finite(parm.faint)) then if(parm.faint LT 8) then return, ''
 if(finite(parm.bright)) then if(parm.bright GT 16) then return, ''


 f = file_search(filename)
 if(f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + filename
   return, ''
  end

 ; Determine ra bins (j) between 1 and 1440
 jmin = floor(parm.ra1 * 4)
 jmax = ceil(parm.ra2 * 4) + 1
 ; Determine dec zones (zn) between 1 and 900
 zmin = floor(parm.dec1 * 5) + 450
 zmax = ceil(parm.dec2 * 5) + 450 
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
 stars = strcat_ucac4_values(recs)

; href = recs.rnm			;;; for look-up in hipsupl.dat
;                                        ;;; not implemented yet

 return, stars
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_ucac4_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 ndd = n_elements(dd)
 for i=0, ndd-1 do $
  begin
  _sd = strcat_input(dd[i], keyword, 'ucac4', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords )
   sd = append_array(sd, _sd)
  end

 return, sd
end
;===============================================================================
