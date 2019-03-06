;===============================================================================
; docformat = 'rst'
;+
;
; Input translator for idlastro queryvizier remote star catalog reader.
; 
; Usage
; =====
; This routine is called via `dat_get_value`, which is used to read the
; translator table. In particular, the specific translator for the scene
; to be processed should contain the following line::
;
;      -   strcat_vizier_input     -       /j2000    # or /b1950 if desired 
;
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
;   Joseph Spitale, 8/2018
;
;-
;===============================================================================



;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function vizier_get_regions, parm
  return, ''
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Queries the specified VIZIER catalog and generates star descriptors for 
; each star within a specified scene.
;
; :Returns:
;   array of star descriptors
;
; :Params:
;   dd : in, required, type="data descriptor"
;      data descriptor
;   filename : ignored
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
function vizier_get_stars, dd, filename, parm

 ;---------------------------------------------------------
 ; determine which catalog to query
 ;---------------------------------------------------------
 cat = dat_keyword_value(dd, 'catalog')
 if(NOT keyword_set(cat)) then $
  begin
   nv_message, /con, 'No star catalog specified.'
   return, 0
  end
 nv_message, verb=0.1, 'Catalog is ' + cat + '.'

 value_fn = 'strcat_'  + strlowcase(cat) + '_values'
 if(NOT routine_exists(value_fn)) then $
   nv_message, 'Cannot translate catalog ' + cat + ' because no value function exists.'

 constraint_fn = 'strcat_' + strlowcase(cat) + '_constraint'
 if(NOT routine_exists(constraint_fn)) then $
   nv_message, /warning, $
      'No constraint function for catalog ' + cat + '.  Proceeding with no filtering.'


 ;---------------------------------------------------------
 ; set up query geometry
 ;---------------------------------------------------------
 radec = strcat_radec_box([parm.ra1, parm.ra2]*!dpi/180d, [parm.dec1, parm.dec2]*!dpi/180d, $
                                                 dradec=dradec, radius=radius)

 ;---------------------------------------------------------
 ; get constraints
 ;---------------------------------------------------------
 if(routine_exists(constraint_fn)) then $
     constraint = call_function(constraint_fn, faint=parm.faint, bright=parm.bright, names=names)

 ;---------------------------------------------------------
 ; query catalog
 ;---------------------------------------------------------
 recs = queryvizier(cat, radec[0:1]*180d/!dpi, dradec[0:1]*180d/!dpi*60, constraint=constraint)
; recs = queryvizier(cat, radec[0:1]*180d/!dpi, radius*180d/!dpi*60, constraint=constraint)


 ;---------------------------------------------------------
 ; get values in standard  form
 ;---------------------------------------------------------
 stars = call_function(value_fn, recs)

 return, stars
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_vizier_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords


 return, strcat_input(dd, keyword, '+vizier', n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords )

end
;===============================================================================
