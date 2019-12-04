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
; cas_spice_parse_labels
;
;===========================================================================
pro vims_spice_parse_labels, dd, _time, $
  exposure=exposure, size=size, filters=filters, oaxis=oaxis, target=target,$
  endjd=endjd,startjd=startjd
  
  compile_opt idl2

  ndd = n_elements(dd)

  time = dblarr(ndd)
  exposure = dblarr(ndd)
  size = make_array(2,ndd, val=1024)
  filters = strarr((dat_dim(dd[0]))[2],ndd)
  target = strarr(ndd)
  oaxis = dblarr(2,ndd)

  for i=0, ndd-1 do $
    begin
    label = dat_header(dd[i])
    llabel=strsplit(label,string(10B),/extract)
    if(keyword_set(label)) then $
      begin
      ttime=vims_spice_time(label,dt=dt,status=status,startjd=startjd,endjd=endjd)
      ;-----------------------------------
      ; time
      ;-----------------------------------
      if(NOT keyword_set(_time)) then begin
        time[i]=spice_str2et(ttime)+dt
      endif

      ;-----------------------------------
      ; exposure time
      ;-----------------------------------
      exposure[i] = 2d0*dt

      ;-----------------------------------
      ; image size
      ;-----------------------------------
      size[1,i] = fix(pp_get_label_value(label,'SWATH_LENGTH'))
      size[0,i] = fix(pp_get_label_value(label,'SWATH_WIDTH'))

      ;-----------------------------------
      ; optic axis
      ;-----------------------------------
      oaxis[0,i]=(size[0,i]-1d0)/2d0-3d0
      oaxis[1,i]=(size[1,i]-1d0)/2d0+3d0

      ;-----------------------------------
      ; filters
      ;-----------------------------------
      filters[*,i] = pp_getcubeheadervalue(llabel,'BAND_BIN_CENTER',/not_trimmed)+'_'+pp_getcubeheadervalue(llabel,'BAND_BIN_UNIT',/not_trimmed)

      ;-----------------------------------
      ; target
      ;-----------------------------------
      target_name = strupcase(pp_get_label_value(label, 'TARGET_NAME'))
      target_desc = strupcase(pp_get_label_value(label, 'TARGET_DESC'))
      target[i] = target_name
      obs_id = pp_get_label_value(label, 'OBSERVATION_ID')
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
function vims_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

compile_opt idl2
 ndd = n_elements(dd)

 sc = -82l
 plat = -82000l

 vims_spice_parse_labels, dd, time, $
       exposure=exposure, size=size, filters=filters, oaxis=oaxis,$
       endjd=endjd,startjd=startjd

 bin = 1
 
 
 
 
; label = dat_header(dd)
;
; if(NOT keyword_set(time)) then $
;  begin
;   time = vims_spice_time(label, dt=dt, status=status)
;   if(status NE 0) then return, ptr_new()
;   time = spice_str2et(time)
;   cam_time = time + dt
;  end $
; else cam_time = time
;
; bin = 1
; cam_nx = (cam_ny = 64d)
; if(keyword_set(label)) then $
;  begin
;   close_time=vims_spice_time(label,dt=dt,status=status,startjd=startjd,endjd=endjd)
;   cam_exposure=2d0*dt
;   cam_nx=fix(pp_get_label_value(label,'SWATH_LENGTH'))
;   cam_ny=fix(pp_get_label_value(label,'SWATH_WIDTH'))
;  end
;
; cam_oaxis = [(cam_nx - 1.), (cam_ny - 1.)]/2. + [-3.,+3.]





 case dat_instrument(dd[0]) of
	  'VIMS_IR': begin
	     inst=-82370L
	     cam_scale=5d-4 ;rad/pix
	     orient_fn = 'cas_cmat_to_orient_vims'
	     cam_nx=size[0,0]
	     cam_ny=size[1,0]
	     npixels=long(cam_nx)*long(cam_ny)
	     times=dindgen(npixels)*(endjd-startjd)*86400d0/(npixels*1d0)
;	     cam_time+=times
	     orients=dblarr(3,3,npixels)+!values.d_nan
	     poss=dblarr(1,3,npixels)+!values.d_nan
	     vels=poss
	     inds=array_indices([cam_nx,cam_ny],dindgen(npixels),/dimensions)
	     fnd={t0:startjd,times:times,orients:orients,inds:inds,poss:poss,vels:vels}
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
; filters=cam_name

; ret= cas_to_ominas( $
;           spice_cameras(dd, ref, '', '', pos=pos, $
;		sc = sc, $
;		inst = inst, $
;		plat = plat, $
;		orient = orient, $
;		cam_time = cam_time, $
;		cam_scale = cam_scale, $
;		cam_oaxis = cam_oaxis, $
;		cam_fn_psf = 'cas_psf', $
;		cam_filters = filters, $
;		cam_size = [cam_nx, cam_ny], $
;		cam_exposure = cam_exposure, $
;		cam_fn_focal_to_image = 'vims_focal_to_image_linear', $
;		cam_fn_image_to_focal = 'vims_image_to_focal_linear', $
;		;cam_fn_body_to_image='vims_body_to_image',$
;    ;            cam_fn_body_to_inertial='vims_body_to_inertial',$
;		cam_fi_data = fn_data,$;[nv_ptr_new()], $
;		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
;                  orient_fn )

 cd=cas_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
    sc = sc, $
    inst = inst, $
    plat = plat, $
    orient = orient, $
    cam_time = time, $
    cam_scale = make_array(2,ndd, val=cam_scale), $
    cam_oaxis = oaxis, $
    cam_fn_psf = make_array(ndd, val='cas_psf'), $
    cam_filters = dat_instrument(dd[0]), $
    cam_size = size, $
    cam_exposure = exposure, $
    cam_fn_focal_to_image = make_array(ndd, val='vims_focal_to_image_linear'), $
    cam_fn_image_to_focal = make_array(ndd, val='vims_image_to_focal_linear'), $
    cam_fi_data = [ptrarr(ndd)], $
    n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
                  orient_fn )
                  
  ret=list()
  foreach ccd,cd,icd do begin
    cds=objarr((dat_dim(dd[icd]))[2])
    foreach cdsf,cds,ifi do begin
      cds[ifi]=nv_clone(ccd)
      cam_set_filters,cds[ifi],filters[ifi]
      cor_set_name,cds[ifi],dat_instrument(dd[0])+'_'+(strsplit(filters[ifi],'_',/extract))[0]
    endforeach
    ret.add,cds,/extract
  endforeach
  ret=ret.toarray()
  ;cams=reform(cam_evolve(ret,times))
  ;for i=0,npixels-1 do fnd.orients[*,*,i]=bod_orient(cams[i])
  ;(*(fn_data[0]))=fnd
  
;  fnd=(cam_fn_data_p(ret))
;  for i=0,npixels-1 do begin
;    cmat=(*fnd).orients(*,*,i)
;    (*fnd).orients[*,*,i]=call_function(orient_fn,cmat)
;  endfor
;  (*fnd).poss=(*fnd).poss*1d3
;  (*fnd).vels=(*fnd).vels*1d3
  
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

compile_opt idl2
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

compile_opt idl2
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









;===========================================================================
; cas_spice_input.pro
;
;
;===========================================================================
function vims_spice_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords
compile_opt idl2
;key7=vims_spice_time(nv_header(dd))
key7=vims_spice_time(dat_header(dd))
 return, spice_input(dd, keyword, 'vims', values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
