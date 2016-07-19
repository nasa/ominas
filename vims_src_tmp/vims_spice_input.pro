;=============================================================================
;+
; NAME:
;	vims_spice_input
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
;	n_obj:		Number of objects returned.
;
;	dim:		Dimensions of return objects.
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
; cas_spice_cameras
;
;===========================================================================
function vims_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ;cam_name = nv_instrument(dd)
 cam_name = dat_instrument(dd)

 sc = -82l
 plat = -82000l

 ;label = nv_header(dd)
 label = dat_header(dd)

 if(NOT keyword_set(time)) then $
  begin
   time = vims_spice_time(label, dt=dt, status=status)
   if(status NE 0) then return, ptr_new()
   time = spice_str2et(time)
   cam_time = time + dt
  end $
 else cam_time = time

 bin = 1
 cam_nx = (cam_ny = 64d)
 if(keyword_set(label)) then $
  begin
   close_time=vims_spice_time(label,dt=dt,status=status,startjd=startjd,endjd=endjd)
   cam_exposure=2d0*dt
   ;cam_exposure = vicgetpar(label, 'EXPOSURE_DURATION')/1000d
   ;cam_nx = double(vicgetpar(label, 'NS'))
   ;cam_ny = double(vicgetpar(label, 'NL'))
   cam_nx=fix(pp_get_label_value(label,'SWATH_LENGTH'))
   cam_ny=fix(pp_get_label_value(label,'SWATH_WIDTH'))
  end

 cam_oaxis = [(cam_nx - 1.), (cam_ny - 1.)]/2. + [-3.,+3.]
 ;bin = 1024./cam_nx

; bin = 0
; if(keyword_set(label)) then $
;  begin
;   cam_exposure = vicgetpar(label, 'EXPOSURE_DURATION')/1000d
;   cam_nx = double(vicgetpar(label, 'NS'))
;   cam_ny = double(vicgetpar(label, 'NL'))

;   cam_oaxis = [(cam_nx - 1.), (cam_ny - 1.)]/2.
;   bin = 1024./cam_nx
;  end

 case cam_name of
	'CAS_ISSNA': $
	  begin
	   inst=-82360l
	   cam_scale = cas_nac_scale() * bin
	  end
	'CAS_ISSWA': $
	  begin
	   inst=-82361l
	   cam_scale = cas_wac_scale() * bin
	  end
	  'VIMS_IR': begin
	     inst=-82370L
	     cam_scale=5d-4 ;rad/pix
	     orient_fn = 'cas_cmat_to_orient_vims'
	     npixels=long(cam_nx)*long(cam_ny)
	     times=dindgen(npixels)*(endjd-startjd)*86400d0/(npixels*1d0)
	     cam_time+=times
	     orients=dblarr(3,3,npixels)+!values.d_nan
	     inds=array_indices([cam_nx,cam_ny],dindgen(npixels),/dimensions)
	     fnd={t0:startjd,times:times,orients:orients,inds:inds}
	     fn_data=[ptr_new(fnd)]
	   end
	   'VIMS_VIS': begin
	     inst=-82371L
	     cam_scale=5d-4 ;rad/pix
	     orient_fn = 'cas_cmat_to_orient_vims'
	     fn_data=[nv_ptr_new()]
	   end
 endcase

 ;filters = vicgetpar(label, 'FILTER_NAME')
 filters=cam_name

 ret= cas_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = cam_time, $
		cam_scale = cam_scale, $
		cam_oaxis = cam_oaxis, $
		cam_fn_psf = 'cas_psf', $
		cam_filters = filters, $
		cam_size = [cam_nx, cam_ny], $
		cam_exposure = cam_exposure, $
		cam_fn_focal_to_image = 'vims_focal_to_image_linear', $
		cam_fn_image_to_focal = 'vims_image_to_focal_linear', $
		cam_fn_body_to_image='vims_body_to_image',$
                cam_fn_body_to_inertial='vims_body_to_inertial',$
		cam_fn_data = fn_data,$;[nv_ptr_new()], $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
                  orient_fn )
                  
  
  ;cams=reform(cam_evolve(ret,times))
  ;for i=0,npixels-1 do fnd.orients[*,*,i]=bod_orient(cams[i])
  ;(*(fn_data[0]))=fnd
  fnd=(cam_fn_data_p(ret))
  for i=0,npixels-1 do begin
    cmat=(*fnd).orients(*,*,i)
    (*fnd).orients[*,*,i]=call_function(orient_fn,cmat)
  endfor
  
  return,ret

end
;===========================================================================



;===========================================================================
; cas_spice_planets
;
;===========================================================================
function vims_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 ;label = nv_header(dd)
 label = dat_header(dd)

 if(NOT keyword_set(time)) then $
  begin
   time = vims_spice_time(label, dt=dt, status=status)
   if(status NE 0) then return, ptr_new()
   time = spice_str2et(time)
   plt_time = time + dt
  end $
 else plt_time = time

 if(keyword_set(label)) then $
  begin
   ;target_name = strupcase(vicgetpar(label, 'TARGET_NAME'))
   ;target_desc = strupcase(vicgetpar(label, 'TARGET_DESC'))
   target_name = strupcase(pp_get_label_value(label, 'TARGET_NAME'))
   target_desc = strupcase(pp_get_label_value(label, 'TARGET_DESC'))

   target = target_name

   ;obs_id = vicgetpar(label, 'OBSERVATION_ID')
   obs_id = pp_get_label_value(label, 'OBSERVATION_ID')
   if((strpos(strupcase(obs_id), 'OPNAV'))[0] NE -1) then target = target_desc
  end

 return, eph_spice_planets(dd, ref, time=plt_time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_spice_sun
;
;===========================================================================
function vims_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 ;label = nv_header(dd)
 label = dat_header(dd)

 if(NOT keyword__set(time)) then $
  begin
   time = vims_spice_time(label, dt=dt, status=status)
   if(status NE 0) then return, ptr_new()
   time = spice_str2et(time)
   sun_time = time + dt
  end $
 else sun_time = time
 
 return, eph_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
            status=status, time=sun_time, constants=constants, obs=obs)

end
;===========================================================================

;=============================================================================
; vims_spice_lsk_detect
;
;=============================================================================
function vims_spice_lsk_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all
 return, eph_spice_lsk_detect(dd, kpath, time=time, reject=reject, strict=strict, all=all)
end
;=============================================================================

function vims_spice_ck_detect, dd, ckpath, djd=djd, time=time, $
  all=all, reject=reject, strict=strict
return,cas_spice_ck_detect(dd, ckpath, djd=djd, time=time, $
  all=all, reject=reject, strict=strict)
end

;=============================================================================
; vims_spice_pck_detect
;
;
;=============================================================================
function vims_spice_pck_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all
  return, eph_spice_pck_detect(dd, kpath, time=time, reject=reject, strict=strict, all=all)
end
;=============================================================================

function vims_spice_ik_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all
return,cas_spice_ik_detect(dd, kpath, time=time, reject=reject, strict=strict, all=all)
end

function vims_spice_fk_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all
return,cas_spice_fk_detect(dd, kpath, time=time, reject=reject, strict=strict, all=all)
end

function vims_spice_sck_detect, dd, kpath, time=time, reject=reject, strict=strict, all=all
return,cas_spice_sck_detect(dd, kpath, time=time, reject=reject, strict=strict, all=all)
end

function vims_spice_spk_detect, dd, kpath, reject=spk_reject_files, $
  strict=strict, all=all, time=_time
return, cas_spice_spk_detect(dd, kpath, reject=spk_reject_files, $
  strict=strict, all=all, time=_time)
end

;===========================================================================
; cas_spice_input.pro
;
;
;===========================================================================
function vims_spice_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords
;key7=vims_spice_time(nv_header(dd))
key7=vims_spice_time(dat_header(dd))
 return, spice_input(dd, keyword, 'vims', n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================