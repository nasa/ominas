;=============================================================================
;+
; NAME:
;	vgr_spice_input
;
;
; PURPOSE:
;	NAIF/SPICE input translator for Voyager.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = vgr_spice_input(dd, keyword)
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
;	vgr_spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================


;===========================================================================
; vgr_spice_parse_labels
;
;===========================================================================
pro vgr_spice_parse_labels, dd, _time, $
     exposure=exposure, size=size, filters=filters, oaxis=oaxis, scale=scale, $
     target=target

 ndd = n_elements(dd)

 name = cor_name(dd[0])

 time = dblarr(ndd)
 exposure = dblarr(ndd)
 size = make_array(2,ndd, val=1024)
 filters = strarr(2,ndd)
 target = strarr(ndd)
 oaxis = dblarr(2,ndd)
 scale = dblarr(2,ndd)

 for i=0, ndd-1 do $
  begin
   label = dat_header(dd[i])
   if(keyword_set(label)) then $
    begin
     ;-----------------------------------
     ; time
     ;-----------------------------------
     if(NOT keyword_set(_time)) then time[i] = vgr_spice_time(label)

     ;-----------------------------------
     ; exposure time
     ;-----------------------------------
     exposure[i] = vicar_vgrkey(label, 'EXP') / 1000d

     ;-----------------------------------
     ; image size, scale
     ;-----------------------------------

     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; geom'd image
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     geom = 0
     if(strpos(label,'GEOM') NE -1) then geom = 1
     if(strpos(label,'FARENC') NE -1) then geom = 1
     if(strpos(label,'*** OBJECT SPACE') NE -1) then geom = 1
     s = dat_dim(dd)
     if(s[0] EQ 1000 AND s[1] EQ 1000) then geom = 1
 
     if((geom)) then $
      begin
       scale[*,i] = vgr_pixel_scale(name, /geom)
       size[0,i] = 1000d
       size[1,i] = 1000d
      end $
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; raw image   
     ;  Here we use initial guesses.  That's the best that
     ;  can be done before reseau marks are analyzed.
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     else $
      begin
       scale[*,i] = vgr_pixel_scale(name)
;       scale = scale / 0.85d			; just a guess!!
       size[0,i] = 800d
       size[1,i] = 800d
      end

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
     target = strupcase(vicgetpar(label, 'TARGET_NAME'))

    end
  end

 if(NOT keyword_set(_time)) then _time = time

end 
;=============================================================================


;===========================================================================
; vgr_spice_cameras
;
;===========================================================================
function vgr_spice_cameras, dd, ref, pos=pos, constants=constants, $
        n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)
 sc_name = vgr_parse_inst(dat_instrument(dd), cam=name)
 sc = -31l
 if(sc_name EQ 'vg2') then sc = -32l

 plat = 0l

 inst = sc*1000 - 001l				; na camera
 if(name EQ 'wa') then inst = sc*1000 - 002l	; wa camera
 orient_fn = 'vgr_cmat_to_orient_iss'


 vgr_spice_parse_labels, dd, time, $
    exposure=exposure, size=size, filters=filters, oaxis=oaxis, scale=scale


 return, vgr_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		tol = 100d, $
		orient = orient, $
		cam_time = time, $
		cam_scale = scale, $
		cam_oaxis = oaxis, $
		cam_fn_psf = make_array(ndd, val='vgr_psf'), $
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
; vgr_spice_planets
;
;===========================================================================
function vgr_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 vgr_spice_parse_labels, dd, time, target=target

 return, eph_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; vgr_spice_sun
;
;===========================================================================
function vgr_spice_sun, dd, ref, n_obj=n_obj, dim=dim, $
                   status=status, time=time, constants=constants, obs=obs

 vgr_spice_parse_labels, dd, time

 return, eph_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
                    status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; vgr_spice_input.pro
;
;
;===========================================================================
function vgr_spice_input, dd, keyword, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 return, spice_input(dd, keyword, 'vgr', values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
