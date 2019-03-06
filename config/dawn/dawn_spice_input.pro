;=============================================================================
;+
; NAME:
;	dawn_spice_input
;
;
; PURPOSE:
;	NAIF/SPICE input translator for Dawn. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = dawn_spice_input(dd, keyword)
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
;	dawn_spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================


;===========================================================================
; dawn_spice_parse_labels
;
;===========================================================================
pro dawn_spice_parse_labels, dd, _time, $
   size=size, size=size, filters=filters, oaxis=oaxis, target=target

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
     if(NOT keyword_set(_time)) then time[i] = dawn_spice_time(dd)

     exposure[i] = pdspar(label, 'EXPOSURE_DURATION')/1000d
     size[0,i] = double((pdspar(label, 'LINE_SAMPLES'))[0])
     size[1,i] = double((pdspar(label, 'LINES'))[0])

     oaxis[*,i] = size[*,i]/2d

    filters[*,i] = ''
;    filters[*,i] = pdspar(label, 'FILTER_NAME')

     target = strupcase(pdspar(label, 'TARGET_NAME'))

    end
  end

 if(NOT keyword_set(_time)) then _time = time

end 
;=============================================================================


;===========================================================================
; dawn_spice_cameras
;
;===========================================================================
function dawn_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 sc = -203l
 plat = -203000l

 dawn_spice_parse_labels, dd, time, $
          exposure=exposure, size=size, filters=filters, oaxis=oaxis

 case dat_instrument(dd[0]) of
	'DAWN_FC1': $
	  begin
	   inst=-203110l
	   orient_fn = 'dawn_cmat_to_orient_fc'
	  end
	'DAWN_FC2': $
	  begin
	   inst=-203120l
	   orient_fn = 'dawn_cmat_to_orient_fc'
	  end
 endcase

 cam_scale = dawn_spice_scale(inst)


 return, dawn_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = cam_time, $
		cam_scale = make_array(2,ndd, val=scale), $
		cam_oaxis = cam_oaxis, $
		cam_fn_psf = make_array(ndd, val='dawn_psf'), $
		cam_filters = filters, $
		cam_size = [cam_nx, cam_ny], $
		cam_exposure = cam_exposure, $
		cam_fn_focal_to_image = make_array(ndd, val='cam_focal_to_image_linear'), $
		cam_fn_image_to_focal = make_array(ndd, val='cam_image_to_focal_linear'), $
		cam_fi_data = [nv_ptr_new()], $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
                  orient_fn )

end
;===========================================================================



;===========================================================================
; dawn_spice_planets
;
;===========================================================================
function dawn_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 dawn_spice_parse_labels, dd, time, target=target

 return, gen_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; dawn_spice_sun
;
;===========================================================================
function dawn_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 dawn_spice_parse_labels, dd, time
 
 return, gen_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
                      status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; dawn_spice_input.pro
;
;
;===========================================================================
function dawn_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 return, spice_input(dd, keyword, 'dawn', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
