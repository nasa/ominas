;=============================================================================
;NOT FINISHED YET, COPIED FROM cas_iss_spice_input.pro FIRST
;+
; NAME:
;	cas_uvis_spice_input
;
;
; PURPOSE:
;	NAIF/SPICE input translator for Cassini UVIS. 
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
;	cas_uvis_spice_output
;
;
; MODIFICATION HISTORY:
; 	Edited by:	Andy Ham, 8/2017
;	
;-
;=============================================================================



;===========================================================================
; cas_uvis_spice_parse_labels
;
;===========================================================================
pro cas_uvis_spice_parse_labels, dd, _time, $
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
     if(NOT keyword_set(_time)) then time[i] = cas_uvis_spice_time(label)

     ;-----------------------------------
     ; exposure time
     ;-----------------------------------
     tim=cas_uvis_spice_time(dd[i],exposure=exp)
     exposure[i] = exp

     ;-----------------------------------
     ; image size
     ;-----------------------------------
     axisname=strsplit(pdspar(label,'AXIS_NAME'),' ,()',/extract)
     coreitems=long(strsplit(pdspar(label,'CORE_ITEMS'),' ,()',/extract))
     size[1,i] = coreitems[where(strmatch(axisname,'*SAMPLE*',/fold_case))]
     size[0,i] = coreitems[where(strmatch(axisname,'*LINE*',/fold_case))]

     ;-----------------------------------
     ; filters
     ;-----------------------------------
     filters[*,i] = strmid(pdspar(label,'PRODUCT_ID'),1,3)

     ;-----------------------------------
     ; target
     ;-----------------------------------
     target_name = strupcase(pdspar(label, 'TARGET_NAME'))
     target_desc = strupcase(pdspar(label, 'TARGET_DESC') )
     target[i] = target_name
     obs_id = pdspar(label, 'OBSERVATION_ID')
     if((strpos(strupcase(obs_id), 'OPNAV'))[0] NE -1) then target[i] = target_desc
    end

   ;-----------------------------------
   ; optic axis
   ;-----------------------------------
   oaxis[*,i] = [-2,6];size[*,i]/2d;[-2,36];size[*,i]/2d
  end

 if(NOT keyword_set(_time)) then _time = time

end 
;=============================================================================



;===========================================================================
; cas_uvis_spice_cameras
;
;===========================================================================
function cas_uvis_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 sc = -82l
 plat = -82000l

 cas_uvis_spice_parse_labels, dd, time, $
       exposure=exposure, size=size, filters=filters, oaxis=oaxis

 bin = 1
 label=dat_header(dd[0])
 cam_scale=make_array(2,ndd, val=1d0)
 case pdspar(label,'SLIT_STATE') of
	'LOW_RESOLUTION': begin
	   inst = -82840l ;FUV_LO
	   cam_scale[1,*]=2d0*0.04297d0*!dpi/180d0
	   cam_scale[0,*]=(2d0*1.83346495*!dpi/180d0)/134d0   
	  end
	 else: begin
	   inst = -82840l ;FUV_HI
	   cam_scale[1,*]=2d0*0.02148592d0*!dpi/180d0
	   cam_scale[0,*]=(2d0*1.83346495*!dpi/180d0)/134d0 
	 end
 endcase
 orient_fn = 'cas_cmat_to_orient'
 return, cas_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = time, $
		cam_scale = cam_scale, $
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
; cas_uvis_spice_planets
;
;===========================================================================
function cas_uvis_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 cas_uvis_spice_parse_labels, dd, time, target=target

 return, gen_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_uvis_spice_sun
;
;===========================================================================
function cas_uvis_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 cas_uvis_spice_parse_labels, dd, time

 return, gen_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
            status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_uvis_spice_input.pro
;
;
;===========================================================================
function cas_uvis_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 return, spice_input(dd, keyword, 'cas', 'uvis', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
