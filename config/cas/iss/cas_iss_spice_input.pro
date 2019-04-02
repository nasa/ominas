;=============================================================================
;+
; NAME:
;	cas_iss_spice_input
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
;	result = spice_input(dd, keyword)
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
;	cas_iss_spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================



;===========================================================================
; cas_iss_spice_parse_labels
;
;===========================================================================
pro cas_iss_spice_parse_labels, dd, _time, $
     exposure=exposure, size=size, filters=filters, oaxis=oaxis, target=target

 ndd = n_elements(dd)

 meta0 = {cas_iss_spice_label_struct}
 meta0.size = [1024,1024]
 meta0.oaxis = [511.5,511.5]

 for i=0, ndd-1 do $
  begin
   _meta = dat_header_info(dd[i])
   if(NOT keyword_set(_meta)) then _meta = meta0
   meta = append_array(meta, _meta)
  end

 if(NOT keyword_set(_time)) then _time = meta.time
 exposure = meta.exposure
 size = meta.size
 filters = meta.filters
 target = meta.target
 oaxis = meta.oaxis

end 
;=============================================================================



;===========================================================================
; cas_iss_spice_cameras
;
;===========================================================================
function cas_iss_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 sc = -82l
 plat = -82000l

 cas_iss_spice_parse_labels, dd, time, $
       exposure=exposure, size=size, filters=filters, oaxis=oaxis

 bin = 1024./size[0]

 case dat_instrument(dd[0]) of
	'CAS_ISS_NA': $
	  begin
	   inst = -82360l
	   scale = cas_iss_nac_scale() * bin
	   orient_fn = 'cas_cmat_to_orient'
	  end
	'CAS_ISS_WA': $
	  begin
	   inst = -82361l
	   scale = cas_iss_wac_scale() * bin
	   orient_fn = 'cas_cmat_to_orient'
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
		cam_fn_psf = make_array(ndd, val='cas_iss_psf'), $
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
; cas_iss_spice_planets
;
;===========================================================================
function cas_iss_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 cas_iss_spice_parse_labels, dd, time, target=target

 return, gen_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_iss_spice_sun
;
;===========================================================================
function cas_iss_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 cas_iss_spice_parse_labels, dd, time

 return, gen_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
            status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_iss_spice_input.pro
;
;
;===========================================================================
function cas_iss_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 return, spice_input(dd, keyword, 'cas', 'iss', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
