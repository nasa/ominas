;=============================================================================
;+
; NAME:
;	strcat_input
;
;
; PURPOSE:
;	Generic star catalog input translator core.  This routine is not an 
;	OMINAS input translator; it is intended to be called by an input
;	translator that is taylored to a specific catalog. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = strcat_input(dd, keyword, cat)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	If not 'STR_DESCRIPTORS', the function returns null.
;
;	cat:		String giving the name of the star catalog.  
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Observer descriptor.
;
;	key8:		Array of requested object names.
;
;  OUTPUT:
;	status:		Zero if valid data is returned.
;
;
;  TRANSLATOR KEYWORDS:
;	j2000:		Set to use j2000 reference frame.
;
;	b1950:		Set to use b1950 reference frame.
;
;	faint:		Faintest limiting visual magnitude.
;
;	bright:		Brightest limiting visual magnitude.
;
;	nbright:	Maximum number of brightest stars to return.
;
;	path:		Path to the star catalog data.  If not set, the
;			environment variable NV_<cat>_DATA is checked.
;
;	fov:		Number of fields of view in which to retrieve stars.
;
;	cov:		Image coordinates of center of view in which to
;			retrieve stars. [[maybe change this to RA/DEC]]
;
;
;
; ENVIRONMENT VARIABLES:
;	NV_<cat>_DATA:		Directory containing the star catalog data.
;
;
; RETURN:
;	Array of star descriptors.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	MOdified:	Ryan, 8/2016
;	
;-
;=============================================================================



;=============================================================================
; strcat_parm__define
;
;=============================================================================
pro strcat_parm__define

struct = $
  { strcat_parm, $
    od:		obj_new(), $	; observer descriptor
    format:	'', $		; catalog format j2000 or b1950
    coord:	'', $		; input / output coord. sys j2000 or b1950
    time:	0d, $
    jtime:	0d, $
    path:	'', $		; catalog path
    names_p:	ptr_new(), $	; requested star names
    ra1:	0d, $		; FOV bounds
    ra2:	0d, $		;
    dec1:	0d, $		;
    dec2:	0d, $		;
    faint:	0d, $		; faintest star
    bright:	0d, $		; brightest star
    nbright:	0l, $		; number of brightest stars
    nmax:	0l, $		; max # estimated stars
    force:	0l$		; force us of this catalog
  }

end
;=============================================================================



;=============================================================================
; strcat_nbright
;
;=============================================================================
pro strcat_nbright, sd, parm

 if(NOT keyword_set(parm.nbright)) then return

 mags = str_get_mag(sd, od=parm.od)

 n = n_elements(mags)
 if(n LT parm.nbright) then return

 sd = sd[(sort(mags))[0:parm.nbright-1]]
end
;=============================================================================



;=============================================================================
; strcat_parm_struct
;
;=============================================================================
function strcat_parm_struct

 parm = {strcat_parm}

 parm.jtime = !values.d_nan
 parm.names_p = ptr_new('')
 parm.faint = !values.d_nan
 parm.bright = !values.d_nan

 return, parm
end
;=============================================================================



;=============================================================================
; strcat_get_inputs
;
;=============================================================================
function strcat_get_inputs, dd, cat, format, remote=remote, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 parm = strcat_parm_struct()

 env = 'NV_' + cat + '_DATA'
 key = 'path_' + strlowcase(cat)

 ;---------------------------------------------------------
 ; Translator keywords
 ;---------------------------------------------------------
 parm.format = format
 parm.force = dat_keyword_value(dd, 'force')
 parm.nmax = dat_keyword_value(dd, 'nmax')

 parm.coord = 'j2000'
 if(keyword_set(dat_keyword_value(dd, 'b1950'))) then coord = 'b1950'

 _jtime = dat_keyword_value(dd, 'jtime')
 if(_jtime NE '') then parm.jtime = double(_jtime)

 _faint = dat_keyword_value(dd, 'faint')
 if(_faint NE '') then parm.faint = double(_faint)

 _bright = dat_keyword_value(dd, 'bright')
 if(_bright NE '') then parm.bright = double(_bright)

 parm.nbright = long(dat_keyword_value(dd, 'nbright'))

 ;---------------------------------------------------------
 ; Star catalog path
 ;---------------------------------------------------------
 if(NOT keyword_set(remote)) then $
  begin
   parm.path = dat_keyword_value(dd, key)
   if(NOT keyword_set(parm.path)) then parm.path = getenv(env);
   if(NOT keyword_set(parm.path)) then $
    begin
     nv_message, /warning, env + ' not defined.  No star catalog.'
     return, !null
    end
  end

 ;---------------------------------------------------------
 ; Observer descriptor passed as key1
 ;---------------------------------------------------------
 if(keyword_set(key1)) then ods = key1 
 if(NOT cor_isa(ods[0], 'BODY')) then ods = 0
 if(NOT keyword_set(ods)) then return, !null
 od = ods[0]

 ;---------------------------------------------------------
 ; fov and cov 
 ;---------------------------------------------------------
 fov = double(dat_keyword_value(dd, 'fov'))
 if(NOT keyword_set(fov)) then fov = 1

 cov = double(parse_comma_list(dat_keyword_value(dd, 'cov'), delim=';'))
 if(keyword_set(cov)) then cov = transpose(cov) $
 else if(NOT keyword_set(cov)) then cov = cam_oaxis(od)
   ;;; this assumes od is a camera.  Not great.

 ;---------------------------------------------------------
 ; Names passed as key8
 ;---------------------------------------------------------
 if(keyword_set(key8)) then $
  begin
   names = key8
   if(n_elements(names) EQ 1) then $
        if(strupcase(names[0]) EQ 'SUN') then return, !null
   *parm.names_p = names
  end

 ;---------------------------------------------------------
 ; Get jtime 
 ;---------------------------------------------------------
 parm.time = bod_time(od)
 if(NOT finite(parm.jtime)) then $
  begin
   parm.jtime = parm.time/(365.25d*86400d)      ; assuming camtime is secs past 2000
   if(parm.coord EQ 'b1950') then parm.jtime = parm.jtime + 50.
  end

 ;---------------------------------------------------------
 ; Get ra/dec limits 
 ;---------------------------------------------------------
 parm.ra1 = 0d & parm.ra2 = 2d*!dpi * 0.999
 parm.dec1 = -!dpi/2d * 0.999 & parm.dec2 = -parm.dec1 * 0.999

 if(keyword_set(fov)) then $
  begin
   cam_scale = min(cam_scale(od))
   cam_size = cam_size(od)

   radec0 = image_to_radec(od, cov)
   cam_fov = min(cam_scale*cam_size)
   field = fov*cam_fov

   parm.ra1 = reduce_angle(radec0[0] + field)
   parm.ra2 = reduce_angle(radec0[0] - field)

   parm.dec1 = radec0[1] + field
   parm.dec2 = radec0[1] - field
  end $
 else nv_message, /warning, $
      'No FOV limits set for star catalog search.', $
       exp=['Without FOV limits, stars will be returned for the entire sky.', $
            'This may cause the software to run very slowly.']


 ;---------------------------------------------------------
 ; Precess FOV cooordinates if needed if needed
 ;---------------------------------------------------------
; strcat_precess, parm


 ;---------------------------------------------------------
 ; sort ra/dec bounds
 ;---------------------------------------------------------
 ras = [parm.ra1,parm.ra2]
 decs = [parm.dec1,parm.dec2]
 ras = ras[sort(ras)]
 decs = decs[sort(decs)]

 parm.ra1 = ras[0] & parm.ra2 = ras[1]
 parm.dec1 = decs[0] & parm.dec2 = decs[1]


 ;---------------------------------------------------------
 ; Convert ra and dec bounds of scene from rad -> deg
 ;---------------------------------------------------------
 parm.ra1 = parm.ra1 * 180d / !dpi
 parm.ra2 = parm.ra2 * 180d / !dpi
 parm.dec1 = parm.dec1 * 180d / !dpi
 parm.dec2 = parm.dec2 * 180d / !dpi



 return, parm
end
;=============================================================================



;=============================================================================
; strcat_flag
;
;
;=============================================================================
function strcat_flag, cat

 first = strmid(cat, 0, 1)
 if((str_isalphanum(first))[0] NE -1) then return, ''

 cat = strmid(cat, 1, 128)
 return, first
end
;=============================================================================



;=============================================================================
; strcat_input
;
;
;=============================================================================
function strcat_input, dd, keyword, cat, format, n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 status = -1
 if(keyword NE 'STR_DESCRIPTORS') then return, ''

 if(NOT keyword_set(format)) then format = 'j2000'
 format = strlowcase(format)


 ;------------------------------------
 ; parse any catalog flag
 ;------------------------------------
 cat = strupcase(cat)
 flag = strcat_flag(cat)
 if(flag EQ '+') then remote = 1


 ;---------------------------------------------------------
 ; Get input data
 ;---------------------------------------------------------
 parm = strcat_get_inputs(dd, cat, format, remote=remote, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)
 if(NOT keyword_set(parm)) then return, ''


 ;----------------------------------------------------------------------------
 ; If we make it here, then we can consider this a success, even if no stars
 ;----------------------------------------------------------------------------
 status = 0
 n_obj = 0
 dim = [1]


 ;---------------------------------------------------------
 ; Precess cooordinates if needed if needed
 ;---------------------------------------------------------
 strcat_precess, parm


 ;-------------------------------------------------------------
 ; Get the regions/index file for the catalog if a local file
 ;-------------------------------------------------------------
 regions = call_function(cat + '_GET_REGIONS', parm)
 nregions = n_elements(regions)
 if(NOT keyword_set(regions)) then nv_message, verb=0.5, $
                                             'No ' + cat + ' regions found.' $
 else nv_message, verb=0.1, $
                    'Number of ' + cat + ' regions found ' + strtrim(nregions,2)


 ;---------------------------------------------------------
 ; Get star descriptors for all stars in all regions
 ;---------------------------------------------------------
 for i=0, nregions-1 do $
   stars = append_array(sd, call_function(cat + '_GET_STARS', dd, regions[i], parm))
 if(NOT keyword_set(stars)) then return, ''

 sd = strcat_construct_descriptors(dd, parm, stars)
 if(NOT keyword_set(sd)) then return, ''


 ;--------------------------------------------------------
 ; indicate that light time is included in catalog states
 ;--------------------------------------------------------
 bod_set_aberration, sd, 'LT'


 ;--------------------------------------------------------
 ; Apply brightness threshold to data
 ;--------------------------------------------------------
; if(keyword_set(parm.nbright)) then sd = strcat_nbright(parm.od, sd, nbright)
 strcat_nbright, sd, parm
 n_obj = n_elements(sd)


 ;---------------------------------------------------------
 ; Return silently if no stars are left
 ;---------------------------------------------------------
 if(n_obj EQ 0) then return, ''
 
 stcat = stars[0].cat
 scat = keyword_set(stcat) ? cat + '[' + stcat + ']' : cat
 nv_message, /con, 'Total ' + scat + ' stars found: ' + strtrim(n_obj, 2)
 
 bod_set_time, sd, parm.time

 return, sd
end
;===============================================================================
