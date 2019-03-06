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
function tycho2_get_regions, parm
  return, parm.path + '/index.dat'
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
function tycho2_get_stars, dd, filename, parm

 ;-----------------------------------------------------------------
 ; Decide whether to proceed based on FOV, magnitude constraints
 ;-----------------------------------------------------------------
 status = strcat_check(2.5d6, [0,2*!dpi], [-1,1]*!dpi/2, 12, -1.5, parm)
 if(keyword_set(status)) then $
  begin
   nv_message, verb=0.2, 'Skipping catalog.'
   return, ''
  end

 ;-----------------------------------------------------------------
 ; Search for index file
 ;-----------------------------------------------------------------
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
 reg = strcat_radec_regions([parm.ra1, parm.ra2]*!dpi/180d, [parm.dec1, parm.dec2]*!dpi/180d, $
	  index.RAmin*!dpi/180d, index.RAmax*!dpi/180d, $
	  index.DEmin*!dpi/180d, index.DEmax*!dpi/180d)
; if(n_elements(regions) GT ...) then $
;  begin
;   nv_message, '...'
;   return, ''
;  end


 ;---------------------------------------------------------
 ; Open the catalog file, known bug: will break if 
 ; the value of path_tycho2 is changed from the default
 ;---------------------------------------------------------
 cat_fname = getenv('NV_TYCHO2_DATA') + '/tyc2.dat'
 f = file_search(cat_fname)
 if(f[0] EQ '') then nv_message, 'File does not exist - ' + cat_fname
 
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
 stars = strcat_tycho2_values(recs)

 return, stars
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_tycho2_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords


 return, strcat_input(dd, keyword, 'tycho2', n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords )

end
;===============================================================================
