;=============================================================================
;+
; NAME:
;	cas_spice_input
;
;
; PURPOSE:
;	NAIF/SPICE input translator for Cassini. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = cas_spice_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Camera descriptor.
;
;  OUTPUT:
;	status:		Zero if valid data is returned.
;
;
;  TRANSLATOR KEYWORDS:
;	ref:		Name of the reference frame for the output quantities.
;			Default is 'j2000'.
;
;	j2000:		/j2000 is equivalent to specifying ref=j2000.
;
;	b1950:		/b1950 is equivalent to specifying ref=b1950.
;
;	klist:		Name of a file giving a list of SPICE kernels to use.
;			If no path is included, the path is taken from the 
;			NV_SPICE_KER environment variable.
;
;	ck_in:		List of input C kernel files to use.  List must be 
;			delineated by semimcolons with no space.  The kernel
;			list file is still used, but these kernels take
;			precedence.  Entries in this list may be file
;			specification strings.
;
;	planets:	List of planets to for which to request ephemeris.  
;			Must be delineated by semicolons with no space.
;
;	reload:		If set, new kernels are loaded, as specified by the
;			klist and ck_in keywords.
;
;
; RETURN:
;	Data associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	cas_spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================


;===========================================================================
; cas_spice_parse_labels
;
;===========================================================================
pro cas_spice_parse_labels, dd, _time, $
     exposure=exposure, size=size, filters=filters, oaxis=oaxis, target=target

 ndd = n_elements(dd)

 time = dblarr(ndd)
 exposure = dblarr(ndd)
 size = make_array(2,ndd, val=1024)
 filters = strarr(2,ndd)
 target = strarr(ndd)
 oaxis = dblarr(2,ndd)

 for i=0, ndd-1 do $
  begin
   label = dat_header(dd[i])
   if(keyword_set(label)) then $
    begin
     ;-----------------------------------
     ; time
     ;-----------------------------------
     if(NOT keyword_set(_time)) then time[i] = cas_spice_time(label)

     ;-----------------------------------
     ; exposure time
     ;-----------------------------------
     exposure[i] = vicgetpar(label, 'EXPOSURE_DURATION')/1000d

     ;-----------------------------------
     ; image size
     ;-----------------------------------
     size[0,i] = double(vicgetpar(label, 'NS'))
     size[1,i] = double(vicgetpar(label, 'NL'))

     ;-----------------------------------
     ; optic axis
     ;-----------------------------------
     oaxis[*,i] = size[*,i]/2d

     ;-----------------------------------
     ; filters
     ;-----------------------------------
     filters[*,i] = vicgetpar(label, 'FILTER_NAME')

     ;-----------------------------------
     ; target
     ;-----------------------------------
     target_name = strupcase(vicgetpar(label, 'TARGET_NAME'))
     target_desc = strupcase(vicgetpar(label, 'TARGET_DESC') )
     target[i] = target_name
     obs_id = vicgetpar(label, 'OBSERVATION_ID')
     if((strpos(strupcase(obs_id), 'OPNAV'))[0] NE -1) then target[i] = target_desc
    end
  end

 if(NOT keyword_set(_time)) then _time = time

end 
;=============================================================================


;===========================================================================
; cas_spice_cameras
;
;===========================================================================
function cas_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 sc = -82l
 plat = -82000l

 cas_spice_parse_labels, dd, time, $
       exposure=exposure, size=size, filters=filters, oaxis=oaxis

 bin = 1024./size[0]

 case dat_instrument(dd[0]) of
	'CAS_ISSNA': $
	  begin
	   inst = -82360l
	   scale = cas_nac_scale() * bin
	   orient_fn = 'cas_cmat_to_orient_iss'
	  end
	'CAS_ISSWA': $
	  begin
	   inst = -82361l
	   scale = cas_wac_scale() * bin
	   orient_fn = 'cas_cmat_to_orient_iss'
	  end
 endcase

 return, cas_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = time, $
		cam_scale = make_array(2,ndd, val=scale), $
		cam_oaxis = oaxis, $
		cam_fn_psf = make_array(ndd, val='cas_psf'), $
		cam_filters = filters, $
		cam_size = size, $
		cam_exposure = exposure, $
		cam_fn_focal_to_image = make_array(ndd, val='cam_focal_to_image_linear'), $
		cam_fn_image_to_focal = make_array(ndd, val='cam_image_to_focal_linear'), $
		cam_fi_data = [ptrarr(ndd)], $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
                  orient_fn )

end
;===========================================================================



;===========================================================================
; cas_spice_planets
;
;===========================================================================
function cas_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 cas_spice_parse_labels, dd, time, target=target

 return, eph_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_spice_sun
;
;===========================================================================
function cas_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 cas_spice_parse_labels, dd, time

 return, eph_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
            status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_spice_input.pro
;
;
;===========================================================================
function cas_spice_input, dd, keyword, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

 return, spice_input(dd, keyword, 'cas', values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
